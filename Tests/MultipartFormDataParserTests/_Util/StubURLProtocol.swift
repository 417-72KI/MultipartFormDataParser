import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing

protocol StubResponseProvider {
    static func stub(for request: URLRequest) throws -> (Data?, URLResponse)
}

extension URLSessionConfiguration {
    static func stubbed<S: StubResponseProvider>(for type: S.Type) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol<S>.self]
        return configuration
    }
}

// MARK: -
private final class StubURLProtocol<S: StubResponseProvider>: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let client else { return }
        do {
            let (data, response) = try S.stub(for: request)
            client.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
            if let data {
                client.urlProtocol(self, didLoad: data)
            }
            client.urlProtocolDidFinishLoading(self)
        } catch {
            client.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // no-op
    }
}
