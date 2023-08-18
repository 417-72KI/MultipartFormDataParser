#if canImport(FoundationNetworking)
import Foundation
import FoundationNetworking

// `URLSession` in `FoundationNetworking` does not support `async`/`await`.
extension URLSession {
    public func data(for request: URLRequest, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = dataTask(with: request) { data, res, err in
                if let err = err {
                    return continuation.resume(throwing: err)
                }
                if let data = data,
                   let res = res {
                    return continuation.resume(returning: (data, res))
                }
            }
            // task.delegate = delegate
            task.resume()
        }
    }

    public func data(from url: URL, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
        try await data(for: URLRequest(url: url), delegate: delegate)
    }

    public func upload(for request: URLRequest, fromFile fileURL: URL, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = uploadTask(with: request, fromFile: fileURL) { data, res, err in
                if let err = err {
                    return continuation.resume(throwing: err)
                }
                if let data = data,
                   let res = res {
                    return continuation.resume(returning: (data, res))
                }
            }
            // task.delegate = delegate
            task.resume()
        }
    }

    public func upload(for request: URLRequest, from bodyData: Data, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = uploadTask(with: request, from: bodyData) { data, res, err in
                if let err = err {
                    return continuation.resume(throwing: err)
                }
                if let data = data,
                   let res = res {
                    return continuation.resume(returning: (data, res))
                }
            }
            // task.delegate = delegate
            task.resume()
        }
    }
}
#endif
