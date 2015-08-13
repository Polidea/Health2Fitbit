#import <Foundation/Foundation.h>
#import "Bolts/BFTask.h"

@interface BFTask (H2FFailureChecking)
- (BOOL)h2f_hasFailed;
- (BOOL)h2f_hasSucceeded;
- (NSError *)h2f_failureDescriptionError; // takes care of handling 'exception' field of a BFTask
@end
