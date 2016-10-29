//
//  GNFrontEndJobExecutor.mm
//  GNFrontEndJobExecutor
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import <GNFrontEndJobExecutor/GNFrontEndJobExecutor.h>

#import <GNExceptions/GNIllegalArgumentException.h>
#import <GNExceptions/GNIllegalStateException.h>
#import <GNLog/GNLog.h>
#import <GNPreconditions/GNPreconditions.h>
#import <GNThreadPool/GNThreadPool.h>

#import <atomic>
#import <libkern/OSAtomic.h>
#import <mutex>
#import <utility>



static std::mutex logicJobThreadMutex_;
static std::mutex bridgeJobThreadMutex_;
static std::condition_variable logicJobThreadCondition_;
static std::condition_variable bridgeJobThreadCondition_;


@interface GNFrontEndJobExecutor ()
{
@private
    GNIdGenerator* idGenerator_;

    GNThreadPool* logicThreadPool_;
    GNThreadPool* bridgeThreadPool_;

    BOOL isStopped_;
}

- (BOOL)isStopped;

- (void)setStopped;

- (void)executeLockingUnchainedJob:(nonnull void (^)())lockingJob inThreadPool:(GNThreadPool* _Nonnull)threadPool
        withMutex:(std::mutex* _Nonnull)threadMutex withCondition:(std::condition_variable* _Nonnull)threadCondition;

@end


static const NSString* const LOG_TAG = @"GNFrontEndJobExecutor";


@implementation GNFrontEndJobExecutor

- (_Nullable instancetype)initWithIdGenerator:(nonnull GNIdGenerator*)idGenerator
{
    self = [super init];
    if (nil != self) {
        idGenerator_ = idGenerator;

        isStopped_ = NO;

        logicThreadPool_ = [[GNThreadPool alloc] initWithThreadsAmount:1 withPriority:GNThreadPriorityHigher];
        [self executeLockingUnchainedJob:^{
            [NSThread currentThread].name = @"logic";
        } inThreadPool:logicThreadPool_ withMutex:&logicJobThreadMutex_ withCondition:&logicJobThreadCondition_];
        bridgeThreadPool_ = [[GNThreadPool alloc] initWithThreadsAmount:1 withPriority:GNThreadPriorityHigher];
        [self executeLockingUnchainedJob:^{
            [NSThread currentThread].name = @"bridge";
        } inThreadPool:bridgeThreadPool_ withMutex:&bridgeJobThreadMutex_ withCondition:&bridgeJobThreadCondition_];
    }

    return self;
}


- (void)executeInMain:(nonnull void (^)())job
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkCondition:[self isInLogic] :[GNIllegalStateException class] :@"isInLogic()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeInMain(_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInMain(%@): Enter(%ld)", job, jobId);

    dispatch_async(dispatch_get_main_queue(), ^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Main(%ld): Enter", jobId);

        job();

        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Main(%ld): Exit", jobId);
    });

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInMain(%ld): Exit", jobId);
}


- (void)executeInMain:(nonnull _Nullable id (^)())job withChainedCallback:(nonnull void (^)(_Nullable id))callback
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkNotNil:callback :@"callback!"];
    [GNPreconditions checkCondition:[self isInLogic] :[GNIllegalStateException class] :@"isInLogic()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeInMain(_,_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInMain(%@)withChainedCallback(%@): Enter(%ld)", job, callback, jobId);

    dispatch_async(dispatch_get_main_queue(), ^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Main(%ld): Enter", jobId);

        const id jobResult = job();
        [logicThreadPool_ enqueue:^{
            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Main's callback in Logic(%ld): Enter", jobId);

            callback(jobResult);

            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Main's callback in Logic(%ld): Exit", jobId);
        }];

        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Main(%ld): Exit", jobId);
    });

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInMain(_)withChainedCallback(%ld): Exit", jobId);
}


- (void)executeInMain:(nonnull void (^)())job withUnchainedCallback:(nonnull void (^)())callback
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkNotNil:callback :@"callback!"];
    [GNPreconditions checkCondition:[self isInLogic] :[GNIllegalStateException class] :@"isInLogic()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeInMain(_,_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInMain(%@)withUnchainedCallback(%@): Enter(%ld)", job, callback, jobId);

    dispatch_async(dispatch_get_main_queue(), ^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Main(%ld): Enter", jobId);

        job();

        [logicThreadPool_ enqueue:^{
            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Main's callback in Logic(%ld): Enter", jobId);

            callback();

            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Main's callback in Logic(%ld): Exit", jobId);
        }];

        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Main(%ld): Exit", jobId);
    });

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInMain(_)withUnchainedCallback(%ld): Exit", jobId);
}


- (void)executeInLogic:(nonnull void (^)())job
{
    [GNPreconditions checkNotNil:job :@"job!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeInLogic(_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInLogic(%@): Enter(%ld)", job, jobId);

    [logicThreadPool_ enqueue:^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Logic(%ld): Enter", jobId);

        job();

        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Logic(%ld): Exit", jobId);
    }];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInLogic(%ld): Exit", jobId);
}


- (void)executeInLogic:(nonnull _Nullable id (^)())job withChainedCallback:(nonnull void (^)(_Nullable id))callback
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkNotNil:callback :@"callback!"];
    [GNPreconditions checkCondition:[self isInMain] :[GNIllegalStateException class] :@"isInMain()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeInLogic(_,_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInLogic(%@)withChainedCallback(%@): Enter(%ld)", job, callback, jobId);

    [logicThreadPool_ enqueue:^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Logic(%ld): Enter", jobId);

        const id jobResult = job();
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Logic's callback in Main(%ld): Enter", jobId);

            callback(jobResult);

            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Logic's callback in Main(%ld): Exit", jobId);
        });

        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Logic(%ld): Exit", jobId);
    }];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInLogic(_,_)withChainedCallback(%ld): Exit", jobId);
}


- (void)executeInLogic:(nonnull void (^)())job withUnchainedCallback:(nonnull void (^)())callback
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkNotNil:callback :@"callback!"];
    [GNPreconditions checkCondition:[self isInMain] :[GNIllegalStateException class] :@"isInMain()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeInLogic(_,_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInLogic(%@)withUnchainedCallback(%@): Enter(%ld)", job, callback, jobId);

    [logicThreadPool_ enqueue:^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Logic(%ld): Enter", jobId);

        job();
        dispatch_async(dispatch_get_main_queue(), ^{
            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Logic's callback in Main(%ld): Enter", jobId);

            callback();

            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Logic's callback in Main(%ld): Exit", jobId);
        });

        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Logic(%ld): Exit", jobId);
    }];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInLogic(_,_)withUnchainedCallback(%ld): Exit", jobId);
}


- (_Nullable id)executeLockingChainedInLogic:(nonnull _Nullable id (^)())job
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkCondition:(![self isInLogic] && ![self isInBridge]) :[GNIllegalStateException class]
            :@"!isInLogic() && !isInBridge() !"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeLockingChainedInLogic(_): job executor stopped, Exit!");
        return nil;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingChainedInLogic(%@): Enter(%ld)", job, jobId);

    __block id jobResult;
    [self executeLockingUnchainedJob:^{
        jobResult = job();
    } inThreadPool:logicThreadPool_ withMutex:&logicJobThreadMutex_ withCondition:&logicJobThreadCondition_];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingChainedInLogic(%ld): Exit(%@)", jobId, jobResult);

    return jobResult;
}


- (void)executeLockingUnchainedInLogic:(nonnull void (^)())job
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkCondition:[self isInMain] :[GNIllegalStateException class] :@"isInMain()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeLockingUnchainedInLogic(_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingUnchainedInLogic(%@): Enter(%ld)", job, jobId);

    [self executeLockingUnchainedJob:^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingUnchainedInLogic(%@): in Logic, Enter(%ld)", job, jobId);

        job();

        LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingUnchainedInLogic(%@): in Logic, Exit(%ld)", job, jobId);
    } inThreadPool:logicThreadPool_ withMutex:&logicJobThreadMutex_ withCondition:&logicJobThreadCondition_];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingUnchainedInLogic(%ld): Exit", jobId);
}


- (void)executeInBridge:(nonnull void (^)())job
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkCondition:[self isInLogic] :[GNIllegalStateException class] :@"isInLogic()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeInLogic(_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInBridge(%@): Enter(%ld)", job, jobId);

    [bridgeThreadPool_ enqueue:^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Bridge(%ld): Enter", jobId);

        job();

        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Bridge(%ld): Exit", jobId);
    }];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInBridge(%ld): Exit", jobId);
}


- (void)executeInBridge:(nonnull _Nullable id (^)())job withChainedCallback:(nonnull void (^)(_Nullable id))callback
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkNotNil:callback :@"callback!"];
    [GNPreconditions checkCondition:[self isInLogic] :[GNIllegalStateException class] :@"isInLogic()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeInBridge(_,_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInBridge(%@)withChainedCallback(%@): Enter(%ld)", job, callback, jobId);

    [bridgeThreadPool_ enqueue:^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Bridge(%ld): Enter", jobId);

        const id jobResult = job();
        [logicThreadPool_ enqueue:^{
            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Bridge's callback in Logic(%ld): Enter", jobId);

            callback(jobResult);

            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Bridge's callback in Logic(%ld): Exit", jobId);
        }];

        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Bridge(%ld): Exit", jobId);
    }];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInBridge(_,_)withChainedCallback(%ld): Exit", jobId);
}


- (void)executeInBridge:(nonnull void (^)())job withUnchainedCallback:(nonnull void (^)())callback
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkNotNil:callback :@"callback!"];
    [GNPreconditions checkCondition:[self isInLogic] :[GNIllegalStateException class] :@"isInLogic()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeInBridge(_,_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInBridge(%@)withUnchainedCallback(%@): Enter(%ld)", job, callback, jobId);

    [bridgeThreadPool_ enqueue:^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Bridge(%ld): Enter", jobId);

        job();
        [logicThreadPool_ enqueue:^{
            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Bridge's callback in Logic(%ld): Enter", jobId);

            callback();

            LOG_PRINT_VERBOSE(LOG_TAG, @"executing Bridge's callback in Logic(%ld): Exit", jobId);
        }];

        LOG_PRINT_VERBOSE(LOG_TAG, @"executing job in Bridge(%ld): Exit", jobId);
    }];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeInBridge(_,_)withUnchainedCallback(%ld): Exit", jobId);
}


- (_Nullable id)executeLockingChainedInBridge:(nonnull _Nullable id (^)())job
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkCondition:[self isInLogic] :[GNIllegalStateException class] :@"isInLogic()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeLockingChainedInBridge(_): job executor stopped, Exit!");
        return nil;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingChainedInBridge(%@): Enter(%ld)", job, jobId);

    __block id jobResult;
    [self executeLockingUnchainedJob:^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingChainedInBridge(%@): in Bridge, Enter(%ld)", job, jobId);

        jobResult = job();

        LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingChainedInBridge(%@): in Bridge, Exit(%ld)", job, jobId);
    } inThreadPool:bridgeThreadPool_ withMutex:&bridgeJobThreadMutex_ withCondition:&bridgeJobThreadCondition_];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingChainedInBridge(%ld): Exit(%@)", jobId, jobResult);

    return jobResult;
}


- (void)executeLockingUnchainedInBridge:(nonnull void (^)())job
{
    [GNPreconditions checkNotNil:job :@"job!"];
    [GNPreconditions checkCondition:[self isInLogic] :[GNIllegalStateException class] :@"isInLogic()!"];

    if ([self isStopped]) {
        LOG_WRITE_DEBUG(LOG_TAG, @"executeLockingUnchainedInBridge(_): job executor stopped, Exit!");
        return;
    }

    const long jobId = [idGenerator_ generateNextId];
    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingUnchainedInBridge(%@): Enter(%ld)", job, jobId);

    [self executeLockingUnchainedJob:^{
        LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingUnchainedInBridge(%@): in Bridge, Enter(%ld)", job, jobId);

        job();

        LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingUnchainedInBridge(%@): in Bridge, Exit(%ld)", job, jobId);
    } inThreadPool:bridgeThreadPool_ withMutex:&bridgeJobThreadMutex_ withCondition:&bridgeJobThreadCondition_];

    LOG_PRINT_VERBOSE(LOG_TAG, @"executeLockingUnchainedInBridge(%ld): Exit", jobId);
}


- (void)clear
{
    [GNPreconditions checkCondition:[self isInMain] :[GNIllegalStateException class] :@"isInMain()!"];

    LOG_WRITE_VERBOSE(LOG_TAG, @"clear(): Enter");

    [self setStopped];

    [self executeLockingUnchainedJob:^{
        LOG_WRITE_VERBOSE(LOG_TAG, @"clear(): last Bridge job executed");
    } inThreadPool:bridgeThreadPool_ withMutex:&bridgeJobThreadMutex_ withCondition:&bridgeJobThreadCondition_];

    [self executeLockingUnchainedJob:^{
        LOG_WRITE_VERBOSE(LOG_TAG, @"clear(): last Logic job executed");
    } inThreadPool:logicThreadPool_ withMutex:&logicJobThreadMutex_ withCondition:&logicJobThreadCondition_];

    LOG_WRITE_VERBOSE(LOG_TAG, @"clear(): Exit");
}


- (BOOL)isInMain
{
    LOG_WRITE_VERBOSE(LOG_TAG, @"isInMain(): Enter");

    const BOOL returnValue = (dispatch_get_main_queue() == [NSOperationQueue currentQueue].underlyingQueue);

    LOG_PRINT_VERBOSE(LOG_TAG, @"isInMain(): Exit(%d)", returnValue);

    return returnValue;
}


- (BOOL)isInLogic
{
    LOG_WRITE_VERBOSE(LOG_TAG, @"isInLogic(): Enter");

    BOOL returnValue = NO;

    NSString* currentThreadName = [NSThread currentThread].name;
    if (nil != currentThreadName) {
        for (NSString* threadName in [logicThreadPool_ getThreadNames]) {
            if ([threadName isEqualToString:currentThreadName]) {
                returnValue = YES;
                break;
            }
        }
    }

    LOG_PRINT_VERBOSE(LOG_TAG, @"isInLogic(): Exit(%d)", returnValue);

    return returnValue;
}


- (BOOL)isInBridge
{
    LOG_WRITE_VERBOSE(LOG_TAG, @"isInBridge(): Enter");

    BOOL returnValue = NO;

    NSString* currentThreadName = [NSThread currentThread].name;
    if (nil != currentThreadName) {
        for (NSString* threadName in [bridgeThreadPool_ getThreadNames]) {
            if ([threadName isEqualToString:currentThreadName]) {
                returnValue = YES;
                break;
            }
        }
    }

    LOG_PRINT_VERBOSE(LOG_TAG, @"isInBridge(): Exit(%d)", returnValue);

    return returnValue;
}


- (BOOL)isStopped
{
    @synchronized (self) {
        LOG_PRINT_VERBOSE(LOG_TAG, @"isStopped(): Enter/Exit(%d)", isStopped_);

        return isStopped_;
    }
}


- (void)setStopped
{
    @synchronized (self) {
        [GNPreconditions checkCondition:(NO == isStopped_) :[GNIllegalStateException class] :@"already stopped!"];
        LOG_WRITE_VERBOSE(LOG_TAG, @"setStopped(): Enter/Exit");

        isStopped_ = YES;
    }
}


- (void)executeLockingUnchainedJob:(nonnull void (^)())lockingJob inThreadPool:(GNThreadPool* _Nonnull)threadPool
        withMutex:(std::mutex* _Nonnull)threadMutex withCondition:(std::condition_variable* _Nonnull)threadCondition
{
    volatile __block uint32_t executed = 0;
    volatile __block uint32_t ready = 0;

    [threadPool enqueue:^{
        std::unique_lock<std::mutex> jobThreadUniqueLock(*threadMutex);
        threadCondition->wait(jobThreadUniqueLock, ^{ return (0 != ready); });

        lockingJob();

        OSAtomicOr32Barrier(1, &executed);

        jobThreadUniqueLock.unlock();
        threadCondition->notify_one();
    }];

    {
        std::lock_guard<std::mutex> jobThreadUniqueLock(*threadMutex);
        OSAtomicOr32Barrier(1, &ready);
    }
    threadCondition->notify_one();
    {
        std::unique_lock<std::mutex> jobThreadUniqueLock(*threadMutex);
        threadCondition->wait(jobThreadUniqueLock, ^{ return (0 != executed); });
    }
}

@end
