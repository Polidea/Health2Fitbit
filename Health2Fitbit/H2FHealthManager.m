#import "H2FHealthManager.h"
#import <HealthKit/HealthKit.h>
#import <AFOAuth1Client/AFOAuth1Client.h>
#import "libextobjc/EXTScope.h"
#import "DDLog.h"
#import "H2FLogger.h"
#import "H2FAppDelegate.h"
#import "CoreDataStack.h"
#import "NSManagedObjectContext+Helpers.h"
#import "NSManagedObjectContext+PLCoreDataUtils.h"
#import "StepsLog.h"
#import "NSObject+H2FClassName.h"
#import "H2FMacros.h"
#import "NSException+DefaultExceptions.h"
#import "AFOAuth1Client+BFTasks.h"
#import "BFTask+H2FFailureChecking.h"
#import "HKHealthStore+BFTasks.h"

NSString *const LastDateIdentifier = @"LastDateIdentifier";
NSString *const TokenKeyChainIdentifier = @"Health2FitTokenKeyChainIdentifier";
NSString *const CallbackURL = @"health2fitbit://success";
NSInteger walkActivityId = 90013;
NSInteger oneHourInSeconds = 60 * 60;
NSInteger oneDayInSeconds = 60 * 60 * 24;
NSInteger lookBackInterval = 7;

@implementation H2FHealthManager
- (id)init {
    self = [super init];
    if (self) {
        self.healthStore = [[HKHealthStore alloc] init];

        NSURL * baseURL = [NSURL URLWithString:@"https://api.fitbit.com/"];
        self.apiClient = [[AFOAuth1Client alloc] initWithBaseURL:baseURL
                                                             key:@"FITBIT_API_KEY"
                                                          secret:@"FITBIT_API_SECRET"];

        [[self loginToFitbitWithForcedLogin:NO] continueWithBlock:^id(BFTask *task) {
            return nil;
        }];
    }

    return self;
}

- (BFTask *)loginToFitbitWithForcedLogin:(BOOL)forcedLogin {
    AFOAuth1Token *token = [AFOAuth1Token retrieveCredentialWithIdentifier:TokenKeyChainIdentifier];

    if (token) {
        self.apiClient.accessToken = token;
        return [BFTask taskWithResult:nil];
    } else if (forcedLogin) {
        return [[[self.apiClient h2f_authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token"
                                                       userAuthorizationPath:@"/oauth/authorize"
                                                                 callbackURL:[NSURL URLWithString:CallbackURL]
                                                             accessTokenPath:@"/oauth/access_token"
                                                                accessMethod:@"POST"
                                                                       scope:nil] continueWithSuccessBlock:^id(BFTask *task) {
            DDLogInfo(@"Successfully logged in");
            AFOAuth1Token *accessToken = task.result;
            [AFOAuth1Token storeCredential:accessToken
                            withIdentifier:TokenKeyChainIdentifier
                         withAccessibility:(__bridge id) kSecAttrAccessibleAlways];
            return nil;
        }] continueWithBlock:^id(BFTask *task) {
            if ([task h2f_hasFailed]) {
                DDLogError(@"failed to login %@", [task h2f_failureDescriptionError].localizedDescription);
            }
            return nil;
        }];
    } else {
        return [BFTask taskWithException:[NSException exceptionWithDescription:@"Not logged in, and forced login not set"]];
    }
}

- (BOOL)loggedIn {
    return self.apiClient.accessToken != nil;
}

- (void)clearFitbitCredentials {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LastDateIdentifier];
    [AFOAuth1Token deleteCredentialWithIdentifier:TokenKeyChainIdentifier];
    self.apiClient.accessToken = nil;
}

- (NSDate *)lastSyncDate {
    NSDate *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:LastDateIdentifier];

    if (!lastSyncDate) {
        int oneDayInSeconds = 60 * 60 * 24;
        lastSyncDate = [NSDate dateWithTimeIntervalSinceNow:-oneDayInSeconds];
    }

    return lastSyncDate;
}

- (BFTask *)processStepsFromLastWeek {
    if (self.processStepsFromLastWeekTask && !self.processStepsFromLastWeekTask.isCompleted) {
        return self.processStepsFromLastWeekTask;
    }


    __block UIBackgroundTaskIdentifier backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"Steps update" expirationHandler:^{
        DDLogError(@"Will expire processing steps operation");
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];

    self.processStepsFromLastWeekTask = [self internalProcessStepsFromLastWeek];

    [self.processStepsFromLastWeekTask continueWithBlock:^id(BFTask *task) {

        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;

        return nil;
    }];

    return self.processStepsFromLastWeekTask;
}

- (BFTask *)internalProcessStepsFromLastWeek {
    NSSet * readObjectTypes = [NSSet setWithArray:@[
            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
    ]];

    NSDate *lastSyncDate = [self lastSyncDate];
    NSDate *currentDate = [NSDate date];

    DDLogInfo(@"Real last sync date: %@", lastSyncDate);

    NSDate *startDate = [lastSyncDate dateByAddingTimeInterval:-lookBackInterval * oneDayInSeconds];
    NSDate *endDate = [currentDate dateByAddingTimeInterval:oneHourInSeconds];

    NSDateComponents *startDateComponenets = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitHour fromDate:startDate];
    startDateComponenets.minute = 0;
    startDateComponenets.hour = 0;
    startDate = [[NSCalendar currentCalendar] dateFromComponents:startDateComponenets];

    NSDateComponents *endDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitHour fromDate:endDate];
    endDateComponents.minute = 0;
    endDate = [[NSCalendar currentCalendar] dateFromComponents:endDateComponents];

    NSDate *syncStartDate = [NSDate date];

    DDLogInfo(@"Sync will take place from %@ to %@", startDate, endDate);
    @weakify(self)
    return [[[[[self healthStore] h2f_requestAuthorizationToShareTypes:nil readTypes:readObjectTypes] continueWithSuccessBlock:^id(BFTask *_) {
        @strongify(self)
        DDLogInfo(@"Recieved healthkit access");
        return [[[self downloadAndSaveCurrentActivitiesWithStartDate:startDate endDate:endDate] continueWithSuccessBlock:^id(BFTask *__) {
            return [self prepareStatisticsCollection:startDate];
        }] continueWithSuccessBlock:^id(BFTask *getStatisticsTask) {
            HKStatisticsCollection *collection = getStatisticsTask.result;


            NSDate *partEndDate = endDate;
            NSDate *partStartDate = [partEndDate dateByAddingTimeInterval:-oneHourInSeconds];

            BFTask *readAndSendEverythingTask = [BFTask taskWithResult:nil];

            while (partStartDate >= startDate) {
                StepsLog *stepsLog = [self getActivityFromDate:partStartDate toDate:partEndDate];
                NSInteger stepsCount = [self stepsFromHK:partStartDate statisticsCollection:collection];
                NSInteger previousSteps = [stepsLog.stepsCount integerValue];
                if (stepsLog) {
                    if (previousSteps != stepsCount && stepsCount > 0) {
                        readAndSendEverythingTask = [readAndSendEverythingTask continueWithSuccessBlock:^id(BFTask *task) {
                            return [self updateStepsToFitbitServer:stepsCount
                                                     previousSteps:previousSteps
                                                         startDate:partStartDate
                                                           endDate:partEndDate
                                                        activityId:stepsLog.logId];
                        }];
                    }

                } else {
                    if (stepsCount > 0) {
                        readAndSendEverythingTask = [readAndSendEverythingTask continueWithSuccessBlock:^id(BFTask *task) {
                            return [self addNewStepsToFitbitServer:stepsCount
                                                         startDate:partStartDate
                                                           endDate:partEndDate];
                        }];
                    }
                }

                partEndDate = partStartDate;
                partStartDate = [partStartDate dateByAddingTimeInterval:-oneHourInSeconds];
            }

            return readAndSendEverythingTask;
        }];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:LastDateIdentifier];
        return nil;
    }] continueWithBlock:^id(BFTask *task) {
        NSTimeInterval syncTime = [[NSDate date] timeIntervalSinceDate:syncStartDate];

        DDLogInfo(@"Sync time: %@ seconds", @(syncTime));

        return task;
    }];
}

- (BFTask *)downloadAndSaveCurrentActivitiesWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSDate *processedDate = endDate;
    BFTask *completionTask = [BFTask taskWithResult:nil];
    NSManagedObjectContext * backgroundContext = [[H2FAppDelegate sharedInstance] coreDataStack].backgroundThreadContext;

    while (processedDate >= startDate) {
        completionTask = [completionTask continueWithSuccessBlock:^id(BFTask *task) {
            return [self taskForDownloadAndSaveActivitesFromDate:processedDate];
        }];

        processedDate = [processedDate dateByAddingTimeInterval:-oneDayInSeconds];
    }

    return [[backgroundContext h2f_performBlockAndSave:^NSError * {
        [backgroundContext removeEntitiesWithName:[StepsLog h2f_className] predicate:nil];
        return nil;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        return completionTask;
    }];
}

- (BFTask *)taskForDownloadAndSaveActivitesFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * processedDateString = [dateFormatter stringFromDate:date];
    NSString * activitiesPath = [NSString stringWithFormat:@"/1/user/-/activities/date/%@.json", processedDateString];
    NSManagedObjectContext * backgroundContext = [[H2FAppDelegate sharedInstance] coreDataStack].backgroundThreadContext;

    return [[self.apiClient h2f_getPath:activitiesPath parameters:nil] continueWithSuccessBlock:^id(BFTask *getActivityResultTask) {
        NSData *responseData = getActivityResultTask.result;

        return [backgroundContext h2f_performBlockAndSave:^NSError * {
            NSError * jsonError;
            NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:&jsonError];

            if (!jsonError) {

                DDLogInfo(@"Recieved %@ activities.", @([responseDict[@"activities"] count]));
                for (NSDictionary *activityDict in responseDict[@"activities"]) {
                    NSString * activityStartTime = activityDict[@"startTime"];
                    NSString * activityStartDate = activityDict[@"startDate"];
                    NSNumber * activityParentId = activityDict[@"activityParentId"];
                    NSNumber * duration = activityDict[@"duration"];
                    NSNumber * steps = activityDict[@"steps"];
                    NSNumber * logId = activityDict[@"logId"];

                    BOOL isWalkingActivity = [activityParentId isEqualToNumber:@(walkActivityId)];
                    BOOL isBeginningAtFirstMinuteOfHour = [activityStartTime hasSuffix:@":00"];
                    BOOL lastsOneHour = [duration isEqualToNumber:@(oneHourInSeconds * 1000)];
                    BOOL lastsOneHourMinusSecond = [duration isEqualToNumber:@((oneHourInSeconds - 1) * 1000)];
                    if (isBeginningAtFirstMinuteOfHour && (lastsOneHour || lastsOneHourMinusSecond) && isWalkingActivity) {
                        StepsLog *stepsLog = (StepsLog *) [backgroundContext insertNewEntityWithName:[StepsLog h2f_className]];

                        stepsLog.logId = logId;
                        stepsLog.startDate = activityStartDate;
                        stepsLog.startTime = activityStartTime;
                        stepsLog.duration = duration;
                        stepsLog.stepsCount = steps;
                    } else {
                        DDLogWarn(@"Wrong activity. ID: %@ startDate: %@ time: %@ duration: %@ steps: %@.", logId, activityStartDate, activityStartTime, duration, steps);
                    }
                }
                return nil;
            } else {
                DDLogError(@"JSON decode error %@", jsonError.localizedDescription);
                return jsonError;
            }
        }];
    }];
}

- (StepsLog *)getActivityFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSManagedObjectContext * mainContext = [H2FAppDelegate sharedInstance].coreDataStack.mainThreadContext;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * searchDateString = [dateFormatter stringFromDate:startDate];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString * searchTime = [dateFormatter stringFromDate:startDate];
    NSInteger difference = (NSInteger) ([endDate timeIntervalSinceDate:startDate] * 1000);
    NSInteger differenceMinusOne = (NSInteger) (([endDate timeIntervalSinceDate:startDate] - 1) * 1000);

    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
            [NSPredicate predicateWithFormat:@"%K == %@", _sfs(startDate), searchDateString],
            [NSPredicate predicateWithFormat:@"%K == %@", _sfs(startTime), searchTime],
            [NSCompoundPredicate orPredicateWithSubpredicates:@[
                    [NSPredicate predicateWithFormat:@"%K == %@", _sfs(duration), @(difference)],
                    [NSPredicate predicateWithFormat:@"%K == %@", _sfs(duration), @(differenceMinusOne)],
            ]]
    ]];

    return (StepsLog *) [mainContext fetchObjectWithEntityName:[StepsLog h2f_className] predicate:predicate];
}

- (BFTask *)addNewStepsToFitbitServer:(double)steps startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    DDLogInfo(@"Will post new steps with %@ steps startDate: %@ endDate: %@", @(steps), startDate, endDate);

    return [[[self sendStepsToFitbitServer:steps
                                 startDate:startDate
                                   endDate:endDate
                                activityId:nil]
            continueWithSuccessBlock:^id(BFTask *task) {
                DDLogInfo(@"Successfully added new steps with %@ steps startDate: %@ endDate: %@", @(steps), startDate, endDate);
                return task;
            }] continueWithBlock:^id(BFTask *task) {
        if ([task h2f_hasFailed]) {
            DDLogInfo(@"Failed to add new steps with %@ steps startDate: %@ endDate: %@. Error: %@", @(steps), startDate, endDate, [task h2f_failureDescriptionError].localizedDescription);
        }
        return task;
    }];
}

- (BFTask *)updateStepsToFitbitServer:(NSInteger)steps previousSteps:(NSInteger)previousSteps startDate:(NSDate *)startDate endDate:(NSDate *)endDate activityId:(NSNumber *)activityId {
    DDLogInfo(@"Will update steps with %@ steps (previously %@) startDate: %@ endDate: %@ activityId: %@", @(steps), @(previousSteps), startDate, endDate, activityId);
    return [[[self sendStepsToFitbitServer:steps
                                 startDate:startDate
                                   endDate:endDate
                                activityId:activityId] continueWithSuccessBlock:^id(BFTask *task) {
        DDLogInfo(@"Successfully updated steps with %@ steps (previously %@) startDate: %@ endDate: %@ activityId: %@", @(steps), @(previousSteps), startDate, endDate, activityId);
        return task;
    }] continueWithBlock:^id(BFTask *task) {
        if ([task h2f_hasFailed]) {
            DDLogError(@"Failed to update steps with %@ steps (previously %@) startDate: %@ endDate: %@ activityId: %@. Error: %@", @(steps), @(previousSteps), startDate, endDate, activityId, [task h2f_failureDescriptionError].localizedDescription);
        }
        return task;
    }];
}

- (BFTask *)sendStepsToFitbitServer:(double)steps startDate:(NSDate *)startDate endDate:(NSDate *)endDate activityId:(NSNumber *)activityId {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString * startTime = [dateFormatter stringFromDate:startDate];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * startDateString = [dateFormatter stringFromDate:startDate];

    NSInteger durationInterval = (NSInteger) [endDate timeIntervalSinceDate:startDate];

    NSMutableDictionary *params = [@{
            @"activityId" : @(walkActivityId),
            @"startTime" : startTime,
            @"durationMillis" : @(durationInterval * 1000),
            @"date" : startDateString,
            @"distance" : @(steps),
            @"distanceUnit" : @"Steps"
    } mutableCopy];

    NSString * path = activityId ? [NSString stringWithFormat:@"/1/user/-/activities/%@.json", activityId] : @"/1/user/-/activities.json";

    return [self.apiClient h2f_postPath:path parameters:params];
}

- (NSInteger)stepsFromHK:(NSDate *)startDate statisticsCollection:(HKStatisticsCollection *)collection {
    HKStatistics *statistics = [collection statisticsForDate:startDate];

    NSInteger stepsCount = 0;
    HKQuantity *quantity = statistics.sumQuantity;
    if (quantity) {
        stepsCount = (NSInteger) [quantity doubleValueForUnit:[HKUnit countUnit]];
    }

    return stepsCount;
}

- (BFTask *)prepareStatisticsCollection:(NSDate *)startDate {
    BFTaskCompletionSource *taskCS = [BFTaskCompletionSource taskCompletionSource];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.hour = 1;

    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:startDate
                                                                                intervalComponents:interval];

    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *_, HKStatisticsCollection *results, NSError *error) {

        if (error) {
            DDLogError(@"Error while reading from HK");
            [taskCS setError:error];
        } else {
            DDLogInfo(@"Successfully read from HK");
            [taskCS setResult:results];
        }
    };

    [self.healthStore executeQuery:query];

    return taskCS.task;
}


@end