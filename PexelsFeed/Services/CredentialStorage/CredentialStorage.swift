import Foundation

protocol CredentialStorageOutput: AnyObject {
    var token: String? { get }
}

protocol CredentialStorageInput {
    func setValues(token: String?)
}

typealias CredentialStorage = CredentialStorageOutput & CredentialStorageInput
