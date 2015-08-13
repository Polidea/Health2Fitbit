#import <objc/runtime.h>
#import "NSOperation+Failurable.h"

static char const *const FailedTagKey = "failed";


@implementation NSOperation (Failurable)

- (void)setFailed:(BOOL)failed {
    NSNumber *number = @(failed);
    objc_setAssociatedObject(self, FailedTagKey, number, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)failed {
    NSNumber *number = objc_getAssociatedObject(self, FailedTagKey);
    return [number boolValue];
}

@end