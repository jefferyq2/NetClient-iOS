//
//  NetRequest+Build.swift
//  Net
//
//  Created by Alex Rupérez on 25/3/17.
//
//

import Foundation

extension NetRequest {

    public class Builder {

        public private(set) var url: URL

        public private(set) var cache: NetRequest.NetCachePolicy?

        public private(set) var timeout: TimeInterval?

        public private(set) var mainDocumentURL: URL?

        public private(set) var serviceType: NetRequest.NetServiceType?

        public private(set) var contentType: NetContentType?

        public private(set) var accept: NetContentType?

        public private(set) var allowsCellularAccess: Bool?

        public private(set) var method: NetRequest.NetMethod?

        public private(set) var headers: [String : String]?

        public private(set) var body: Data?

        public private(set) var bodyStream: InputStream?

        public private(set) var handleCookies: Bool?

        public private(set) var usePipelining: Bool?

        public private(set) var authorization: NetAuthorization?

        public init(_ netRequest: NetRequest) {
            url = netRequest.url
            cache = netRequest.cache
            timeout = netRequest.timeout
            mainDocumentURL = netRequest.mainDocumentURL
            serviceType = netRequest.serviceType
            contentType = netRequest.contentType
            accept = netRequest.accept
            allowsCellularAccess = netRequest.allowsCellularAccess
            method = netRequest.method
            headers = netRequest.headers
            body = netRequest.body
            bodyStream = netRequest.bodyStream
            handleCookies = netRequest.handleCookies
            usePipelining = netRequest.usePipelining
            authorization = netRequest.authorization
        }

        public convenience init?(_ urlRequest: URLRequest) {
            guard let netRequest = urlRequest.netRequest else {
                return nil
            }
            self.init(netRequest)
        }

        public init(_ url: URL) {
            self.url = url
        }

        public convenience init?(_ urlString: String) {
            guard let url = URL(string: urlString) else {
                return nil
            }
            self.init(url)
        }

        @discardableResult public func setCache(_ cache: NetRequest.NetCachePolicy?) -> Self {
            self.cache = cache
            return self
        }

        @discardableResult public func setTimeout(_ timeout: TimeInterval?) -> Self {
            self.timeout = timeout
            return self
        }

        @discardableResult public func setMainDocumentURL(_ mainDocumentURL: URL?) -> Self {
            self.mainDocumentURL = mainDocumentURL
            return self
        }

        @discardableResult public func setServiceType(_ serviceType: NetRequest.NetServiceType?) -> Self {
            self.serviceType = serviceType
            return self
        }

        @discardableResult public func setContentType(_ contentType: NetContentType?) -> Self {
            self.contentType = contentType
            return self
        }

        @discardableResult public func setAccept(_ accept: NetContentType?) -> Self {
            self.accept = accept
            return self
        }

        @discardableResult public func setAllowsCellularAccess(_ allowsCellularAccess: Bool?) -> Self {
            self.allowsCellularAccess = allowsCellularAccess
            return self
        }

        @discardableResult public func setMethod(_ method: NetRequest.NetMethod?) -> Self {
            self.method = method
            return self
        }

        @discardableResult public func setHeaders(_ headers: [String : String]?) -> Self {
            self.headers = headers
            return self
        }

        @discardableResult public func addHeader(_ key: String, value: String?) -> Self {
            if headers == nil {
                headers = [:]
            }
            headers?[key] = value
            return self
        }

        @discardableResult public func setBody(_ body: Data?) -> Self {
            self.body = body
            return self
        }

        @discardableResult public func setURLParameters(_ urlParameters: [String: Any]?, resolvingAgainstBaseURL: Bool = false) -> Self {
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: resolvingAgainstBaseURL) {
                components.percentEncodedQuery = nil
                if let urlParameters = urlParameters, urlParameters.count > 0 {
                    components.percentEncodedQuery = query(urlParameters)
                }
                if let url = components.url {
                    self.url = url
                }
            }
            return self
        }

        @discardableResult public func addURLParameter(_ key: String, value: Any?, resolvingAgainstBaseURL: Bool = false) -> Self {
            guard let value = value else {
                return self
            }
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: resolvingAgainstBaseURL) {
                let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + query([key: value])
                components.percentEncodedQuery = percentEncodedQuery
                if let url = components.url {
                    self.url = url
                }
            }
            return self
        }

        @discardableResult public func setFormParameters(_ formParameters: [String: Any]?, encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) -> Self {
            guard let formParameters = formParameters else {
                return self
            }
            body = query(formParameters).data(using: encoding, allowLossyConversion: allowLossyConversion)
            if contentType == nil {
                contentType = .formURL
            }
            return self
        }

        @discardableResult public func setStringBody(_ stringBody: String?, encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) -> Self {
            guard let stringBody = stringBody else {
                return self
            }
            body = stringBody.data(using: encoding, allowLossyConversion: allowLossyConversion)
            return self
        }

        @discardableResult public func setJSONBody(_ jsonBody: Any?, options: JSONSerialization.WritingOptions = .prettyPrinted) throws -> Self {
            guard let jsonBody = jsonBody else {
                return self
            }
            body = try JSONSerialization.data(withJSONObject: jsonBody, options: options)
            if contentType == nil {
                contentType = .json
            }
            return self
        }

        @discardableResult public func setPlistBody(_ plistBody: Any?, format: PropertyListSerialization.PropertyListFormat = .xml, options: PropertyListSerialization.WriteOptions = 0) throws -> Self {
            guard let plistBody = plistBody else {
                return self
            }
            body = try PropertyListSerialization.data(fromPropertyList: plistBody, format: format, options: options)
            if contentType == nil {
                contentType = .plist
            }
            return self
        }

        @discardableResult public func setBodyStream(_ bodyStream: InputStream?) -> Self {
            self.bodyStream = bodyStream
            return self
        }

        @discardableResult public func setHandleCookies(_ handleCookies: Bool?) -> Self {
            self.handleCookies = handleCookies
            return self
        }

        @discardableResult public func setUsePipelining(_ usePipelining: Bool?) -> Self {
            self.usePipelining = usePipelining
            return self
        }

        @discardableResult public func setBasicAuthorization(user: String, password: String) -> Self {
            authorization = .basic(user: user, password: password)
            return self
        }

        @discardableResult public func setBearerAuthorization(token: String) -> Self {
            authorization = .bearer(token: token)
            return self
        }

        public func build() -> NetRequest {
            return NetRequest(self)
        }

    }

    public static func builder(_ netRequest: NetRequest) -> Builder {
        return Builder(netRequest)
    }

    public static func builder(_ urlRequest: URLRequest) -> Builder? {
        return Builder(urlRequest)
    }

    public static func builder(_ url: URL) -> Builder {
        return Builder(url)
    }

    public static func builder(_ urlString: String) -> Builder? {
        return Builder(urlString)
    }

    public init(_ builder: Builder) {
        self.init(builder.url, cache: builder.cache ?? .useProtocolCachePolicy, timeout: builder.timeout ?? 60, mainDocumentURL: builder.mainDocumentURL, serviceType: builder.serviceType ?? .default, contentType: builder.contentType, accept: builder.accept, allowsCellularAccess: builder.allowsCellularAccess ?? true, method: builder.method ?? .GET, headers: builder.headers, body: builder.body, bodyStream: builder.bodyStream, handleCookies: builder.handleCookies ?? true, usePipelining: builder.usePipelining ?? true, authorization: builder.authorization ?? .none)
    }

    public func builder() -> Builder {
        return NetRequest.builder(self)
    }

}

extension NetRequest.Builder {

    fileprivate func query(_ parameters: [String: Any]) -> String {
        var components = [(String, String)]()

        for key in parameters.keys.sorted(by: <) {
            if let value = parameters[key] {
                components += queryComponents(key, value: value)
            }
        }

        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    fileprivate func queryComponents(_ key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (dictionaryKey, value) in dictionary {
                components += queryComponents("\(key)[\(dictionaryKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents("\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if CFBooleanGetTypeID() == CFGetTypeID(value) {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    fileprivate func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }

}