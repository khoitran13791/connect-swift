// Code generated by Wire protocol buffer compiler, do not edit.
// Source: grpc.testing.ReconnectInfo in grpc/testing/messages.proto
import Foundation
import Wire

/**
 *  For reconnect interop test only.
 *  Server tells client whether its reconnects are following the spec and the
 *  reconnect backoffs it saw.
 */
public struct ReconnectInfo {

    public var passed: Bool
    public var backoff_ms: [Int32]
    public var unknownFields: Data = .init()

    public init(passed: Bool, backoff_ms: [Int32] = []) {
        self.passed = passed
        self.backoff_ms = backoff_ms
    }

}

#if !WIRE_REMOVE_EQUATABLE
extension ReconnectInfo : Equatable {
}
#endif

#if !WIRE_REMOVE_HASHABLE
extension ReconnectInfo : Hashable {
}
#endif

extension ReconnectInfo : ProtoMessage {
    public static func protoMessageTypeURL() -> String {
        return "type.googleapis.com/grpc.testing.ReconnectInfo"
    }
}

extension ReconnectInfo : Proto3Codable {
    public init(from reader: ProtoReader) throws {
        var passed: Bool? = nil
        var backoff_ms: [Int32] = []

        let token = try reader.beginMessage()
        while let tag = try reader.nextTag(token: token) {
            switch tag {
            case 1: passed = try reader.decode(Bool.self)
            case 2: try reader.decode(into: &backoff_ms)
            default: try reader.readUnknownField(tag: tag)
            }
        }
        self.unknownFields = try reader.endMessage(token: token)

        self.passed = try ReconnectInfo.checkIfMissing(passed, "passed")
        self.backoff_ms = backoff_ms
    }

    public func encode(to writer: ProtoWriter) throws {
        try writer.encode(tag: 1, value: self.passed)
        try writer.encode(tag: 2, value: self.backoff_ms, packed: true)
        try writer.writeUnknownFields(unknownFields)
    }
}

#if !WIRE_REMOVE_CODABLE
extension ReconnectInfo : Codable {
    public enum CodingKeys : String, CodingKey {

        case passed
        case backoff_ms

    }
}
#endif
