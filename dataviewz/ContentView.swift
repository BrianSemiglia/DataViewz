import SwiftUI
import Combine
import MapKit

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


    var body: some View {
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
        
        Viewz {(
            link: URL(string: "http://www.google.com"),
            UIImage(systemName: "star.fill"),
            color: $color,
            toggle: $toggle,
            date: $date,
            map: $region,
            button: $button,
            foo: 3,
            things: [1, 2, 3],
            (age: age, editAge: $age.conditionally { $0 > 0 && $0 <= 5 }),
            (edit: $foo.conditionally { $0.count <= 10 }, name: (key: "yo", value: foo)),
            Just(
                Foo(
                    integer: 8,
                    structs: [
                        Bar(
                            string: "foo",
                            array: [1, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3],
                            function: { _ in 8 },
                            dictionary: [
                                "hello": "world",
                                "foo": nil
                            ]
                        ),
                        Bar(
                            string: "foo",
                            array: [1, 2, 3],
                            function: { _ in 8 },
                            dictionary: [
                                "hello": "world",
                                "foo": "barz"
                            ]
                        ),
                        Bar(
                            string: "foo",
                            array: [1, 2, 3],
                            function: { _ in 8 },
                            dictionary: [
                                "hello": "world",
                                "foo": "barz"
                            ]
                        )
                    ],
                    tuple: (9, 999),
                    enum: .myCase(
                        Bar(
                            string: "foo",
                            array: [1, 2, 3],
                            function: { _ in 8 },
                            dictionary: [
                                "hello": "world",
                                "foo": "barz"
                            ]
                        )
                    )
                )
            )
        )}
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
        constructor: @escaping () -> Any
    ) {
        self.opacity = opacity
        self.label = label
        self.isRoot = true
        self.constructor = constructor
    }
    
    private init(
        opacity: Double = 1.0,
        label: String? = nil,
        isRoot: Bool = false,
        constructor: @escaping () -> Any
    ) {
        self.opacity = opacity
        self.label = label
        self.isRoot = isRoot
        self.constructor = constructor
    }
    
    var body: some View {
        let foo = HStack {
            let parent = constructor()
            if let label = label {
                Text(label.capitalized).font(.headline)
            }
            VStack(alignment: .leading) {
                if let parent = parent as? Binding<String> {
                    TextField("", text: parent)
                } else if let parent = parent as? Binding<Int> {
                    Stepper("", value: parent)
                } else if let parent = parent as? Binding<Date> {
                    DatePicker("", selection: parent)
                } else if let parent = parent as? Binding<Bool> {
                    Toggle("", isOn: parent)
                } else if let parent = parent as? Binding<Color> {
                    ColorPicker("", selection: parent)
                } else if let parent = parent as? Binding<Void> {
                    Button("Button") {
                        parent.wrappedValue = ()
                    }
                } else if let parent = parent as? Binding<MKCoordinateRegion> {
                    Map(coordinateRegion: parent)
                        .frame(width: 400, height: 300)
                } else if let parent = parent as? UIImage {
                    Image(uiImage: parent)
                } else if let parent = parent as? URL {
                    Link(destination: parent) {
                        Text(parent.description)
                    }
                } else if Mirror(reflecting: parent).children.count > 0 {
                    ForEach(Array(Mirror(reflecting: parent).children.enumerated()), id: \.offset) { _, x in
                        if Mirror(reflecting: x.value).children.count > 2 {
                            NavigationLink("\(x.label?.capitalized ?? "Some")") {
                                ScrollView {
                                    Viewz(opacity: opacity - 0.15, label: nil, isRoot: false) { x.value }
                                        .navigationTitle("\(x.label?.capitalized ?? "Some")")
                                }
                            }
                        } else {
                            Viewz(opacity: opacity - 0.15, label: x.label, isRoot: false) { x.value }
                        }
                    }
                } else if let functionType = getFunctionType(of: parent) {
                    Viewz(opacity: opacity - 0.15, isRoot: false) { functionType }
                } else {
                    Text("\(parent)")
                }
            }
            .padding(8)
            .background(Color.purple.opacity(0.5))
            .cornerRadius(8)
            .frame(maxWidth: .infinity)
        }
        .padding(8)
        .background(Color.yellow.opacity(opacity))
        .cornerRadius(8)
                
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
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        
    }
    
}


#Preview {
    ContentView()
}
