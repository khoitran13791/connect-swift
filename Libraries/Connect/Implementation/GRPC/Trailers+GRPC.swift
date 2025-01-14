// Copyright 2022-2023 Buf Technologies, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

extension Trailers {
    /// Identifies the status code from gRPC and gRPC-Web trailers.
    ///
    /// - returns: The gRPC status code, if specified.
    public func grpcStatus() -> Code? {
        return self[HeaderConstants.grpcStatus]?
            .first
            .flatMap(Int.init)
            .flatMap { Code(rawValue: $0) }
    }
}
