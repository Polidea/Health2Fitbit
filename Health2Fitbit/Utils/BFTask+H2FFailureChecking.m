#import "BFTask+H2FFailureChecking.h"

@implementation BFTask (H2FFailureChecking)

- (BOOL)h2f_hasFailed {
    return self.error || self.exception;
}

- (BOOL)h2f_hasSucceeded {
    return ![self h2f_hasFailed];
}

- (NSError *)h2f_failureDescriptionError {
    if ([self h2f_hasSucceeded]) {
        return nil;
    }
    if (self.error) {
        return self.error;
    }
    if (self.exception) {
        NSString *devErrorMsg = [NSString stringWithFormat:@"Exception occured: %@", self.exception];
        return [NSError errorWithDomain:devErrorMsg code:-1 userInfo:nil];
    }
    NSAssert(NO, @"Internal inconsistency.");
    return nil;
}

@end
