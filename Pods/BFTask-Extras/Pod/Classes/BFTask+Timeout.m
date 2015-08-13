//
//  BFTaskCompletionSource+Expire.m
//  Umwho
//
//  Created by Felix Dumit on 3/29/15.
//  Copyright (c) 2015 Umwho. All rights reserved.
//

#import "BFTask+Result.h"
#import "BFTask+Timeout.h"
#import "BFTaskCompletionSource+Task.h"

@implementation BFTaskCompletionSource (Timeout)

+ (instancetype)taskCompletionSourceWithExpiration:(NSTimeInterval)timeout {
    BFTaskCompletionSource *taskCompletion = [BFTaskCompletionSource taskCompletionSource];
    [[BFTask taskWithDelay:timeout * 1000] continueWithBlock: ^id (BFTask *task) {
        [taskCompletion trySetCancelled];
        return nil;
    }];
    return taskCompletion;
}

@end


@implementation BFTask (Timeout)

- (instancetype)setTimeout:(NSTimeInterval)timeout {
    return [self _continueTaskWithTimeout:timeout];
}

- (BFTask *)_continueTaskWithTimeout:(NSTimeInterval)timeout {
    BFTaskCompletionSource *tsk = [BFTaskCompletionSource taskCompletionSourceWithExpiration:timeout];
    [tsk setResultBasedOnTask:self];
    return tsk.task;
}

@end
