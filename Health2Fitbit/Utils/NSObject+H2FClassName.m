#import "NSObject+H2FClassName.h"

@implementation NSObject (H2FClassName)

+ (NSString *)h2f_className {
    return NSStringFromClass(self);
}

@end
