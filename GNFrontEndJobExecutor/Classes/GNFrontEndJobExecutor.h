//
//  GNFrontEndJobExecutor.h
//  GNFrontEndJobExecutor
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#ifndef GNFrontEndJobExecutor_h
#define GNFrontEndJobExecutor_h

#import <Foundation/Foundation.h>

#import <GNFrontEndJobExecutor/GNIdGenerator.h>



__attribute__((objc_subclassing_restricted))
@interface GNFrontEndJobExecutor : NSObject

- (_Nullable instancetype)initWithIdGenerator:(nonnull GNIdGenerator*)idGenerator;

/**
 @pre `job` is not a `nil` pointer
 @pre this method is being called from the Logic thread

 @param job operation to be executed in the Main thread

 @throws `GNIllegalStateException` if this method is being called from a thread different than the Logic thread
 @throws `GNNilPointerException` if `job` is a `nil` pointer
 */
- (void)executeInMain:(nonnull void (^)())job;

/**
 @pre `job` is not a `nil` pointer
 @pre `callback` is not a `nil` pointer
 @pre this method is being called from the Logic thread

 @param job operation to be executed in the Main thread. Its result will passed to the `callback` parameter.
 @param callback operation to be executed in the Logic thread with result returned by the `job` parameter.

 @throws GNIllegalStateException if this method is being called from a thread different than the Logic thread
 @throws GNNilPointerException if `job` or `callback` is a `nil` pointer
 */
- (void)executeInMain:(nonnull _Nullable id (^)())job withChainedCallback:(nonnull void (^)(_Nullable id))callback;

/**
 @pre `job` is not a `nil` pointer
 @pre `callback` is not a `nil` pointer
 @pre this method is being called from the Logic thread

 @param job operation to be executed in the Main thread.
 @param callback operation be executed in the Logic thread after the `job` parameter finished its execution.

 @throws GNIllegalStateException if this method is being called from a thread different than the Logic thread
 @throws GNNilPointerException if `job` or `callback` is a `nil` pointer
 */
- (void)executeInMain:(nonnull void (^)())job withUnchainedCallback:(nonnull void (^)())callback;

/**
 @pre `job` is not a `nil` pointer

 @param job operation to be executed in the Logic thread.

 @throws GNNilPointerException if `job` is a `nil` pointer
 */
- (void)executeInLogic:(nonnull void (^)())job;

/**
 @pre `job` is not a `nil` pointer
 @pre `callback` is not a `nil` pointer
 @pre this method is being called from the Main thread

 @param job operation to be executed in the Logic thread. Its result will passed to the `callback` parameter.
 @param callback operation be executed in the Main thread with the result returned from the `job` parameter.

 @throws GNIllegalStateException if this method is being called from a thread different than the Main thread
 @throws GNNilPointerException if `job` or `callback` is a `nil` pointer
 */
- (void)executeInLogic:(nonnull _Nullable id (^)())job withChainedCallback:(nonnull void (^)(_Nullable id))callback;

/**
 @pre `job` is not a `nil` pointer
 @pre `callback` is not a `nil` pointer
 @pre this method is being called from the Main thread

 @param job operation to be executed in the Logic thread.
 @param callback operation be executed in the Main thread after the `job` parameter finished its execution.

 @throws GNIllegalStateException if this method is being called from a thread different than the Main thread
 @throws GNNilPointerException if `job` or `callback` is a `nil` pointer
 */
- (void)executeInLogic:(nonnull void (^)())job withUnchainedCallback:(nonnull void (^)())callback;

/**
 @pre `job` is not a `nil` pointer
 @pre this method is not being called from the Logic or Bridge thread

 @param job operation to be executed in the Logic thread. The current thread is being locked until the `job` returns
         synchronously.

 @return result of the `job` execution or `nil` pointer if the job executor has already been stopped

 @throws GNIllegalStateException if this method is being called from the Logic or the Bridge thread
 @throws GNNilPointerException if `job` is a `nil` pointer
 */
- (_Nullable id)executeLockingChainedInLogic:(nonnull _Nullable id (^)())job;

/**
 @pre `job` is not a `nil` pointer
 @pre this method is being called from the Main thread

 @param job operation to be executed in the Logic thread. The current thread is being locked until the `job` execution
         returns synchronously.

 @throws GNIllegalStateException if this method is being called from a thread different than the Main thread
 @throws GNNilPointerException if `job` is a `nil` pointer
 */
- (void)executeLockingUnchainedInLogic:(nonnull void (^)())job;

/**
 @pre `job` is not a `nil` pointer
 @pre this method is being called from the Logic thread

 @param job operation to be executed in the Bridge thread

 @throws GNIllegalStateException if this method is being called from a thread different than the Logic thread
 @throws GNNilPointerException if `job` is a `nil` pointer
 */
- (void)executeInBridge:(nonnull void (^)())job;

/**
 @pre `job` is not a `nil` pointer
 @pre `callback` is not a `nil` pointer
 @pre this method is being called from the Logic thread

 @param job operation to be executed in the Bridge thread. Its result will passed to the `callback` parameter.
 @param callback operation to be executed in the Logic thread with the result returned from the `job` parameter.

 @throws GNIllegalStateException if this method is being called from a thread different than the Logic thread
 @throws GNNilPointerException if `job` or `callback` is a `nil` pointer
 */
- (void)executeInBridge:(nonnull _Nullable id (^)())job withChainedCallback:(nonnull void (^)(_Nullable id))callback;

/**
 @pre `job` is not a `nil` pointer
 @pre `callback` is not a `nil` pointer
 @pre this method is being called from the Logic thread

 @param job operation to be executed in the Bridge thread
 @param callback operation to be executed in the Logic thread after the `job` parameter finished its execution.

 @throws GNIllegalStateException if this method is being called from a thread different than the Logic thread
 @throws GNNilPointerException if `job` or `callback` is a `nil` pointer
 */
- (void)executeInBridge:(nonnull void (^)())job withUnchainedCallback:(nonnull void (^)())callback;

/**
 @pre `job` is not a `nil` pointer
 @pre this method is being called from the Logic thread

 @param job operation to be executed in the Bridge thread. The current thread is being locked until the `job` returns
         synchronously.

 @return result of the `job` execution or `nil` pointer if the job executor has already been stopped

 @throws GNIllegalStateException if this method is being called from a thread different than the Logic thread
 @throws GNNilPointerException if `job` is a `nil` pointer
 */
- (_Nullable id)executeLockingChainedInBridge:(nonnull _Nullable id (^)())job;

/**
 @pre `job` is not a `nil` pointer
 @pre this method is being called from the Logic thread

 @param job operation to be executed in the Bridge thread. The current thread is being locked until the `job` returns
         synchronously.

 @throws GNIllegalStateException if this method is being called from a thread different than the Logic thread
 @throws GNNilPointerException if `job` is a `nil` pointer
 */
- (void)executeLockingUnchainedInBridge:(nonnull void (^)())job;

/**
 @pre this method is being called from Main thread

 Drains the list of queued jobs and stops this executor.
 */
- (void)clear;

/**
 This method can be called from any thread.

 @return `YES` if this call occurs in the Main thread, otherwise - `NO`
 */
- (BOOL)isInMain;

/**
 This method can be called from any thread.

 @return `YES` if this call occurs in the Logic thread, otherwise - `NO`
 */
- (BOOL)isInLogic;

/**
 This method can be called from any thread.

 @return `YES` if this call occurs in the Bridge thread, otherwise - `NO`
 */
- (BOOL)isInBridge;

@end

#endif /* GNFrontEndJobExecutor_h */
