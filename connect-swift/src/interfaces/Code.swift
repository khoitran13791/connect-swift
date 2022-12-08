/// Indicates a status of an RPC.
/// The zero code in gRPC is OK, which indicates that the operation was a success.
public enum Code: Int, CaseIterable {
    case ok = 0
    case canceled = 1
    case unknown = 2
    case invalidArgument = 3
    case deadlineExceeded = 4
    case notFound = 5
    case alreadyExists = 6
    case permissionDenied = 7
    case resourceExhausted = 8
    case failedPrecondition = 9
    case aborted = 10
    case outOfRange = 11
    case unimplemented = 12
    case internalError = 13
    case unavailable = 14
    case dataLoss = 15
    case unauthenticated = 16

    public var name: String {
        switch self {
        case .ok:
            return "ok"
        case .canceled:
            return "canceled"
        case .unknown:
            return "unknown"
        case .invalidArgument:
            return "invalid_argument"
        case .deadlineExceeded:
            return "timeout_exceeded"
        case .notFound:
            return "not_found"
        case .alreadyExists:
            return "already_exists"
        case .permissionDenied:
            return "permission_denied"
        case .resourceExhausted:
            return "resource_exhausted"
        case .failedPrecondition:
            return "failed_precondition"
        case .aborted:
            return "aborted"
        case .outOfRange:
            return "out_of_range"
        case .unimplemented:
            return "unimplemented"
        case .internalError:
            return "internal_error"
        case .unavailable:
            return "unavailable"
        case .dataLoss:
            return "data_loss"
        case .unauthenticated:
            return "unauthenticated"
        }
    }

    public static func fromHTTPStatus(_ status: Int) -> Self {
        switch status {
        case 200:
            return .ok
        case 400:
            return .invalidArgument
        case 401:
            return .unauthenticated
        case 403:
            return .permissionDenied
        case 404:
            return .notFound
        case 408:
            return .deadlineExceeded
        case 409:
            return .aborted
        case 412:
            return .failedPrecondition
        case 413:
            return .resourceExhausted
        case 415:
            return .internalError
        case 429, 431:
            return .resourceExhausted
        case 502, 503, 504:
            return .unavailable
        default:
            return .unknown
        }
    }

    public static func fromName(_ name: String) -> Self {
        return Self.allCases.first { $0.name == name } ?? .unknown
    }
}