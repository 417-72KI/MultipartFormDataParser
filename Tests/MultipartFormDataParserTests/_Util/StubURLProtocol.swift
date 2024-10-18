import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class StubURLProtocol: URLProtocol {
    typealias RequestHandler = (URLRequest) throws -> (Data?, HTTPURLResponse)

    static var requestHandler: RequestHandler?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let requestHandler = Self.requestHandler else { return }
        do {
            let (data, response) = try requestHandler(request)
            client?.urlProtocol(self,
                                didReceive: response,
                                cacheStoragePolicy: .notAllowed)
            if let data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // no-op
    }
}
