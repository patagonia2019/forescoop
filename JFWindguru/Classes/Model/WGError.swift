//
//  WGError.swift
//  Pods
//
//  Created by javierfuchs on 7/11/17.
//
//

import Foundation
#if USE_EXT_FWK
import ObjectMapper
#endif
/*
 *  WGError
 *
 *  Discussion:
 *    Model object representing an error in a request in Windguru api.
 *
 * {
 *   "return":"error",
 *   "error_id":2,
 *   "error_message":"Wrong password"
 * }
 */

public class WGError: Mappable {
    var returnString: String?
    var error_id: Int?
    var error_message: String?
    
    public init(code: Int, desc: String, reason: String? = nil, suggestion: String? = nil,
                underError error: NSError? = nil, wgdata : Data? = nil)
    {
        var dict = [String: AnyObject]()
        if let reason = reason {
            dict[NSLocalizedFailureReasonErrorKey] = reason as AnyObject?
        }
        if let suggestion = suggestion {
            dict[NSLocalizedRecoverySuggestionErrorKey] = suggestion as AnyObject?
        }
        if let error = error {
            dict[NSUnderlyingErrorKey] = error
        }
        
        var descValue = desc
        if let wgdata = wgdata,
            let jsonString = String(data: wgdata, encoding: .utf8)
        {
#if USE_EXT_FWK
            if let wgerror = Mapper<WGError>().map(JSONString: jsonString)
            {
                descValue += ". "
                descValue += wgerror.description
            }
            else {
                descValue += " Response IS " + jsonString
            }
#else
            descValue += " Response IS " + jsonString
#endif
        }
        else {
            descValue += " Response EMPTY"
        }
        dict[NSLocalizedDescriptionKey] = descValue as AnyObject?
        
        var id = "JFWindguru"
        if let bundleId = Bundle.main.bundleIdentifier {
            id = bundleId
        }
        nserror = NSError(domain: id, code:code, userInfo: dict)
        
    }
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        #if USE_EXT_FWK
            returnString <- map["return"]
            error_id <- map["error_id"]
            error_message <- map["error_message"]
        #else
            returnString = map["return"] as? String
            error_id = map["error_id"] as? Int
            error_message = map["error_message"] as? String
        #endif
    }
    
    
    public var description : String {
        var aux : String = ""
        if let returnString = returnString {
            aux += "\(returnString): "
        }
        if let error_id = error_id {
            aux += "# \(error_id), "
        }
        if let error_message = error_message {
            aux += "\(error_message)."
        }
        if let nserror = nserror {
            aux += "code=\(nserror.code). "
            aux += "\(nserror.localizedDescription)\n"
        }
        aux += "Please contact us claiming this error."
        return aux
    }
    

    public var nserror: NSError?
    
}

extension WGError : Error {
    
    public func title() -> String {
        if let e = nserror {
            return e.localizedDescription
        }
        return "No Title"
    }
    
    public func reason() -> String {
        if let e = nserror,
            let reason = e.localizedFailureReason {
            return reason
        }
        return "No Reason"
    }
    
    public func asDictionary() -> [String : AnyObject]? {
        if let error = nserror {
            return ["code": error.code as AnyObject,
                    NSLocalizedDescriptionKey: error.localizedDescription as AnyObject,
                    NSLocalizedFailureReasonErrorKey: (error.localizedFailureReason ?? "") as AnyObject,
                    NSLocalizedRecoverySuggestionErrorKey: (error.localizedRecoverySuggestion ?? "") as AnyObject,
                    NSUnderlyingErrorKey: "\(error.userInfo)" as AnyObject]
        }
        return nil
    }
        
    public var debugDescription : String {
        var aux : String = "\(type(of:self)): "
        aux += "["
        if let _error = nserror {
            aux += "\(_error.code);"
            aux += "\(_error.localizedDescription);"
            if let _failureReason = _error.localizedFailureReason {
                aux += "\(_failureReason);"
            } else { aux += "();" }
            if let _recoverySuggestion = _error.localizedRecoverySuggestion {
                aux += "\(_recoverySuggestion);"
            } else { aux += "();" }
            aux += "\(_error.userInfo.description);"
        }
        aux += "]"
        return aux
    }
    
    
    public func fatal() {
        fatalError("fatal:\(self.debugDescription)")
    }
    
}

