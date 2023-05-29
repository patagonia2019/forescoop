//
//  ViewControllerTests.swift
//  JFWindguru_Tests
//
//  Created by fox on 29/05/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
@testable import JFWindguru_Example

final class ViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitVC() throws {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "ViewController") { coder in
            ViewController(coder: coder)
        }
    }

}
