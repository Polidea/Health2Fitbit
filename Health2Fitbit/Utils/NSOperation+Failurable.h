#import <Foundation/Foundation.h>

@interface NSOperation (Failurable)

@property (readwrite) BOOL failed;
@end