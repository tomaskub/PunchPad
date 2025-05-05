import Home
import History

public protocol TabViewFactoryProducer {
    func create() -> TabViewFactory
}

public protocol EditSheetViewModelFactoryProducer {
    func create() -> EditSheetViewModelFactory
}

public typealias TabViewFactory = EditSheetViewModelFactoryProducer

extension Composition: TabViewFactoryProducer {
    public func create() -> TabViewFactory {
        self
    }
}

extension Composition: TabViewFactory {
    public func create() -> EditSheetViewModelFactory {
        self
    }
}
