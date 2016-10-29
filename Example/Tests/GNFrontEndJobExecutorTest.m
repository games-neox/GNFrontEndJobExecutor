//
//  GNFrontEndJobExecutorTest.m
//  GNFrontEndJobExecutor
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import "GNFrontEndJobExecutorTest.h"

#import <GNLog/GNLog.h>
#import <GNPreconditions/GNPreconditions.h>
#import <GNThreadPool/GNThreadPool.h>



static const long GNASYNC_TESTING_SHORT_TIMEOUT = 5000l;

static const NSString* const LOG_TAG = @"AsyncTesting";


@interface GNAsyncTesting ()

+ (GNThreadPool*)getThreadPool:(GNFrontEndJobExecutor*)jobExecutor forName:(NSString*)threadPoolName;

+ (BOOL)executeLockingJob:(GNAsyncTaskToken*)stopWaitingToken :(void (^)())jobInvocator :(long)timeOut;

+ (BOOL)executeLockingJobInQueue:(dispatch_queue_t)queue :(GNAsyncTaskToken*)stopWaitingToken :(void (^)())job
        :(long)timeOut;

+ (BOOL)executeLockingJobInThreadPool:(GNThreadPool*)threadPool :(GNAsyncTaskToken*)stopWaitingToken :(void (^)())job
        :(long)timeOut;

@end


@implementation GNAsyncTesting

+ (void)stopWaiting:(GNAsyncTaskToken*)stopWaitingToken
{
    [GNPreconditions checkNotNil:stopWaitingToken :@"stopWaitingToken!"];

    LOG_PRINT_VERBOSE(LOG_TAG, @"stopWaiting(%@): Enter", stopWaitingToken);

    [stopWaitingToken unlock];

    LOG_PRINT_VERBOSE(LOG_TAG, @"stopWaiting(%@): Exit", stopWaitingToken);
}


+ (BOOL)executeLockingJobInLogic:(GNFrontEndJobExecutor*)jobExecutor :(void (^)())job
{
    [GNPreconditions checkNotNil:jobExecutor :@"jobExecutor!"];
    [GNPreconditions checkNotNil:job :@"job!"];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInLogic(%@,%@): Enter", jobExecutor, job);

    __block GNAsyncTaskToken* jobExecutedToken = [GNAsyncTaskToken createNew];
    const BOOL returnValue = [self executeLockingJobInLogic:jobExecutor :jobExecutedToken : ^{
        job();

        [self stopWaiting:jobExecutedToken];
    }];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInLogic(%@,%@): Exit(%d)", jobExecutor, job, returnValue);

    return returnValue;
}


+ (BOOL)executeLockingJobInLogic:(GNFrontEndJobExecutor*)jobExecutor :(GNAsyncTaskToken*)stopWaitingToken
        :(void (^)())job
{
    [GNPreconditions checkNotNil:jobExecutor :@"jobExecutor!"];
    [GNPreconditions checkNotNil:stopWaitingToken :@"stopWaitingToken!"];
    [GNPreconditions checkNotNil:job :@"job!"];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInLogic(%@,%@,%@): Enter", jobExecutor, stopWaitingToken, job);

    const BOOL returnValue =
            [self executeLockingJobInThreadPool:[self getThreadPool:jobExecutor forName:@"logicThreadPool_"]
                    :stopWaitingToken :job :GNASYNC_TESTING_SHORT_TIMEOUT];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInLogic(%@,%@,%@): Exit(%d)", jobExecutor, stopWaitingToken, job,
            returnValue);

    return returnValue;
}


+ (BOOL)executeLockingJobInBridge:(GNFrontEndJobExecutor*)jobExecutor :(void (^)())job
{
    [GNPreconditions checkNotNil:jobExecutor :@"jobExecutor!"];
    [GNPreconditions checkNotNil:job :@"job!"];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInBridge(%@,%@): Enter", jobExecutor, job);

    __block GNAsyncTaskToken* jobExecutedToken = [GNAsyncTaskToken createNew];
    const BOOL returnValue = [self executeLockingJobInBridge:jobExecutor :jobExecutedToken : ^{
        job();

        [self stopWaiting:jobExecutedToken];
    }];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInBridge(%@,%@): Exit(%d)", jobExecutor, job, returnValue);

    return returnValue;
}


+ (BOOL)executeLockingJobInBridge:(GNFrontEndJobExecutor*)jobExecutor :(GNAsyncTaskToken*)stopWaitingToken
        :(void (^)())job
{
    [GNPreconditions checkNotNil:jobExecutor :@"jobExecutor!"];
    [GNPreconditions checkNotNil:stopWaitingToken :@"stopWaitingToken!"];
    [GNPreconditions checkNotNil:job :@"job!"];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInBridge(%@,%@,%@): Enter", jobExecutor, stopWaitingToken, job);

    const BOOL returnValue =
            [self executeLockingJobInThreadPool:[self getThreadPool:jobExecutor forName:@"bridgeThreadPool_"]
                    :stopWaitingToken :job :GNASYNC_TESTING_SHORT_TIMEOUT];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInBridge(%@,%@,%@): Exit(%d)", jobExecutor, stopWaitingToken, job,
            returnValue);

    return returnValue;
}


+ (BOOL)executeLockingJobInMain:(void (^)())job
{
    [GNPreconditions checkNotNil:job :@"job!"];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInMain(%@): Enter", job);

    __block GNAsyncTaskToken* jobExecutedToken = [GNAsyncTaskToken createNew];
    const BOOL returnValue = [self executeLockingJobInMain:jobExecutedToken : ^{
        job();

        [self stopWaiting:jobExecutedToken];
    }];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInMain(%@): Exit(%d)", job, returnValue);

    return returnValue;
}


+ (BOOL)executeLockingJobInMain:(GNAsyncTaskToken*)stopWaitingToken :(void (^)())job
{
    [GNPreconditions checkNotNil:stopWaitingToken :@"stopWaitingToken!"];
    [GNPreconditions checkNotNil:job :@"job!"];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInMain(%@,%@): Enter", stopWaitingToken, job);

    const BOOL returnValue = [self executeLockingJobInQueue:dispatch_get_main_queue() :stopWaitingToken :job
            :GNASYNC_TESTING_SHORT_TIMEOUT];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInMain(%@,%@): Exit(%d)", stopWaitingToken, job, returnValue);

    return returnValue;
}


+ (GNThreadPool*)getThreadPool:(GNFrontEndJobExecutor*)jobExecutor forName:(NSString*)threadPoolName
{
    return [(NSObject*) jobExecutor valueForKey:threadPoolName];
}


+ (BOOL)executeLockingJob:(GNAsyncTaskToken*)stopWaitingToken :(void (^)())jobInvocator :(long)timeOut
{
    jobInvocator();

    return [stopWaitingToken lock:(NSTimeInterval) (timeOut / 1000.f)];
}


+ (BOOL)executeLockingJobInQueue:(dispatch_queue_t)queue :(GNAsyncTaskToken*)stopWaitingToken :(void (^)())job
        :(long)timeOut
{
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInQueue(%@,%@,%@,%ld): Enter", queue, stopWaitingToken, job, timeOut);

    const BOOL lockResult = [self executeLockingJob:stopWaitingToken :^{
        dispatch_async(queue, ^{
            LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInQueue(%@,%@,%@,%ld): executing Job...", queue,
                    stopWaitingToken, job, timeOut);

            job();

            LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInQueue(%@,%@,%@,%ld): ...job executed", queue,
                    stopWaitingToken, job, timeOut);
        });
    } :timeOut];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInQueue(%@,%@,%@,%ld): Exit(%d)", queue, stopWaitingToken, job,
            timeOut, lockResult);

    return lockResult;
}


+ (BOOL)executeLockingJobInThreadPool:(GNThreadPool*)threadPool :(GNAsyncTaskToken*)stopWaitingToken :(void (^)())job
        :(long)timeOut
{
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInThreadPool(%@,%@,%@,%ld): Enter", threadPool, stopWaitingToken, job,
            timeOut);

    const BOOL lockResult = [self executeLockingJob:stopWaitingToken :^{
        [threadPool enqueue:^{
            LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInThreadPool(%@,%@,%@,%ld): executing job...", threadPool,
                    stopWaitingToken, job, timeOut);

            job();

            LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInThreadPool(%@,%@,%@,%ld): ...job executed", threadPool,
                    stopWaitingToken, job, timeOut);
        }];
    } :timeOut];
    
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingJobInThreadPool(%@,%@,%@,%ld): Exit(%d)", threadPool, stopWaitingToken,
            job, timeOut, lockResult);
    
    return lockResult;
}

@end


@implementation GNFrontEndJobExecutorTest

- (void)setUp
{
    [super setUp];

    defaultJobResult_ = [[NSObject alloc] init];

    defaultBigTimeOut_ = 10l;
    defaultSmallTimeOut_ = 1l;

    __weak GNFrontEndJobExecutorTest* weakSelf = self;
    defaultFatalChainedCallbackBlock_ = ^(id JobResult) {
        GNFrontEndJobExecutorTest* self = weakSelf;
        if (nil != weakSelf) {
            XCTFail(@"defaultFatalChainedCallbackBlock_!");
        }
    };
    defaultFatalChainedJobBlock_ = ^{
        GNFrontEndJobExecutorTest* self = weakSelf;
        if (nil != weakSelf) {
            XCTFail(@"defaultFatalChainedJobBlock_!");
        }
        return (id) nil;
    };
    defaultFatalUnchainedCallbackBlock_ = ^{
        GNFrontEndJobExecutorTest* self = weakSelf;
        if (nil != self) {
            XCTFail(@"defaultFatalUnchainedCallbackBlock_!");
        }
    };
    defaultFatalUnchainedJobBlock_ = ^{
        GNFrontEndJobExecutorTest* self = weakSelf;
        if (nil != self) {
            XCTFail(@"defaultFatalUnchainedJobBlock_!");
        }
    };

    jobExecutor_ = [[GNFrontEndJobExecutor alloc] initWithIdGenerator:[[GNIdGenerator alloc] init]];
}


- (void)tearDown
{
    [jobExecutor_ clear];

    defaultFatalChainedCallbackBlock_ = nil;
    defaultFatalChainedJobBlock_ = nil;
    defaultFatalUnchainedCallbackBlock_ = nil;
    defaultFatalUnchainedJobBlock_ = nil;

    jobExecutor_ = nil;

    defaultJobResult_ = nil;

    [super tearDown];
}

@end
