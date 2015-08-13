#import <AFOAuth1Client/AFOAuth1Client.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "AFOAuth1Client+BFTasks.h"


@implementation AFOAuth1Client (BFTasks)

- (BFTask *)h2f_authorizeUsingOAuthWithRequestTokenPath:(NSString *)requestTokenPath
                                  userAuthorizationPath:(NSString *)userAuthorizationPath
                                            callbackURL:(NSURL *)callbackURL
                                        accessTokenPath:(NSString *)accessTokenPath
                                           accessMethod:(NSString *)accessMethod
                                                  scope:(NSString *)scope {
    BFTaskCompletionSource *performBlockTaskCS = [BFTaskCompletionSource taskCompletionSource];

    [self authorizeUsingOAuthWithRequestTokenPath:requestTokenPath
                            userAuthorizationPath:userAuthorizationPath
                                      callbackURL:callbackURL
                                  accessTokenPath:accessTokenPath
                                     accessMethod:accessMethod
                                            scope:scope
                                          success:^(AFOAuth1Token *accessToken, id responseObject) {
                                              [performBlockTaskCS setResult:accessToken];
                                          }
                                          failure:^(NSError *error) {

                                              [performBlockTaskCS setError:error];
                                          }];

    return performBlockTaskCS.task;
}

- (BFTask *)h2f_getPath:(NSString *)path parameters:(NSDictionary *)parameters {
    BFTaskCompletionSource *performBlockTaskCS = [BFTaskCompletionSource taskCompletionSource];


    [self getPath:path
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [performBlockTaskCS setResult:responseObject];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [performBlockTaskCS setError:error];
          }];

    return performBlockTaskCS.task;
}

- (BFTask *)h2f_postPath:(NSString *)path parameters:(NSDictionary *)parameters {
    BFTaskCompletionSource *performBlockTaskCS = [BFTaskCompletionSource taskCompletionSource];

    [self postPath:path
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [performBlockTaskCS setResult:responseObject];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [performBlockTaskCS setError:error];
          }];

    return performBlockTaskCS.task;
}


@end