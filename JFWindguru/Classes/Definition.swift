//
//  Definition.swift
//  Pods
//
//  Created by javierfuchs on 10/1/17.
//
//

import Foundation

public struct Definition {
    
    public mutating func info(name: String) -> [String: Any?]? {
        guard let definitionArray = ForecastWindguruService.instance.definitionArray() else {
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
