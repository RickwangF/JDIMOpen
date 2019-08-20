//
//  JDNetWorkTool.swift
//  Base
//
//  Created by 张森 on 2019/7/15.
//  Copyright © 2019 张森. All rights reserved.
//

import Foundation
import Alamofire
import AdSupport

@objcMembers public class JDNetWorkTool: NSObject {
    
    private class func parameterEncoding(encoding: RequestEncoding) -> ParameterEncoding {
        switch encoding {
        case .URLDefult:
            return URLEncoding.default
        case .URLQueryString:
            return URLEncoding.queryString
        case .HTTPBody:
            return URLEncoding.httpBody
        case .JSONString:
            return JSONEncoding.default
        }
    }
    
    public class func request(_ base: String,
                              url: String,
                              parameters: Parameters?,
                              contentId: Any? = nil,
                              method: HTTPMethod = .get,
                              timeOut: TimeInterval = 10,
                              encoding: RequestEncoding = .URLDefult,
                              response: ResponseEncoding = .JSON,
                              headers: HTTPHeaders? = nil,
                              complete: ((Any?, Data?, NSError?) -> Void)?) {
        
        NetWorkingTool.request(
            base,
            url: url,
            parameters: parameters,
            timeOut: timeOut,
            method: method,
            encoding: self.parameterEncoding(encoding: encoding),
            response: response,
            headers: headers) { (responseObject, responseData, error) in
                
                switch response {
                    
                case .JSON where complete != nil:
                    
                    complete!(responseObject, nil, error)
                    
                case .Data where complete != nil:
                    complete!(nil, responseData, nil)
                    
                default: break
                    
                }
        }
        
    }
    
    
    // MARK: - Public
    @objc public enum RequestEncoding: Int {
        case JSONString = 1, URLDefult = 2, URLQueryString = 3, HTTPBody = 4
    }
    
    
    // MARK: 请求方式
    public class func POST(_ base: String,
                           url: String,
                           parameters: Parameters?,
                           contentId: Any? = nil,
                           timeOut: TimeInterval = 10,
                           encoding: RequestEncoding = .URLDefult,
                           response: ResponseEncoding = .JSON,
                           headers: HTTPHeaders? = nil,
                           complete: ((Any?, Data?, NSError?) -> Void)?) {
        
        self.request(base,
                     url: url,
                     parameters: parameters,
                     method: .post,
                     timeOut: timeOut,
                     encoding: encoding,
                     response: response,
                     headers: headers,
                     complete: complete)
        
    }
    
    
    public class func GET(_ base: String,
                          url: String,
                          parameters: Parameters?,
                          contentId: Any? = nil,
                          timeOut: TimeInterval = 10,
                          encoding: RequestEncoding = .URLDefult,
                          response: ResponseEncoding = .JSON,
                          headers: HTTPHeaders? = nil,
                          complete: ((Any?, Data?, NSError?) -> Void)?) {
        
        self.request(base,
                     url: url,
                     parameters: parameters,
                     method: .get,
                     timeOut: timeOut,
                     encoding: encoding,
                     response: response,
                     headers: headers,
                     complete: complete)
    }
    
    
    public class func PUT(_ base: String,
                          url: String,
                          parameters: Parameters?,
                          contentId: Any? = nil,
                          timeOut: TimeInterval = 10,
                          encoding: RequestEncoding = .URLDefult,
                          response: ResponseEncoding = .JSON,
                          headers: HTTPHeaders? = nil,
                          complete: ((Any?, Data?, NSError?) -> Void)?) {
        
        self.request(base,
                     url: url,
                     parameters: parameters,
                     method: .put,
                     timeOut: timeOut,
                     encoding: encoding,
                     response: response,
                     headers: headers,
                     complete: complete)
    }
    
    
    public class func DELETE(_ base: String,
                             url: String,
                             parameters: Parameters?,
                             timeOut: TimeInterval = 10,
                             contentId: Any? = nil,
                             encoding: RequestEncoding = .URLDefult,
                             response: ResponseEncoding = .JSON,
                             headers: HTTPHeaders? = nil,
                             complete: ((Any?, Data?, NSError?) -> Void)?) {
        
        self.request(base,
                     url: url,
                     parameters: parameters,
                     method: .delete,
                     timeOut: timeOut,
                     encoding: encoding,
                     response: response,
                     headers: headers,
                     complete: complete)
    }
    
    
    public class func Down(_ path: String,
                           progress: ((Double) -> Void)? = nil,
                           complete: ((String?, NSError?) -> Void)? = nil) {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            
            let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            
            let fileURL = cachesURL.appendingPathComponent(response.suggestedFilename ?? "\(Date())" + ".png" )
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        NetWorkingTool.download(path, to: destination, progress: progress, complete: complete)
    }
}
