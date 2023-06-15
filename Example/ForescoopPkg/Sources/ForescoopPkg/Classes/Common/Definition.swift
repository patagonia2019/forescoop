//
//  Definition.swift
//  Forescoop
//
//  Created by javierfuchs on 10/1/17.
//
//

import Foundation

public struct Constants {
    public static let plist = "ForecastWindguruService"
    public static let frameworkBundle = "Forescoop"
    public static let bundleResource = "Forescoop"
}

public class Definition {

    public init() {}

    public var conversionDict: [String: Double?]? {
        guard let info = info else {
            return nil
        }
        return info["conversion"] as? [String: Double?]
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
    
    public func json(jsonFile: String) -> [String: Any]? {
        guard let path = fwkBundle?.path(forResource: jsonFile, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }

    private lazy var info: [String : AnyObject]? = {
        guard let bundle = self.fwkBundle,
            let path = bundle.path(forResource: Constants.plist, ofType: "plist"),
            let dict = NSDictionary.init(contentsOfFile: path) as? [String: AnyObject] else {
                return nil
        }
        return dict
    }()
}

private extension Definition {

    var bundleFromFramework: Bundle? {
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
    
    var fwkBundle: Bundle? {
        guard let bundle = bundleFromFramework else {
            assert(false, "Check if \(Constants.frameworkBundle) is framework available in bundle:\(Constants.bundleResource)")
            return nil
        }
        return bundle
    }
}
