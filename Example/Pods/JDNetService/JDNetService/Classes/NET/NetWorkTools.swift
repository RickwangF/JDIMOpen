//
//  NetWorkTool.swift
//  Base
//
//  Created by 张森 on 2019/7/15.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation
import Alamofire

@objc public enum ResponseEncoding: Int {
    case JSON = 1, Data
}

@objcMembers class NetWorkingTool: NSObject {
    
    public private(set) var responseObject: DataResponse<Any>? = nil
    public private(set) var responseData: DefaultDataResponse? = nil
    
    private var complete: ((_ responseData: Any?) -> Void)? = nil
    private var success: ((_ responseObject: Any?) -> Void)? = nil
    private var fail: ((_ error: NSError?) -> Void)? = nil
    
    private static let `default`: SessionManager = Alamofire.SessionManager.default
    
    /// defaultHTTPHeaders
    private static let defaultHTTPHeaders: HTTPHeaders = {
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")
        
        // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
        // Example: `iOS Example/1.0 (org.alamofire.iOS-Example; build:1; iOS 10.0.0) Alamofire/4.0.0`
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
                
                let osName: String = {
                    #if os(iOS)
                    return "iOS"
                    #elseif os(watchOS)
                    return "watchOS"
                    #elseif os(tvOS)
                    return "tvOS"
                    #elseif os(macOS)
                    return "OS X"
                    #elseif os(Linux)
                    return "Linux"
                    #else
                    return "Unknown"
                    #endif
                }()
                
                let osNameVersion: String = {
                    let version = ProcessInfo.processInfo.operatingSystemVersion
                    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                    return "\(osName) \(versionString)"
                }()
                
                let alamofireVersion: String = {
                    guard
                        let afInfo = Bundle(for: SessionManager.self).infoDictionary,
                        let build = afInfo["CFBundleShortVersionString"]
                        else { return "Unknown" }
                    
                    return "Alamofire/\(build)"
                }()
                
                return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osName); \(osNameVersion)) \(alamofireVersion)"
            }
            
            return "Alamofire"
        }()
        
        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent"     : userAgent
        ]
    }()
    
    
    /// contentType
    private static let contentType: Set<String> = {
        
        return ["application/json",
                "text/json",
                "text/javascript",
                "text/html",
                "text/plain",
                "application/atom+xml",
                "application/xml",
                "text/xml",
                "image/png",
                "image/jpeg"]
    }()
    
    
    /// 公共的请求方法
    class public func request(_ base: String,
                              url: String,
                              parameters: Parameters? = nil,
                              timeOut: TimeInterval = 10,
                              method: HTTPMethod = .get,
                              encoding: ParameterEncoding = URLEncoding.default,
                              response: ResponseEncoding = .JSON,
                              headers: HTTPHeaders? = nil,
                              complete: ((Any?, Data?, NSError?) -> Void)? = nil) {
        
        var httpHeaders = self.defaultHTTPHeaders
        
        if let tempHeaders = headers {
            for (key, value) in tempHeaders {
                httpHeaders[key] = value
            }
        }
        
        self.default.session.configuration.timeoutIntervalForRequest = timeOut
        
        let path = base + url
        
        let request: DataRequest = self.default.request(path,
                                                        method: method,
                                                        parameters: parameters,
                                                        encoding: encoding,
                                                        headers: httpHeaders)
            .validate(contentType: self.contentType)
        
        switch response {
        case .JSON:
            request.responseJSON { (responseObject) in
                
                switch responseObject.result {
                case .success(let value) where complete != nil:
                    complete!(value, nil, nil)
                case .failure(let error) where complete != nil:
                    complete!(nil, nil, error as NSError)
                    print(error)
                default : break
                }
            }
        case .Data:
            request.response { (responseObject) in
                
                if complete != nil {
                    complete!(nil, responseObject.data, nil)
                }
            }
        }
    }
    
    
    /// 公共的下载方法
    class public func download(_ path: String,
                               to destination: DownloadRequest.DownloadFileDestination? = DownloadRequest.suggestedDownloadDestination(),
                               progress: ((Double) -> Void)? = nil,
                               complete: ((String?, NSError?) -> Void)? = nil) {
        
        guard let requestUrl: URL = URL.init(string: path) else { return }
        
        
        self.default.download(URLRequest.init(url: (requestUrl)), to: destination)
            .downloadProgress(queue: DispatchQueue.main, closure: { (progressObject) in
                if progress != nil {
                    progress!(progressObject.fractionCompleted)
                }
            })
            .responseData { (response) in
                
                guard complete != nil else { return }

                complete!(response.destinationURL?.path, response.error as NSError?)
        }
    }
}
