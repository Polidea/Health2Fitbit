#import <Foundation/Foundation.h>

@interface NSException (DefaultExceptions)

+ (NSException *)notImplementedException;

+ (NSException *)abstractMethodNotOverridenException;

+ (NSException *)wrongInitException;

+ (NSException *)exceptionWithDescription:(NSString *)description;
@end