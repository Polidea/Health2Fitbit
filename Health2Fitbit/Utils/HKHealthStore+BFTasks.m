#import "HKHealthStore+BFTasks.h"

@implementation HKHealthStore (BFTasks)
- (BFTask *)h2f_requestAuthorizationToShareTypes:(NSSet *)typesToShare readTypes:(NSSet *)typesToRead {
    BFTaskCompletionSource *performBlockTaskCS = [BFTaskCompletionSource taskCompletionSource];

    [self requestAuthorizationToShareTypes:typesToShare readTypes:typesToRead completion:^(BOOL success, NSError *error) {
        if (success) {
            [performBlockTaskCS setResult:nil];
        } else {
            [performBlockTaskCS setError:error];
        }
    }];

    return performBlockTaskCS.task;
}

@end
