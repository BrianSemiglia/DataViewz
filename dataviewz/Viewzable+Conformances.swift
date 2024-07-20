import SwiftUI
import Combine
import MapKit
import AVKit
import PhotosUI
import ContactsUI

protocol Viewzable {
    associatedtype ViewType: View
    func value(label: String?) -> ViewType
}

extension CNContact: Viewzable {
    func value(label: String?) -> some View {
        VStack(alignment: .leading) {
            if let label = label {
                Text(label.capitalized).font(.headline)
                    .frame(maxWidth: .infinity)
            }
            ContactView(contact: self)
                .padding(8)
                .background(Color.purple.opacity(0.5))
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
        }
    }
}

extension Color: Viewzable {
    func value(label: String?) -> some View {
        VStack(alignment: .leading) {
            if let label = label {
                Text(label.capitalized).font(.headline)
                    .frame(maxWidth: .infinity)
            }
            self
                .padding(8)
                .background(Color.purple.opacity(0.5))
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
        }
    }
}

extension UIColor: Viewzable {
    func value(label: String?) -> some View {
        VStack(alignment: .leading) {
            if let label = label {
                Text(label.capitalized).font(.headline)
            }
            Color(uiColor: self)
                .padding(8)
                .background(Color.purple.opacity(0.5))
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
        }
    }
}

extension AVPlayerItem: Viewzable {
    func value(label: String?) -> some View {
        VStack(alignment: .leading) {
            if let label = label {
                Text(label.capitalized).font(.headline)
            }
            VideoPlayer(player: AVPlayer(playerItem: self))
                .aspectRatio(contentMode: .fit)
                .padding(8)
                .background(Color.purple.opacity(0.5))
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
        }
    }
}

extension UIImage: Viewzable {
    func value(label: String?) -> some View {
        VStack(alignment: .leading) {
            if let label = label {
                Text(label.capitalized).font(.headline)
            }
            Image(uiImage: self)
                .padding(8)
                .background(Color.purple.opacity(0.5))
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
        }
    }
}

extension URL: Viewzable {
    func value(label: String?) -> some View {
        VStack(alignment: .leading) {
            if let label = label {
                Text(label.capitalized).font(.headline)
            }
            Link(destination: self) {
                Text(self.description)
            }
            .padding(8)
            .background(Color.purple.opacity(0.5))
            .cornerRadius(8)
            .frame(maxWidth: .infinity)
        }
    }
}

extension State: Viewzable {
    func value(label: String?) -> some View {
        Viewz(
            label: label?.replacingOccurrences(of: "_", with: ""),
            isRoot: false,
            constructor: { projectedValue }
        )
    }
}

extension ReadOnlyPublished: Viewzable {
    func value(label: String?) -> some View {
        Viewz(
            label: label?.replacingOccurrences(of: "_", with: ""),
            isRoot: false,
            constructor: { self.wrappedValue }
        )
    }
}

extension Published: Viewzable {
    func value(label: String?) -> some View {
        self.view { x in
            Viewz(label: label) { x }
        }
    }
}

extension Optional: Viewzable {
    func value(label: String?) -> some View {
        switch self {
        case .none:
            return AnyView(Text("None"))
        case .some(let value):
            if let value = value as? any Viewzable {
                return AnyView(value.value(label: label))
            } else {
                return AnyView(Text("\(value)"))
            }
        }
    }
}

struct Async<T> {
    
    var value: T
    var state: State
    
    enum State {
        case awaiting
        case idle
    }
}

extension Binding: Viewzable {
    func value(label: String?) -> some View {
        HStack {
            if let self = self as? Binding<String> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                TextField("", text: self).frame(maxWidth: .infinity)
            } else if let self = self as? Binding<Action> {
                HStack {
                    Button(label ?? "Missing") {
                        self.wrappedValue = .beginning
                    }
                    .disabled(self.wrappedValue == .beginning)
                    if self.wrappedValue == .beginning {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            } else if let self = self as? Binding<Date> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                DatePicker("", selection: self).frame(maxWidth: .infinity)
            } else if let self = self as? Binding<Bool> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                Toggle("", isOn: self).frame(maxWidth: .infinity)
            } else if let self = self as? Binding<Color> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                ColorPicker("", selection: self).frame(maxWidth: .infinity)
            } else if let self = self as? Binding<CNContact?> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                MutableContactView(contact: self).frame(maxWidth: .infinity)
            } else if let self = self as? Binding<Int> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                Stepper("\(self.wrappedValue)", value: self).frame(maxWidth: .infinity)
            } else if let self = self as? Binding<MKCoordinateRegion> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                Map(coordinateRegion: self).frame(maxWidth: .infinity)
                //                        .frame(width: 400, height: 300)
            } else if let self = self as? Binding<PhotosPickerItem?> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                VStack(alignment: .center) {
                    PhotosPickerItemImage(item: self)
                    PhotosPicker(
                        selection: self,
                        matching: .images
                    ) {
                        Text ("Select Photos")
                    }
                }.frame(maxWidth: .infinity)
            } else if let self = self as? Binding<UIImage> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                Image(uiImage: self.wrappedValue).frame(maxWidth: .infinity)
            } else if let self = self as? Binding<UIImage?> {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                if let image = self.wrappedValue {
                    Image(uiImage: image).frame(maxWidth: .infinity)
                } else {
                    Text("")
                        .frame(maxWidth: .infinity)
                }
                // should be picker if @Published is gonna be considered mutable
                // picker from files? pickers from array? from where?
//                } else if Mirror(reflecting: self.wrappedValue).children.count > 0 {
//
//                    // TODO: how to combine this with Binding/Published/State types
//
//                    ForEach(Array(Mirror(reflecting: self).children.enumerated()), id: \.offset) { _, x in
//                        if Mirror(reflecting: x.value).children.count > 2 {
//                            NavigationLink("\(x.label?.capitalized ?? "Some")") {
//                                ScrollView {
//                                    Viewz(
//                                        opacity: 1,
//                                        label: nil,
//                                        isRoot: false
//                                    ) {
//                                        self.map(
//                                            get: { self.wrappedValue },
//                                            set: { _, x in x = "" }
//                                        )
//                                    }
//                                    .navigationTitle("\(x.label?.capitalized ?? "Some")")
//                                }
//                            }
//                        } else {
//                            Viewz(opacity: 1, label: x.label, isRoot: false) { x.value }
//                        }
//                    }
//                } else if Mirror(reflecting: self.wrappedValue).children.count > 1 {
//                    ForEach(Array(Mirror(reflecting: self.wrappedValue).children.enumerated()), id: \.offset) { _, x in
//                        if Mirror(reflecting: x.value).children.count > 2 {
//                            NavigationLink("\(x.label?.capitalized ?? "Some")") {
//                                ScrollView {
//                                    Viewz(opacity: 1, label: nil, isRoot: false) { x.value }
//                                        .navigationTitle("\(x.label?.capitalized ?? "Some")")
//                                }
//                            }
//                        } else {
//                            Viewz(opacity: 1, label: x.label, isRoot: false) { x.value }
//                        }
//                    }
            } else {
                if let label = label {
                    Text(
                        label
                            .replacingOccurrences(of: "_", with: "")
                            .capitalized
                    )
                    .font(.headline)
                }
                Text("\(self)").frame(maxWidth: .infinity)
            }
        }
        .padding(8)
        .background(Color.pink.opacity(0.75))
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }
}
