//
//  Definition.swift
//  Forescoop
//
//  Created by javierfuchs on 10/1/17.
//
//

import Foundation

public class Definition {
    
    /*
     * Private parts
     */
    
    private struct Constants {
        static let plist = "ForecastWindguruService"
        static let frameworkBundle = "Forescoop"
        static let bundleResource = "Forescoop"
    }
    
    private var bundleFromFramework: Bundle? {
        var fwkBundle : Bundle? = nil
        for bundle in Bundle.allFrameworks {
            if let bundleIdentifier = bundle.bundleIdentifier,
                bundleIdentifier.hasSuffix(Constants.frameworkBundle) == true {
                fwkBundle = bundle
                break
            }
        }
        if let fwkBundle = fwkBundle,
            let innerBundlePath = fwkBundle.path(forResource: Constants.bundleResource, ofType: "bundle")
        {
            return Bundle.init(path: innerBundlePath)
        }
        return Bundle.init(identifier: "org.cocoapods.\(Constants.bundleResource)")
    }
    
    
    private var fwkBundle: Bundle? {
        guard let bundle = bundleFromFramework else {
            assert(false, "Check if \(Constants.frameworkBundle) is framework available in bundle:\(Constants.bundleResource)")
            return nil
        }
        return bundle
    }
    
    private lazy var info: [String : AnyObject]? = {
        guard let bundle = self.fwkBundle,
            let path = bundle.path(forResource: Constants.plist, ofType: "plist"),
            let dict = NSDictionary.init(contentsOfFile: path) as? [String: AnyObject] else {
                return nil
        }
        return dict
    }()
    
    public var conversionDict: [String: Float?]? {
        guard let info = info else {
            return nil
        }
        return info["conversion"] as? [String: Float?]
    }
    
    public var beaufortArray: Array<[String: Any?]>? {
        guard let info = info,
            let bft = info["bft"] as? Array<[String: Any?]> else {
                return nil
        }
        return bft
    }
    
    public var definitionArray: Array<[String: Any?]>? {
        guard let info = info,
            let definition = info["definition"] as? Array<[String: Any?]> else {
                return nil
        }
        return definition
    }
    
    public func info(name: String) -> [String: Any?]? {
        guard let definitionArray = definitionArray else {
            return nil
        }
        for definitionInfo in definitionArray {
            if let definitionDictionary = definitionInfo[name] as? [String: Any?] {
                return definitionDictionary
            }
        }
        return nil
    }
}
