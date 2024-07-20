import SwiftUI
import Combine
import MapKit
import AVKit
import PhotosUI
import ContactsUI

extension Binding {
    func conditionally(condition: @escaping (Value) -> Bool) -> Binding {
        Binding(
            get: { wrappedValue },
            set: { value, transaction in
                if condition(value) {
                    wrappedValue = value
                }
            }
        )
    }
}

struct PhotosPickerItemImage: View {
    @Binding var item: PhotosPickerItem?
    @State private var image: Image? = nil
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else if isLoading {
                ProgressView()
            } else {
                Text("No Image Selected")
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: item) {
            loadImage()
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let item = item else {
            image = nil
            return
        }
        
        isLoading = true
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data?):
                    if let uiImage = UIImage(data: data) {
                        image = Image(uiImage: uiImage)
                    } else {
                        image = nil
                    }
                case .success(nil), .failure:
                    image = nil
                }
            }
        }
    }
}

extension Binding {
    func map<T>(
        get: @escaping (Value) -> T,
        set: @escaping (T, inout Value) -> Void = { _, _ in }
    ) -> Binding<T> {
        Binding<T>(
            get: { get(self.wrappedValue) },
            set: { new, transaction in
                set(new, &self.wrappedValue)
            }
        )
    }
}

final class Objectz: ObservableObject {
    
//    private let bar = "Bar"
//    @State var foo = "Foo"
    @ReadOnlyPublished var thing = UIColor.green // LAZY DOES NOT WORK
    @Published var foo: String = "hi"
    @Published var baz2: Int = 5000 // read only needs viewz conformance
    @Published var pickImage: PhotosPickerItem?
    @Published var image: UIImage?
    @Published var things = [
        Bar(string: "hi", array: [0,1,2,3], function: { _ in 5 }, dictionary: ["foo": "bar"]),
        Bar(string: "hello", array: [3,2], function: { _ in 5 }, dictionary: ["foo": "bar"])
    ]
    
    @Published var baz: Int = 0
    @Published var incrementBaz = Action.idle

    init() {
        $incrementBaz
            .print()
            .removeDuplicates()
            .filter { $0 == .beginning }
            .delay(for: 1, scheduler: RunLoop.main) // only works if called async 🫤
            .combineLatest($baz.removeDuplicates())
            .map { $0.1 + 1 }
            .assign(to: &$baz)
        
        $baz
            .removeDuplicates()
            .combineLatest($incrementBaz.removeDuplicates())
            .map { _ in .idle }
            .assign(to: &$incrementBaz)
    }
    
//    @State var age: Int = 0
    @Published var date = Date()
    @Published var toggle = false
    @Published var color = Color.red
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 51.507222,
            longitude: -3.1275
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.5,
            longitudeDelta: 0.5
        )
    )
//    @State var button: Void = ()
//    @State var image: PhotosPickerItem?
    @Published var contact: CNContact?
//
//    let thing = (
//        video: AVPlayerItem(url: Bundle.main.url(forResource: "drift", withExtension: "mov")!),
//        link: URL(string: "http://www.google.com"),
//        singleImage: UIImage(systemName: "star.fill"),
//        manyImage: Array(repeating: UIImage(systemName: "star.fill"), count: 100),
////        pickableImage: $image,
////        color: $color,
////        toggle: $toggle,
////        date: $date,
//        contact: CNContact(),
////        pickableContact: $contact,
////        map: $region,
////        button: $button,
//        foo: 3,
//        things: [1, 2, 3],
////        age: (age, edit: $age.conditionally { $0 > 0 && $0 <= 5 }),
////        (name: (key: "yo", value: foo), edit: $foo.conditionally { $0.count <= 10 }),
//        Just(
//            Foo(
//                integer: 8,
//                structs: [
//                    Bar(
//                        string: "foo",
//                        array: [1, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3],
//                        function: { _ in 8 },
//                        dictionary: [
//                            "hello": "world",
//                            "foo": nil
//                        ]
//                    ),
//                    Bar(
//                        string: "foo",
//                        array: [1, 2, 3],
//                        function: { _ in 8 },
//                        dictionary: [
//                            "hello": "world",
//                            "foo": "barz"
//                        ]
//                    ),
//                    Bar(
//                        string: "foo",
//                        array: [1, 2, 3],
//                        function: { _ in 8 },
//                        dictionary: [
//                            "hello": "world",
//                            "foo": "barz"
//                        ]
//                    )
//                ],
//                tuple: (9, 999),
//                enum: .myCase(
//                    Bar(
//                        string: "foo",
//                        array: [1, 2, 3],
//                        function: { _ in 8 },
//                        dictionary: [
//                            "hello": "world",
//                            "foo": "barz"
//                        ]
//                    )
//                )
//            )
//        )
//    )
}

enum Action {
    
    /*
     Actions as Binding over Action.Enum
     - button sets state of action, object responds
     */
    

        case idle
        case considering
        case beginning
        case ending
        case error
}

//extension Async: Viewzable {
//    func value(label: String?) -> some View {
//        switch self.state {
//        case .awaiting:
//            AnyView(
//                HStack {
//                    if let value = value as? any Viewzable {
//                        AnyView(value.value(label: label))
//                        ProgressView().progressViewStyle(CircularProgressViewStyle())
//                    } else {
//                        Text("\(value)")
//                    }
//                }
//            )
//        case .idle:
//            if let value = value as? any Viewzable {
//                AnyView(value.value(label: label))
//            } else {
//                AnyView(Text("\(value)"))
//            }
//        }
//    }
//}

struct ContentView: View {
    
    @State var foo = "Foo"
    @State var age: Int = 0
    @State var date = Date()
    @State var toggle = false
    @State var color = Color.red
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 51.507222,
            longitude: -3.1275
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.5,
            longitudeDelta: 0.5
        )
    )
    @State var button: Void = ()
    @State var image: PhotosPickerItem?
    @State var contact: CNContact?
    @State var something: String = "Something"

    @ObservedObject var objectz = Objectz()
    
    var body: some View {
        
        Viewz { (objectz.baz, foo: $objectz.incrementBaz) }
        
//        Viewz {(
//            numbers: [0,1,1,1,1],
//            bars: [
//                Bar(string: "bar 1", array: [0,1,2,3], function: { _ in 5 }, dictionary: ["foo": "bar"]),
//                Bar(string: "bar 2", array: [0], function: { _ in 5 }, dictionary: ["foo": "bar"])
//            ]
//                .reduce(into: [String: Bar](), { sum, next in sum[next.string] = next })
//        )}
        
//        Viewz {(
//            (objectz.things.reduce(into: [String: Bar](), { sum, next in sum[next.string] = next })),
//            numbers: [1,2,3,4,5,6,7],
//            objectz,
//            colors: (color: objectz.color, edit: $objectz.color, third: "thing"),
//            [
//                Bar(string: "hi", array: [0,1,2,3], function: { _ in 5 }, dictionary: ["foo": "bar"]),
//                Bar(string: "hello", array: [0], function: { _ in 5 }, dictionary: ["foo": "bar"])
//            ]
//                .reduce(into: [String: Bar](), { sum, next in sum[next.string] = next })
//        )}
        
//        Viewz {(
//            (objectz.things.reduce(into: [String: Bar](), { sum, next in sum[next.string] = next })),
//            numbers: [1,2,3,4,5,6,7],
//            objectz,
//            colors: (color: objectz.color, edit: $objectz.color, third: "thing")
////            (number: objectz.baz, edit: $objectz.baz, foo: objectz.date),
////            mutableColor: $objectz.color
//        )}
        
        //        ScrollView {
        //            Viewz {(
        //                foo: [5,1,1,1,1,1],
        //                bar: "yes",
        //                baz: "no"
        //            )}
        //            Viewz {(
        //                foo: 3,
        //                things: [1, 2, 3],
        //                (age: age,
        //                editAge: $age.conditionally { $0 > 0 && $0 <= 5 }),
        //                (edit: $foo.conditionally { $0.count <= 10 },
        //                name: (key: "yo", value: foo))
        //            )}
        //            Viewz { [1, 2, 3] }
        //            Viewz { (age: age, value: $age.conditionally { $0 > 0 && $0 <= 5 }) }
        //            Viewz { $foo.conditionally { $0.count <= 10 } }
        //            Viewz { (key: "yo", value: foo) }
        
//        Viewz {(
//            video: AVPlayerItem(url: Bundle.main.url(forResource: "drift", withExtension: "mov")!),
//            link: URL(string: "http://www.google.com"),
//            singleImage: UIImage(systemName: "star.fill"),
//            manyImage: Array(repeating: UIImage(systemName: "star.fill"), count: 100),
//            pickableImage: $image,
//            color: $color,
//            toggle: $toggle,
//            date: $date,
//            contact: CNContact(),
//            pickableContact: $contact,
//            map: $region,
//            button: $button,
//            integer: 3,
//            array: [1, 2, 3],
//            age: (age, edit: $age.conditionally { $0 > 0 && $0 <= 5 }),
//            (name: (keyProperty: "yo", valueProperty: foo), edit: $foo.conditionally { $0.count <= 10 }),
//            Just(
//                Foo(
//                    integer: 8,
//                    structs: [
//                        Bar(
//                            string: "foo",
//                            array: [1, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3],
//                            function: { _ in 8 },
//                            dictionary: [
//                                "hello": "world",
//                                "foo": nil
//                            ]
//                        ),
//                        Bar(
//                            string: "foo",
//                            array: [1, 2, 3],
//                            function: { _ in 8 },
//                            dictionary: [
//                                "hello": "world",
//                                "foo": "barz"
//                            ]
//                        ),
//                        Bar(
//                            string: "foo",
//                            array: [1, 2, 3],
//                            function: { _ in 8 },
//                            dictionary: [
//                                "hello": "world",
//                                "foo": "barz"
//                            ]
//                        )
//                    ],
//                    tuple: (9, 999),
//                    enum: .myCase(
//                        Bar(
//                            string: "foo",
//                            array: [1, 2, 3],
//                            function: { _ in 8 },
//                            dictionary: [
//                                "hello": "world",
//                                "foo": "barz"
//                            ]
//                        )
//                    )
//                )
//            )
//        )}
    }
}

struct Bar {
    let string: String
    let array: [Int]
    let function: (Int) -> Int
    let dictionary: [String: String?]
}

struct Foo {
    let integer: Int
    let `structs`: [Bar]
    let tuple: (foo: Int, bar: Int)
    let `enum`: Baz
    
    enum Baz {
        case myCase(Bar)
    }
}

struct Viewz: View {
    
    private let opacity: Double
    private let label: String?
    private let isRoot: Bool
    private let constructor: () -> Any
 
    init(
        opacity: Double = 1.0,
        label: String? = nil,
        isRoot: Bool = true,
        constructor: @escaping () -> Any
    ) {
        self.opacity = opacity
        self.label = label?.hasPrefix(".") == true ? nil : label // "." for unlabled tuples
        self.isRoot = isRoot
        self.constructor = constructor
    }
    
    var body: some View {
        let parent = constructor()
        if let parent = parent as? any Viewzable {
            AnyView(parent.value(label: label))
        } else {
            let foo = HStack {
                VStack(alignment: .leading) {
                    if let parent = parent as? [UIImage] {
                        if let label = label {
                            Text(label.capitalized).font(.headline)
                        }
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 20) {
                            ForEach(parent.enumerated().map { (element: $1, offset: $0) }, id: \.offset) {
                                Image(uiImage: $0.element)
                            }
                        }
                        .padding(8)
                        .background(Color.purple.opacity(0.5))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)

                    } else if let parent = parent as? Dictionary<AnyHashable, Any> {
                        if let label = label {
                            Text(label.capitalized).font(.headline)
                        }
                        ForEach(parent.keys.map { $0 }, id: \.self) { x in
                            Viewz(
                                opacity: opacity - 0.15,
                                label: "\(x)",
                                isRoot: false,
                                constructor: { parent[x] ?? "None" }
                            )
                        }
                        .padding(8)
                        .background(Color.purple.opacity(0.5))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)
                       
                    } else if let functionType = getFunctionType(of: parent) {
                        if let label = label {
                            Text(label.capitalized).font(.headline)
                        }
                        Viewz(opacity: opacity - 0.15, isRoot: false) { functionType }

                    } else if Mirror(reflecting: parent).children.count > 0 {
                        if isRoot || label?.hasPrefix(".") == true || label?.isEmpty == true || label == nil {
                            if let label = label {
                                Text(label.capitalized).font(.headline)
                            }
                            ForEach(Array(Mirror(reflecting: parent).children.enumerated()), id: \.offset) { _, x in
                                Viewz(
                                    opacity: opacity - 0.15,
                                    label: x.label,
                                    isRoot: false,
                                    constructor: { x.value }
                                )
                                .padding(8)
                                .background(Color.purple.opacity(0.5))
                                .cornerRadius(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        } else {
                            NavigationLink(label?.capitalized ?? "Title Missing") {
                                ScrollView {
                                    ForEach(Array(Mirror(reflecting: parent).children.enumerated()), id: \.offset) { _, x in
                                        Viewz(
                                            opacity: opacity - 0.15,
                                            label: x.label,
                                            isRoot: false,
                                            constructor: { x.value }
                                        )
                                        .padding(8)
                                        .background(Color.purple.opacity(0.5))
//                                        .cornerRadius(8)
//                                        .frame(maxWidth: .infinity)
                                    }
                                    .padding(8)
                                    .background(Color.yellow.opacity(opacity))
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity)
                                    .navigationTitle(label?.capitalized ?? "Title Missing")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        if let label = label {
                            Text(label.capitalized).font(.headline)
                        }
                        Text("\(parent)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(8)
            .background(Color.yellow.opacity(opacity))
            .cornerRadius(8)
            .frame(maxWidth: .infinity)
            
            if isRoot {
                NavigationView {
                    ScrollView {
                        foo.navigationTitle("DataViewz")
                    }
                }
            } else {
                foo
            }
        }
    }
    
    private func getFunctionType(of value: Any) -> String? {
        let typeDescription = String(describing: type(of: value))
        let regex = try! NSRegularExpression(pattern: #"\(.*\) -> .+"#)
        if let match = regex.firstMatch(
            in: typeDescription,
            options: [],
            range: NSRange(
                location: 0,
                length: typeDescription.count
            )
        ) {
            let range = Range(match.range, in: typeDescription)!
            return String(typeDescription[range])
        }
        return nil
    }
}

import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
        print("did call load")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
            print("did init")
        }
        
        // MARK: WKNavigationDelegate methods
        
        // Handle page loading start
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            // Handle start of page load
            print("did start")
        }
        
        // Handle page loading completion
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Handle page load completion
            print("did finish")
        }
        
        // Handle navigation errors
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            // Handle navigation error
            print(error)
        }
        
        // Handle other navigation actions, e.g., user clicks
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Handle navigation action, e.g., open links in Safari
            decisionHandler(.allow)
        }
    }
}

import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> UIViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }
}

struct ContactView: UIViewControllerRepresentable {
    let contact: CNContact
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactView>) -> UIViewController {
        CNContactViewController(for: contact)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ContactView>) {

    }
}

struct MutableContactView: UIViewControllerRepresentable {
    @Binding var contact: CNContact?

    class Coordinator: NSObject, CNContactViewControllerDelegate {
        var parent: MutableContactView

        init(_ parent: MutableContactView) {
            self.parent = parent
        }

        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            parent.contact = contact
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController: CNContactViewController
        if let contact = contact {
            viewController = CNContactViewController(for: contact)
        } else {
            viewController = CNContactViewController(forNewContact: nil)
        }
        viewController.delegate = context.coordinator
        return UINavigationController(rootViewController: viewController)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
}

#Preview {
    Viewz { 3 }
}
