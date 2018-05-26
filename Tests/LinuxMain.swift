import XCTest

@testable import YubatakeTests

let tests: [XCTestCaseEntry] = [
    testCase(APIFileControllerTests.allTests),
    testCase(APIImageControllerTests.allTests),
    testCase(APIThemeControllerTests.allTests),
    testCase(ImageRepositoryTests.allTests),
    testCase(RoutingSecureGuardTests.allTests),
    testCase(ValidationTests.allTests),
    testCase(AdminCategoryControllerTests.allTests),
    testCase(AdminImageControllerTests.allTests),
    testCase(AdminPostControllerTests.allTests),
    testCase(AdminSiteInfoControllerTests.allTests),
    testCase(AdminTagControllerTests.allTests),
    testCase(AdminThemeControllerTests.allTests),
    testCase(AdminUserControllerTests.allTests),
    testCase(LoginControllerTests.allTests),
    testCase(PublicFileMiddlewareTests.allTests),
    testCase(PostControllerTests.allTests),
    testCase(APIFileControllerCSRFTests.allTests),
    testCase(APIThemeControllerCSRFTests.allTests),
    testCase(AdminCategoryControllerCSRFTests.allTests),
    testCase(AdminPostControllerCSRFTests.allTests),
    testCase(AdminSiteInfoControllerCSRFTests.allTests),
    testCase(AdminTagControllerCSRFTests.allTests),
    testCase(AdminUserControllerCSRFTests.allTests),
    testCase(LoginControllerCSRFTests.allTests),
    testCase(AdminCategoryControllerMessageTests.allTests),
    testCase(AdminPostControllerMessageTests.allTests),
    testCase(AdminSiteInfoControllerMessageTests.allTests),
    testCase(AdminTagControllerMessageTests.allTests),
    testCase(AdminUserControllerMessageTests.allTests)
]

XCTMain(tests)
