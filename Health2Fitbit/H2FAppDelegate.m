#import "H2FAppDelegate.h"
#import "AFOAuth1Client.h"
#import "H2FHealthManager.h"
#import "UIForLumberjack.h"
#import "CoreDataStack.h"
#import <HealthKit/HealthKit.h>

@interface H2FAppDelegate ()

@end

@implementation H2FAppDelegate

+ (H2FAppDelegate *)sharedInstance {
    return (H2FAppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[UIForLumberjack sharedInstance]];

    self.coreDataStack = [[CoreDataStack alloc] init];

    self.healthManager = [[H2FHealthManager alloc] init];

    [self observeStepCountChanges];
    return YES;
}

- (void)observeStepCountChanges {
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    [self.healthManager.healthStore enableBackgroundDeliveryForType:sampleType frequency:HKUpdateFrequencyHourly withCompletion:^(BOOL success, NSError *error) {
    }];


    HKObserverQuery *query = [[HKObserverQuery alloc] initWithSampleType:sampleType predicate:nil updateHandler:^(HKObserverQuery *query2, HKObserverQueryCompletionHandler completionHandler, NSError * error) {
        if (error) {
            NSLog(@"Steps count observer completion block. Error: %@", error);
        }
        else {
            [self sync];
        }
    }];
    [self.healthManager.healthStore executeQuery:query];
}

- (void)sync {
    DDLogInfo(@"Will refresh from background");

    [[[[self.healthManager loginToFitbitWithForcedLogin:NO] continueWithSuccessBlock:^id(BFTask *_) {
        return [self.healthManager processStepsFromLastWeek];
    }] continueWithSuccessBlock:^id(BFTask *__) {
        DDLogInfo(@"Finished refresh from background");
        return nil;
    }] continueWithBlock:^id(BFTask *syncTask) {
        if ([syncTask h2f_hasFailed]) {
            DDLogError(@"Failed to refresh from background %@", [syncTask h2f_failureDescriptionError].localizedDescription);
            DDLogError(@"More info: %@", [syncTask h2f_failureDescriptionError].userInfo);
        }
        return nil;
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogInfo(@"Recieved push %@", userInfo);
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)URL
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification
                                                                 object:nil
                                                               userInfo:@{kAFApplicationLaunchOptionsURLKey : URL}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];

    return YES;
}

@end
