import SwiftUI

//extension Published {
//    func view<Fooz: View>(constructor: @escaping (inout Value) -> Fooz) -> some View {
//        PublishedWrapperView(
//            wrapper: PublishedWrapper(published: self),
//            constructor: constructor
//        )
//    }
//}
//
//struct PublishedWrapperView<Value, Fooz: View>: View {
//    @ObservedObject var wrapper: PublishedWrapper<Value>
//    let constructor: (inout Value) -> Fooz
//
//    init(wrapper: PublishedWrapper<Value>, constructor: @escaping (inout Value) -> Fooz) {
//        self.wrapper = wrapper
//        self.constructor = constructor
//    }
//    
//    var body: some View {
//        constructor(&wrapper.value)
//    }
//}
//
//final class PublishedWrapper<Value>: ObservableObject {
//    @Published var value: Value
//
//    init(published: Published<Value>) {
//        self._value = published
//    }
//}

final class PublishedToBinding<T>: ObservableObject {
    @Published var value: T
    init(published: Published<T>) {
        _value = published
    }
}

struct PublishedToBindingView<T, V: View>: View {
    @StateObject var value: PublishedToBinding<T>
    let constructor: (Binding<T>) -> V
    
    var body: some View {
        constructor($value.value)
    }
}

extension Published {
    @ViewBuilder
    func view<V: View>(@ViewBuilder constructor: @escaping (Binding<Value>) -> V) -> some View {
        PublishedToBindingView<Value, V>(
            value: PublishedToBinding(published: self),
            constructor: constructor
        )
    }
}

extension Binding {
    @ViewBuilder
    func view<Fooz: View>(@ViewBuilder constructor: @escaping (Value) -> Fooz) -> some View {
        BindingWrapperView(
            wrapper: BindingWrapper(binding: self),
            constructor: constructor
        )
    }
}

struct BindingWrapperView<Value, Fooz: View>: View {
    @ObservedObject var wrapper: BindingWrapper<Value>
    @ViewBuilder let constructor: (Value) -> Fooz

    init(wrapper: BindingWrapper<Value>, @ViewBuilder constructor: @escaping (Value) -> Fooz) {
        self.wrapper = wrapper
        self.constructor = constructor
    }
    
    var body: some View {
        constructor(wrapper.value)
    }
}

final class BindingWrapper<Value>: ObservableObject {
    @Binding var value: Value

    init(binding: Binding<Value>) {
        self._value = binding
    }
}

import Combine

@propertyWrapper
class ReadOnlyPublished<Value>: ObservableObject {
    private var _value: Value
    private let subject: PassthroughSubject<Value, Never>
    
    var wrappedValue: Value {
        get { _value }
    }
    
    var projectedValue: ReadOnlyPublished<Value> {
        return self
    }
    
    init(wrappedValue: Value) {
        self._value = wrappedValue
        self.subject = PassthroughSubject<Value, Never>()
    }
    
    func set(_ newValue: Value) {
        _value = newValue
        subject.send(_value)
        objectWillChange.send()
    }
    
    var publisher: AnyPublisher<Value, Never> {
        return subject.eraseToAnyPublisher()
    }
}

extension ReadOnlyPublished {
    func view<Fooz: View>(constructor: @escaping (Value) -> Fooz) -> some View {
        ReadOnlyPublishedWrapperView(
            wrapper: ReadOnlyPublishedWrapper(published: self),
            constructor: constructor
        )
    }
}

struct ReadOnlyPublishedWrapperView<Value, Fooz: View>: View {
    @ObservedObject var wrapper: ReadOnlyPublishedWrapper<Value>
    let constructor: (Value) -> Fooz

    init(wrapper: ReadOnlyPublishedWrapper<Value>, constructor: @escaping (Value) -> Fooz) {
        self.wrapper = wrapper
        self.constructor = constructor
    }
    
    var body: some View {
        constructor(wrapper.value)
    }
}

final class ReadOnlyPublishedWrapper<Value>: ObservableObject {
    @ReadOnlyPublished var value: Value

    init(published: ReadOnlyPublished<Value>) {
        self._value = published
    }
}
