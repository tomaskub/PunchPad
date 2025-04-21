import DomainModels
import PayServiceInterfaces

class MockPayService: PayServicing {
    var grossDataForPeriod: GrossSalary = .init()
    var updatePeriodCalled = false
    var updatedPeriod = [Period]()
    
    func updatePeriod(with: Period) {
        updatePeriodCalled = true
        updatedPeriod.append(with)
    }
}
