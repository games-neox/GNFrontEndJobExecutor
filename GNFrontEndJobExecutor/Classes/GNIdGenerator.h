//
//  GNIdGenerator.h
//  GNFrontEndJobExecutor
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#ifndef GNIdGenerator_h
#define GNIdGenerator_h

#import <Foundation/Foundation.h>



/**
 * This API can be called from any thread.
 */
__attribute__((objc_subclassing_restricted))
@interface GNIdGenerator : NSObject

/**
 @return a unique positive identificator
 */
- (long)generateNextId;

@end

#endif /* GNIdGenerator_h */
