//
//  BFTask+Race.m
//  Pods
//
//  Created by Felix Dumit on 3/31/15.
//
//

#import "BFTaskCompletionSource+Task.h"
#import "BFTask+Race.h"

@implementation BFTask (Race)

+ (BFTask *)raceForTasks:(NSArray *)tasks {
    BFTaskCompletionSource *tsk = [BFTaskCompletionSource taskCompletionSource];
    
    for (BFTask *task in tasks) {
        [tsk setResultBasedOnTask:task includingCancel:NO];
    }
    
    // will be called if all tasks cancelled
    [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        [tsk trySetCancelled];
        return nil;
    }];
    
    
    return tsk.task;
}

@end
