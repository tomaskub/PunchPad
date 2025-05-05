import Settings
import Onboarding
import Home
import History
import Statistics

public protocol NavigationViewFactoryProducer {
    func create() -> NavigationViewFactory
}

public typealias NavigationViewFactory =
SettingsViewModelFactory
& OnboardingViewModelFactory
& HomeViewModelFactory
& HistoryViewModelFactory
& StatisticsViewModelFactory
& TabViewFactoryProducer

extension Composition: NavigationViewFactoryProducer {
    public func create() -> NavigationViewFactory {
        self
    }
}
