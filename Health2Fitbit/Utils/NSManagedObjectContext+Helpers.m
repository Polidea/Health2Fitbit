#import "NSManagedObjectContext+Helpers.h"
#import "DDLog.h"
#import "H2FLogger.h"
#import "H2FMacros.h"


@implementation NSManagedObjectContext (Helpers)

- (BFTask *)h2f_performBlockAndSave:(NSError *(^)(void))block propagatedSave:(BOOL)propagatedSave {
    BFTaskCompletionSource *performBlockTaskCS = [BFTaskCompletionSource taskCompletionSource];
    [self performBlock:^{

        NSError *blockError = block();
        if (blockError) {
            [performBlockTaskCS setError:blockError];
            return;
        }

        NSError *savingError = nil;

        if (propagatedSave) {
            [self propagatedSave:&savingError];
        } else {
            [self save:&savingError];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (savingError) {
                DDLogError(@"%@: failed to save changes to CoreData: %@", _sfc(self.class), savingError);
                [performBlockTaskCS setError:savingError];
            } else {
                [performBlockTaskCS setResult:nil];
            }
        });
    }];
    return performBlockTaskCS.task;
}

- (BFTask *)h2f_performBlockAndSave:(NSError *(^)(void))block {
    return [self h2f_performBlockAndSave:block propagatedSave:NO];
}

- (void)h2f_performBlockAndWaitAndSave:(NSError *(^)(void))block {
    [self performBlockAndWait:^{
        if (block) {
            block();
        }

        NSError *savingError = nil;
        [self save:&savingError];
        if (savingError) {
            DDLogError(@"%@: failed to save changes to CoreData: %@", _sfc(self.class), savingError);
        }
    }];
}

- (BFTask *)h2f_performBlock:(NSError *(^)(void))block {
    BFTaskCompletionSource *performBlockTaskCS = [BFTaskCompletionSource taskCompletionSource];
    [self performBlock:^{
        NSError *blockError = block();
        if (blockError) {
            [performBlockTaskCS setError:blockError];
        } else {
            [performBlockTaskCS setResult:nil];
        }
    }];
    return performBlockTaskCS.task;
}

- (BOOL)propagatedSave:(NSError **)error {
    if (![self save:error]) {
        return NO;
    }

    __block NSManagedObjectContext *tmp = self.parentContext;

    __block BOOL result = YES;

    while (tmp != nil && result) {
        [tmp performBlockAndWait:^{
            result = [tmp save:error];
            tmp = tmp.parentContext;
        }];
    }
    return result;
}

@end