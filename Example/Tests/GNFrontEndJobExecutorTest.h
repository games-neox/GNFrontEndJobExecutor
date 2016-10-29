//
//  GNFrontEndJobExecutorTest.h
//  GNFrontEndJobExecutor
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#ifndef GNFrontEndJobExecutorTest_h
#define GNFrontEndJobExecutorTest_h

#import <XCTest/XCTest.h>

#import <GNFrontEndJobExecutor/GNFrontEndJobExecutor.h>
#import <GNTesting/GNAsyncTaskToken.h>



// TODO: test me!
// TODO: move me to a separate library!
@interface GNAsyncTesting : NSObject

/**
 @pre `stopWaitingToken` is not a `nil` pointer

 @see `executeLockingJobInLogic:(GNFrontEndJobExecutor*) :(GNAsyncTaskToken*) :(void (^)())`
 @see `executeLockingJobInMain:(GNAsyncTaskToken*) :(void (^)())`
 @see `executeLockingJobInBridge:(GNFrontEndJobExecutor*) :(GNAsyncTaskToken*) :(void (^)())`
 */
+ (void)stopWaiting:(GNAsyncTaskToken*)stopWaitingToken;

/**
 Schedules the provided `job` parameter to be executed in the Logic thread. This method returns the control once the
 `job`'s invocation finishes.

 @pre `jobExecutor` is not a `nil` pointer
 @pre `job` is not a `nil` pointer

 @return `NO` in case of a time-out, otherwise - `YES`
 */
+ (BOOL)executeLockingJobInLogic:(GNFrontEndJobExecutor*)jobExecutor :(void (^)())job;

/**
 Schedules the provided `job` parameter to be executed in the Logic thread. This method returns the control once the
 `stopWaiting:(GNAsyncTaskToken*)` method is called with the `stopWaitingToken` provided as an input argument.

 @pre `jobExecutor` is not a `nil` pointer
 @pre `stopWaitingToken` is not a `nil` pointer
 @pre `job` is not a `nil` pointer

 @return `NO` in case of a time-out, otherwise - `YES`
 */
+ (BOOL)executeLockingJobInLogic:(GNFrontEndJobExecutor*)jobExecutor :(GNAsyncTaskToken*)stopWaitingToken
        :(void (^)())job;

/**
 Schedules the provided `job` parameter to be executed in a Bridge thread. This method returns the control once the
 `job`'s invocation finishes or a short time-out occurs.

 @pre `jobExecutor` is not a `nil` pointer
 @pre `job` is not a `nil` pointer

 @return `NO` in case of a time-out, otherwise - `YES`
 */
+ (BOOL)executeLockingJobInBridge:(GNFrontEndJobExecutor*)jobExecutor :(void (^)())job;

/**
 Schedules the provided `job` parameter to be executed in a Bridge thread. This method returns the control once the
 `stopWaiting:(AsyncTaskToken*)` method is called with the `stopWaitingToken` provided as an input argument or a short
 time-out occurs.

 @pre `jobExecutor` is not a `nil` pointer
 @pre `stopWaitingToken` is not a `nil` pointer
 @pre `job` is not a `nil` pointer

 @return `NO` in case of a time-out, otherwise - `YES`
 */
+ (BOOL)executeLockingJobInBridge:(GNFrontEndJobExecutor*)jobExecutor :(GNAsyncTaskToken*)stopWaitingToken
        :(void (^)())job;

/**
 Schedules the provided `job` parameter to be executed in the Main thread. This method returns the control once the
 `stopWaiting:(AsyncTaskToken*)` method is called with the `stopWaitingToken` provided as an input argument or a short
 time-out occurs.

 @pre `stopWaitingToken` is not a `nil` pointer
 @pre `job` is not a `nil` pointer

 @return `NO` in case of a time-out, otherwise - `YES`
 */
+ (BOOL)executeLockingJobInMain:(GNAsyncTaskToken*)stopWaitingToken :(void (^)())job;

/**
 Schedules the provided `job` parameter to be executed in the Main thread. This method returns the control once the
 `job`'s invocation finishes or a short time-out occurs.

 @pre `job` is not a `nil` pointer

 @return `NO` in case of a time-out, otherwise - `YES`
 */
+ (BOOL)executeLockingJobInMain:(void (^)())job;

@end


@interface GNFrontEndJobExecutorTest : XCTestCase
{
@private
    GNFrontEndJobExecutor* jobExecutor_;

    id defaultJobResult_;
    long defaultBigTimeOut_;
    long defaultSmallTimeOut_;
    void (^defaultFatalChainedCallbackBlock_)(id);
    id (^defaultFatalChainedJobBlock_)();
    void (^defaultFatalUnchainedCallbackBlock_)();
    void (^defaultFatalUnchainedJobBlock_)();
}

@end

#endif /* GNFrontEndJobExecutorTest_h */
