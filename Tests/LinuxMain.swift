import XCTest

@testable import YubatakeTests

let tests: [XCTestCaseEntry] = [
    testCase(APIFileControllerTests.allTests),
    testCase(APIImageControllerTests.allTests),
    testCase(APIThemeControllerTests.allTests),
    testCase(ImageRepositoryTests.allTests),
    testCase(RoutingSecureGuardTests.allTests),
    testCase(AdminCategoryControllerTests.allTests),
    testCase(AdminImageControllerTests.allTests),
    testCase(AdminPostControllerTests.allTests),
    testCase(AdminSiteInfoControllerTests.allTests),
    testCase(AdminTagControllerTests.allTests),
    testCase(AdminThemeControllerTests.allTests),
    testCase(AdminUserControllerTests.allTests),
    testCase(LoginControllerTests.allTests),
    testCase(PublicFileMiddlewareTests.allTests),
    testCase(PostControllerTests.allTests)
]

XCTMain(tests)
