#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "Bolts/Bolts.h"

@class BFTask;

@interface HKHealthStore (BFTasks)

- (BFTask *)h2f_requestAuthorizationToShareTypes:(NSSet *)typesToShare readTypes:(NSSet *)typesToRead;

@end