import Foundation
import os

// MARK: - Error Types
enum AppError: LocalizedError {
    case network(NetworkError)
    case auth(AuthError)
    case data(DataError)
    case service(ServiceError)
    
    var errorDescription: String? {
        switch self {
        case .network(let error): return error.description
        case .auth(let error): return error.description
        case .data(let error): return error.description
        case .service(let error): return error.description
        }
    }
}

enum NetworkError: Error {
    case timeout
    case noConnection
    case serverError(code: Int, message: String)
    case rateLimitExceeded
    
    var description: String {
        switch self {
        case .timeout: return "Request timed out. Please try again."
        case .noConnection: return "No internet connection."
        case .serverError(_, let message): return "Server error: \(message)"
        case .rateLimitExceeded: return "Too many requests. Please try again later."
        }
    }
}

enum AuthError: Error {
    case invalidCredentials
    case sessionExpired
    case emailNotConfirmed
    case unauthorized
    
    var description: String {
        switch self {
        case .invalidCredentials: return "Invalid email or password"
        case .sessionExpired: return "Session expired. Please sign in again."
        case .emailNotConfirmed: return "Please confirm your email to continue"
        case .unauthorized: return "You're not authorized to perform this action"
        }
    }
}

enum DataError: Error {
    case notFound
    case invalidFormat
    case saveFailed
    
    var description: String {
        switch self {
        case .notFound: return "The requested data could not be found"
        case .invalidFormat: return "Invalid data format"
        case .saveFailed: return "Failed to save data"
        }
    }
}

enum ServiceError: Error {
    case ai(message: String)
    case journal(message: String)
    case unknown(Error)
    
    var description: String {
        switch self {
        case .ai(let message): return "AI service error: \(message)"
        case .journal(let message): return "Journal error: \(message)"
        case .unknown(let error): return "Unexpected error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Error Handler Protocol
@MainActor
protocol ErrorHandling: AnyObject {
    var currentError: AppError? { get set }
    func handle(_ error: Error, file: String, line: Int)
    func clearError()
}

// MARK: - Error Handler Implementation
@MainActor
final class ErrorHandler: ObservableObject, ErrorHandling {
    @Published var currentError: AppError?
    private let logger = Logger(subsystem: "com.justinauri02.Auri-02", category: "ErrorHandler")
    
    init() {}
    
    func handle(_ error: Error, file: String = #file, line: Int = #line) {
        let appError = mapError(error)
        logger.error("Error occurred in \(file):\(line) - \(appError.localizedDescription)")
        currentError = appError
    }
    
    func clearError() {
        currentError = nil
    }
    
    private func mapError(_ error: Error) -> AppError {
        switch error {
        case let error as AppError:
            return error
        case let error as URLError:
            return .network(.serverError(code: error.errorCode, message: error.localizedDescription))
        case let error as AuthError:
            return .auth(error)
        case let error as DataError:
            return .data(error)
        default:
            return .service(.unknown(error))
        }
    }
}

// MARK: - Result Extensions
extension Result where Failure == Error {
    func mapError(_ handler: ErrorHandling) async -> Result<Success, Never> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            await handler.handle(error, file: #file, line: #line)
            return .success(Success.self as! Success) // Only use if Success is Optional
        }
    }
}
