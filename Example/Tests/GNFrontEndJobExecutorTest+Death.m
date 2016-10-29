//
//  GNFrontEndJobExecutorTest+Death.m
//  GNFrontEndJobExecutor
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import "GNFrontEndJobExecutorTest.h"

#import <GNExceptions/GNIllegalArgumentException.h>
#import <GNExceptions/GNIllegalStateException.h>
#import <GNExceptions/GNNilPointerException.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"



// TODO: make more thread-check tests
@implementation GNFrontEndJobExecutorTest (Death)

/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteInMain0
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed(
                [jobExecutor_ executeInMain:nil], GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteInMain1
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeInMain:defaultFatalUnchainedJobBlock_], GNIllegalStateException,
            [GNIllegalStateException defaultName]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteInMainWithChainedCallback0
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed(
                [jobExecutor_ executeInMain:nil withChainedCallback:defaultFatalChainedCallbackBlock_],
                GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid (`nil`) callback provided
 */
- (void)testDeathExecuteInMainWithChainedCallback1
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed([jobExecutor_ executeInMain:defaultFatalChainedJobBlock_ withChainedCallback:nil],
                GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteInMainWithChainedCallback2
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeInMain:defaultFatalChainedJobBlock_
            withChainedCallback:defaultFatalChainedCallbackBlock_], GNIllegalStateException,
            [GNIllegalStateException defaultName]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteInMainWithUnchainedCallback0
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed(
                [jobExecutor_ executeInMain:nil withUnchainedCallback:defaultFatalUnchainedCallbackBlock_],
                GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid (`nil`) callback provided
 */
- (void)testDeathExecuteInMainWithUnchainedCallback1
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed(
                [jobExecutor_ executeInMain:defaultFatalUnchainedJobBlock_ withUnchainedCallback:nil],
                GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteInMainWithUnchainedCallback2
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeInMain:defaultFatalUnchainedJobBlock_
            withUnchainedCallback:defaultFatalUnchainedCallbackBlock_], GNIllegalStateException,
            [GNIllegalStateException defaultName]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteInLogic0
{
    XCTAssertThrowsSpecificNamed(
            [jobExecutor_ executeInLogic:nil], GNNilPointerException, [GNNilPointerException defaultName]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteInLogicWithChainedCallback0
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeInLogic:nil withChainedCallback:defaultFatalChainedCallbackBlock_],
            GNNilPointerException, [GNNilPointerException defaultName]);
}


/**
 invalid (`nil`) callback provided
 */
- (void)testDeathExecuteInLogicWithChainedCallback1
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeInLogic:defaultFatalChainedJobBlock_ withChainedCallback:nil],
            GNNilPointerException, [GNNilPointerException defaultName]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteInLogicWithChainedCallback2
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed([jobExecutor_ executeInLogic:defaultFatalChainedJobBlock_
                withChainedCallback:defaultFatalChainedCallbackBlock_], GNIllegalStateException,
                [GNIllegalStateException defaultName]);
    }]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteInLogicWithUnchainedCallback0
{
    XCTAssertThrowsSpecificNamed(
            [jobExecutor_ executeInLogic:nil withUnchainedCallback:defaultFatalUnchainedCallbackBlock_],
            GNNilPointerException, [GNNilPointerException defaultName]);
}


/**
 invalid (`nil`) callback provided
 */
- (void)testDeathExecuteInLogicWithUnchainedCallback1
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeInLogic:defaultFatalUnchainedJobBlock_ withUnchainedCallback:nil],
            GNNilPointerException, [GNNilPointerException defaultName]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteInLogicWithUnchainedCallback2
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed([jobExecutor_ executeInLogic:defaultFatalUnchainedJobBlock_
                withUnchainedCallback:defaultFatalUnchainedCallbackBlock_], GNIllegalStateException,
                [GNIllegalStateException defaultName]);
    }]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteLockingChainedInLogic0
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeLockingChainedInLogic:nil], GNNilPointerException,
            [GNNilPointerException defaultName]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteLockingChainedInLogic1
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed([jobExecutor_ executeLockingChainedInLogic:defaultFatalChainedJobBlock_],
                GNIllegalStateException, [GNIllegalStateException defaultName]);
    }]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteLockingUnchainedInLogic0
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeLockingUnchainedInLogic:nil], GNNilPointerException,
            [GNNilPointerException defaultName]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteLockingUnchainedInLogic1
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed([jobExecutor_ executeLockingUnchainedInLogic:defaultFatalUnchainedJobBlock_],
                GNIllegalStateException, [GNIllegalStateException defaultName]);
    }]);
}


/**
 invalid (nil) job provided
 */
- (void)testDeathExecuteInBridge0
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed(
                [jobExecutor_ executeInBridge:nil], GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteInBridge1
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeInBridge:defaultFatalUnchainedJobBlock_], GNIllegalStateException,
            [GNIllegalStateException defaultName]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteInBridgeWithChainedCallback0
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed(
                [jobExecutor_ executeInBridge:nil withChainedCallback:defaultFatalChainedCallbackBlock_],
                GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid (`nil`) callback provided
 */
- (void)testDeathExecuteInBridgeWithChainedCallback1
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed([jobExecutor_ executeInBridge:defaultFatalChainedJobBlock_ withChainedCallback:nil],
                GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteInBridgeWithChainedCallback2
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeInBridge:defaultFatalChainedJobBlock_
            withChainedCallback:defaultFatalChainedCallbackBlock_], GNIllegalStateException,
            [GNIllegalStateException defaultName]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteInBridgeWithUnchainedCallback0
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed(
                [jobExecutor_ executeInBridge:nil withUnchainedCallback:defaultFatalUnchainedCallbackBlock_],
                GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid (`nil`) callback provided
 */
- (void)testDeathExecuteInBridgeWithUnchainedCallback1
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed(
                [jobExecutor_ executeInBridge:defaultFatalUnchainedJobBlock_ withUnchainedCallback:nil],
                GNNilPointerException, [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteInBridgeWithUnchainedCallback2
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeInBridge:defaultFatalUnchainedJobBlock_
            withUnchainedCallback:defaultFatalUnchainedCallbackBlock_], GNIllegalStateException,
            [GNIllegalStateException defaultName]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteLockingChainedInBridge0
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed([jobExecutor_ executeLockingChainedInBridge:nil], GNNilPointerException,
                [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteLockingChainedInBridge1
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeLockingChainedInBridge:defaultFatalChainedJobBlock_],
            GNIllegalStateException, [GNIllegalStateException defaultName]);
}


/**
 invalid (`nil`) job provided
 */
- (void)testDeathExecuteLockingUnchainedInBridge0
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed([jobExecutor_ executeLockingUnchainedInBridge:nil], GNNilPointerException,
                [GNNilPointerException defaultName]);
    }]);
}


/**
 invalid thread used
 */
- (void)testDeathExecuteLockingUnchainedInBridge1
{
    XCTAssertThrowsSpecificNamed([jobExecutor_ executeLockingUnchainedInBridge:defaultFatalUnchainedJobBlock_],
            GNIllegalStateException, [GNIllegalStateException defaultName]);
}


/**
 invalid thread used
 */
- (void)testDeathClear
{
    XCTAssertTrue([GNAsyncTesting executeLockingJobInLogic:jobExecutor_ :^{
        XCTAssertThrowsSpecificNamed(
                [jobExecutor_ clear], GNIllegalStateException, [GNIllegalStateException defaultName]);
    }]);
}

@end


#pragma clang diagnostic pop
