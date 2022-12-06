import Connect
import SwiftUI

private enum MessagingConnectionType: Int, CaseIterable {
    case connectUnary
    case connectStreaming
    case grpcWebUnary
    case grpcWebStreaming
}

extension MessagingConnectionType: Identifiable {
    typealias ID = RawValue

    var id: ID {
        return self.rawValue
    }
}

struct MenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Text("Buf Demo")
                    .font(.title)

                Text("Select a protocol to use for chatting with Eliza, a conversational bot.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])

                List(MessagingConnectionType.allCases) { connectionType in
                    switch connectionType {
                    case .connectUnary:
                        NavigationLink(
                            "Connect (Unary)",
                            destination: LazyNavigationView {
                                MessagingView(
                                    viewModel: UnaryMessagingViewModel(
                                        protocolOption: ConnectClientOption()
                                    )
                                )
                            }
                            .navigationTitle("Eliza Chat (Unary)")
                        )

                    case .connectStreaming:
                        NavigationLink(
                            "Connect (Streaming)",
                            destination: LazyNavigationView {
                                MessagingView(
                                    viewModel: BidirectionalStreamingMessagingViewModel(
                                        protocolOption: ConnectClientOption()
                                    )
                                )
                            }
                            .navigationTitle("Eliza Chat (Streaming)")
                        )

                    case .grpcWebUnary:
                        NavigationLink(
                            "gRPC Web (Unary)",
                            destination: LazyNavigationView {
                                MessagingView(
                                    viewModel: UnaryMessagingViewModel(
                                        protocolOption: GRPCWebClientOption()
                                    )
                                )
                            }
                            .navigationTitle("Eliza Chat (gRPC-W Unary)")
                        )

                    case .grpcWebStreaming:
                        NavigationLink(
                            "gRPC Web (Streaming)",
                            destination: LazyNavigationView {
                                MessagingView(
                                    viewModel: BidirectionalStreamingMessagingViewModel(
                                        protocolOption: GRPCWebClientOption()
                                    )
                                )
                            }
                            .navigationTitle("Eliza Chat (gRPC-W Streaming)")
                        )
                    }
                }
            }
        }
    }
}

/// Workaround wrapper that allows `NavigationLink` destinations to be instantiated only when
/// they are used, rather than all at once when the containing view is instantiated.
private struct LazyNavigationView<Content: View>: View {
    @ViewBuilder private let build: () -> Content

    init(@ViewBuilder _ build: @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        self.build()
    }
}
