import Foundation

extension Error {
    func getDescription() -> String? {
        if let httpError = self as? HTTPError {
            return httpError.localizedDescription
        }
        
        return nil
    }
}
