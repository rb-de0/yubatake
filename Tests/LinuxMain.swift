import XCTest

@testable import NoteTests

let tests: [XCTestCaseEntry] = [
    testCase(APIFileControllerTests.allTests),
    testCase(APIHtmlControllerTests.allTests),
    testCase(APIImageControllerTests.allTests),
    testCase(UserFileMiddlewareTests.allTests),
    testCase(MigrationTests.allTests),
    testCase(FileRepositoryTests.allTests),
    testCase(RoutingSecureGuardTests.allTests),
    testCase(AdminCategoryControllerTests.allTests),
    testCase(AdminFileControllerTests.allTests),
    testCase(AdminImageControllerTests.allTests),
    testCase(AdminPostControllerTests.allTests),
    testCase(AdminSiteInfoControllerTests.allTests),
    testCase(AdminTagControllerTests.allTests),
    testCase(AdminUserControllerTests.allTests),
    testCase(LoginControllerTests.allTests),
    testCase(PostControllerTests.allTests),
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
    testCase(AdminUserControllerMessageTests.allTests),
    testCase(ValidationTests.allTests)
]

XCTMain(tests)
