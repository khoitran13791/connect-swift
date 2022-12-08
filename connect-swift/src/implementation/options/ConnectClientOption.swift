import Foundation

/// Enables the client to speak using the Connect protocol:
/// https://connect.build/docs
public struct ConnectClientOption {
    public init() {}
}

extension ConnectClientOption: ProtocolClientOption {
    public func apply(_ config: ProtocolClientConfig) -> ProtocolClientConfig {
        return config.clone(interceptors: [ConnectInterceptor.init] + config.interceptors)
    }
}

/// The Connect protocol is implemented as an interceptor in the request/response chain.
private struct ConnectInterceptor {
    private let config: ProtocolClientConfig

    init(config: ProtocolClientConfig) {
        self.config = config
    }
}

extension ConnectInterceptor: Interceptor {
    func wrapUnary(nextUnary: UnaryFunction) -> UnaryFunction {
        return UnaryFunction(
            requestFunction: { request in
                var headers = request.headers
                headers[HeaderConstants.acceptEncoding] = self.config.acceptCompressionPoolNames()

                let requestBody = request.message ?? Data()
                let finalRequestBody: Data
                if Envelope.shouldCompress(
                    requestBody, compressionMinBytes: self.config.compressionMinBytes
                ), let compressionPool = self.config.requestCompressionPool() {
                    do {
                        headers[HeaderConstants.contentEncoding] = [
                            type(of: compressionPool).name(),
                        ]
                        finalRequestBody = try compressionPool.compress(data: requestBody)
                    } catch {
                        finalRequestBody = requestBody
                    }
                } else {
                    finalRequestBody = requestBody
                }

                return HTTPRequest(
                    target: request.target,
                    contentType: request.contentType,
                    headers: headers,
                    message: finalRequestBody
                )
            },
            responseFunction: { response in
                guard let encoding = response.headers[HeaderConstants.contentEncoding]?.first,
                      let compressionPool = self.config.compressionPools[encoding] else
                {
                    return response
                }

                do {
                    return HTTPResponse(
                        code: response.code,
                        headers: response.headers
                            .filter { $0.key != HeaderConstants.contentEncoding },
                        message: try response.message.map { body in
                            return try compressionPool.decompress(data: body)
                        },
                        // TODO: Handle trailers prefixed with "trailer-":
                        // https://connect.build/docs/protocol
                        trailers: nil,
                        error: response.error
                    )
                } catch {
                    return response
                }
            }
        )
    }

    func wrapStream(nextStream: StreamingFunction) -> StreamingFunction {
        var responseCompressionPool: CompressionPool?
        return StreamingFunction(
            requestFunction: { request in
                var headers = request.headers
                headers[HeaderConstants.connectStreamingContentEncoding] = self.config
                    .compressionName.map { [$0] }
                headers[HeaderConstants.connectStreamingAcceptEncoding] = self.config
                    .acceptCompressionPoolNames()
                return HTTPRequest(
                    target: request.target,
                    contentType: request.contentType,
                    headers: headers,
                    message: request.message
                )
            },
            requestDataFunction: { data in
                return Envelope.packMessage(
                    data,
                    compressionPool: self.config.requestCompressionPool(),
                    compressionMinBytes: self.config.compressionMinBytes
                )
            },
            streamResultFunc: { result in
                switch result {
                case .complete:
                    return result

                case .headers(let headers):
                    responseCompressionPool = headers[
                        HeaderConstants.connectStreamingContentEncoding
                    ]?.first.flatMap { self.config.compressionPools[$0] }
                    return result

                case .message(let data):
                    do {
                        let (headerByte, message) = try Envelope.unpackMessage(
                            data, compressionPool: responseCompressionPool
                        )
                        let isEndStream = 0b00000010 & headerByte != 0
                        if isEndStream {
                            // Expect a valid Connect end stream response, which can simply be {}.
                            // https://connect.build/docs/protocol#error-end-stream
                            let response = try JSONDecoder().decode(
                                ConnectEndStreamResponse.self, from: message
                            )
                            return .complete(error: response.error, trailers: response.metadata)
                        } else {
                            return .message(message)
                        }
                    } catch let error {
                        // TODO: Close the stream here?
                        return .complete(error: error, trailers: nil)
                    }
                }
            }
        )
    }
}