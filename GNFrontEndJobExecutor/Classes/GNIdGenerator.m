//
//  GNIdGenerator.m
//  GNFrontEndJobExecutor
//
//  Created by Games Neox - 2016
//  Copyright © 2016 Games Neox. All rights reserved.
//

#import <GNFrontEndJobExecutor/GNIdGenerator.h>

#import <limits.h>



@interface GNIdGenerator ()
{
@private
    long lastId_;
}

- (instancetype)init;

@end


@implementation GNIdGenerator

- (instancetype)init
{
    self = [super init];
    if (nil != self) {
        lastId_ = 0l;
    }

    return self;
}


- (long)generateNextId
{
    long returnValue;

    @synchronized (self) {
        if (LONG_MAX == lastId_) {
            lastId_ = 0l;
        }

        returnValue = ++lastId_;
    }

    return returnValue;
}

@end
