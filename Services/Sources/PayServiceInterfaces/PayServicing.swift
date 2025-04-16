import DomainModels

protocol PayServicing: AnyObject {
    var grossDataForPeriod: GrossSalary { get set }
    func updatePerios(with: Period)
}
