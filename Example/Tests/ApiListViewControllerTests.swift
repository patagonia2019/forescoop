//
//  ApiListControllerTests.swift
//  JFWindguru_Tests
//
//  Created by fox on 29/05/2023.
//  Copyright © 2023 Forescoop. All rights reserved.
//

import XCTest
import Forescoop
@testable import Forescoop_Example

final class ApiListControllerTests: XCTestCase {

    private var vc: ApiListViewController? {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "ApiListViewController") { coder in
            return ApiListViewController(coder: coder)
        }
        vc.loadViewIfNeeded()
        return vc
    }
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
        
    func testInfo() {
        XCTAssertNotNil(vc)
        XCTAssertTrue(vc?.isViewLoaded == true)
        XCTAssertNotNil(vc?.tableView)
    }
}
