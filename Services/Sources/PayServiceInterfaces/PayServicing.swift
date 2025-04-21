import DomainModels

public protocol PayServicing: AnyObject {
    var grossDataForPeriod: GrossSalary { get set }
    func updatePeriod(with: Period)
}
