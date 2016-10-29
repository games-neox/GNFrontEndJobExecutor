//
//  GNFrontEndJobExecutorTest+Main.m
//  GNFrontEndJobExecutor
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import "GNFrontEndJobExecutorTest.h"



// TODO: make more thread-check tests
@implementation GNFrontEndJobExecutorTest (Main)

/**
 correct flow
 */
- (void)DISABLED_testExecuteInMain
{
    // TODO: implement me!
}


/**
 correct flow
 */
- (void)DISABLED_testExecuteInMainWithChainedCallback
{
    // TODO: implement me!
}


/**
 correct flow
 */
- (void)DISABLED_testExecuteInMainWithUnchainedCallback
{
    // TODO: implement me!
}


/**
 correct flow
 */
- (void)testExecuteInLogic
{
    __block GNAsyncTaskToken* jobExecutedToken = [GNAsyncTaskToken createNew];

    XCTAssertTrue([GNAsyncTesting executeLockingJobInBridge:jobExecutor_ :jobExecutedToken :^{
        [jobExecutor_ executeInLogic:^{
            XCTAssertTrue([jobExecutor_ isInLogic]);

            [GNAsyncTesting stopWaiting:jobExecutedToken];
        }];
    }]);
}


/**
 correct flow
 */
- (void)DISABLED_testExecuteInLogicWithChainedCallback
{
    // TODO: implement me!
}


/**
 correct flow
 */
- (void)DISABLED_testExecuteInLogicWithUnchainedCallback
{
    // TODO: implement me!
}


/**
 correct flow
 */
- (void)testExecuteLockingChainedInLogic
{
    XCTAssertEqual(defaultJobResult_, [jobExecutor_ executeLockingChainedInLogic:^{
        XCTAssertTrue([jobExecutor_ isInLogic]);

        return defaultJobResult_;
    }]);
}


/**
 correct flow
 */
- (void)testExecuteLockingUnchainedInLogic
{
    __block GNAsyncTaskToken* jobExecutedToken = [GNAsyncTaskToken createNew];

    [jobExecutor_ executeLockingUnchainedInLogic:^{
        XCTAssertTrue([jobExecutor_ isInLogic]);

        [GNAsyncTesting stopWaiting:jobExecutedToken];
    }];
}


/**
 correct flow
 */
- (void)testExecuteInBridge
{
    __block GNAsyncTaskToken* jobExecutedToken = [GNAsyncTaskToken createNew];

    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :jobExecutedToken :^{
        [jobExecutor_ executeInBridge:^{
            XCTAssertTrue([jobExecutor_ isInBridge]);

            [GNAsyncTesting stopWaiting:jobExecutedToken];
        }];
    }]);
}


/**
 correct flow
 */
- (void)testExecuteInBridgeWithChainedCallback
{
    __block GNAsyncTaskToken* jobExecutedToken = [GNAsyncTaskToken createNew];

    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :jobExecutedToken :^{
        [jobExecutor_ executeInBridge:^{
            XCTAssertTrue([jobExecutor_ isInBridge]);

            return defaultJobResult_;
        } withChainedCallback:^(id jobResult) {
            XCTAssertTrue([jobExecutor_ isInLogic]);
            XCTAssertEqual(defaultJobResult_, jobResult);

            [GNAsyncTesting stopWaiting:jobExecutedToken];
        }];
    }]);
}


/**
 correct flow
 */
- (void)testExecuteInBridgeWithUnchainedCallback
{
    __block GNAsyncTaskToken* jobExecutedToken = [GNAsyncTaskToken createNew];

    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :jobExecutedToken :^{
        [jobExecutor_ executeInBridge:^{
            XCTAssertTrue([jobExecutor_ isInBridge]);
        } withUnchainedCallback:^{
            XCTAssertTrue([jobExecutor_ isInLogic]);

            [GNAsyncTesting stopWaiting:jobExecutedToken];
        }];
    }]);
}


/**
 correct flow
 */
- (void)testExecuteLockingChainedInBridge
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertEqual(defaultJobResult_, [jobExecutor_ executeLockingChainedInBridge:^{
            XCTAssertTrue([jobExecutor_ isInBridge]);

            return defaultJobResult_;
        }]);
    }]);
}


/**
 correct flow
 */
- (void)testExecuteLockingUnchainedInBridge
{
    __block GNAsyncTaskToken* jobExecutedToken = [GNAsyncTaskToken createNew];

    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :jobExecutedToken :^{
        [jobExecutor_ executeLockingUnchainedInBridge:^{
            XCTAssertTrue([jobExecutor_ isInBridge]);

            [GNAsyncTesting stopWaiting:jobExecutedToken];
        }];
    }]);
}


/**
 correct flow
 */
- (void)testIsInMain
{
    XCTAssertTrue([jobExecutor_ isInMain]);
    XCTAssertFalse([jobExecutor_ isInLogic]);
    XCTAssertFalse([jobExecutor_ isInBridge]);
}


/**
 correct flow
 */
- (void)testIsInBusiness
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertTrue([jobExecutor_ isInLogic]);
        XCTAssertFalse([jobExecutor_ isInMain]);
        XCTAssertFalse([jobExecutor_ isInBridge]);
    }]);
}


/**
 correct flow
 */
- (void)testIsInBridge
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInBridge:jobExecutor_ :^{
        XCTAssertTrue([jobExecutor_ isInBridge]);
        XCTAssertFalse([jobExecutor_ isInMain]);
        XCTAssertFalse([jobExecutor_ isInLogic]);
    }]);
}

@end
