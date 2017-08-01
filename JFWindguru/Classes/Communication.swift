//
//  Communication.swift
//  Pods
//
//  Created by javierfuchs on 7/28/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
    import Alamofire
    import AlamofireObjectMapper
#endif

struct Response {
    /// The server's response to the URL request.
    let response: URLResponse?
    
    /// The data returned by the server.
    let data: Data?
    
    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    var error: Error?
    
    /// Creates a `DataResponse` instance with the specified parameters derived from response serialization.
    ///
    /// - parameter response: The server's response to the URL request.
    /// - parameter data:     The data returned by the server.
    /// - parameter data:     The error returned by the server.
    init(response: URLResponse?,
             data: Data?,
            error: Error?)
    {
        self.response = response
        self.data = data
        self.error = error
    }
}

class Communication {
    class func request(_ url: String, finish: @escaping (_ response: Response?) -> Void) {
#if USE_EXT_FWK
        Alamofire.request(url, method:.get).validate().response {
            (response: DefaultDataResponse) in
            let r = Response(response: response.response, data: response.data, error: response.error)
            finish(r)
        }
#else
        let task = URLSession.shared.dataTask(with: URL.init(string: url)!)
        { (data, response, error) in
            let r = Response(response: response, data: data, error: error)
            finish(r)
        }
        task.resume()
        URLSession.shared.finishTasksAndInvalidate()
#endif
    }
    
}
