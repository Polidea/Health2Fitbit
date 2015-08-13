#import "NSException+DefaultExceptions.h"


@implementation NSException (DefaultExceptions)

+ (NSException *)notImplementedException {
    return [NSException exceptionWithName:@"NotYetImplemented" reason:@"Code lacks implementation" userInfo:nil];
}

+ (NSException *)abstractMethodNotOverridenException{
    return [NSException exceptionWithName:@"NotOverridenException" reason:@"The method must be overriden" userInfo:nil];
}

+ (NSException *)wrongInitException {
    return [NSException exceptionWithName:@"WrongInit" reason:@"Please use a different init" userInfo:nil];
}

+ (NSException *)exceptionWithDescription:(NSString*)description {
    return [NSException exceptionWithName:@"H2F Exception" reason:description userInfo:nil];
}

@end