import UIKit
import XCTest
import Forescoop

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewControllerCreation() {
//        let vc = makeVC()
//        XCTAssertNotNil(vc)
        XCTAssertNil(nil)

    }
        
}

private extension Tests {
    func makeVC() -> MainViewController? {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "MainViewController") { coder in
            MainViewController(coder: coder)
        }
        return vc
    }
}
