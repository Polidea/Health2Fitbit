#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AFOAuth1Client;
@class AFOAuth1Client;
@class StepsLog;
@class BFTask;
@class HKHealthStore;


@interface H2FHealthManager : NSObject

@property(nonatomic, strong) HKHealthStore *healthStore;
@property(nonatomic, strong) AFOAuth1Client *apiClient;

@property(nonatomic, strong) BFTask *processStepsFromLastWeekTask;

- (BFTask *)loginToFitbitWithForcedLogin:(BOOL)forcedLogin;

- (BOOL)loggedIn;

- (void)clearFitbitCredentials;

- (NSDate *)lastSyncDate;

- (BFTask *)processStepsFromLastWeek;
@end