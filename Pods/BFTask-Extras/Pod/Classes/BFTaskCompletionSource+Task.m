//
//  BFTaskCompletionSource+Task.m
//  Pods
//
//  Created by Felix Dumit on 3/31/15.
//
//

#import "BFTaskCompletionSource+Task.h"

@implementation BFTaskCompletionSource (Task)

- (void)setResultBasedOnTask:(BFTask *)taskk includingCancel:(BOOL)includeCancel {
    [taskk continueWithBlock: ^id (BFTask *task) {
        if (task.error) {
            [self trySetError:task.error];
        }
        else if (task.exception) {
            [self trySetException:task.exception];
        }
        else if(task.isCancelled){
            if(includeCancel){
                [self trySetCancelled];
            }
        } else {
            [self trySetResult:task.result];
        }
        return task;
    }];
}

- (void)setResultBasedOnTask:(BFTask *)taskk {
    [self setResultBasedOnTask:taskk includingCancel:YES];
}

@end
