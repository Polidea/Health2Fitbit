#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "Bolts/Bolts.h"

@class BFTask;
@class AFOAuth1Token;

@interface AFOAuth1Client (BFTasks)

- (BFTask *)h2f_authorizeUsingOAuthWithRequestTokenPath:(NSString *)requestTokenPath userAuthorizationPath:(NSString *)userAuthorizationPath callbackURL:(NSURL *)callbackURL accessTokenPath:(NSString *)accessTokenPath accessMethod:(NSString *)accessMethod scope:(NSString *)scope;

- (BFTask *)h2f_getPath:(NSString *)path parameters:(NSDictionary *)parameters;

- (BFTask *)h2f_postPath:(NSString *)path parameters:(NSDictionary *)parameters;

@end