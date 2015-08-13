#import <UIKit/UIKit.h>
#import "H2FLogger.h"
#import <CocoaLumberjack/DDFileLogger.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import "BFTask+H2FFailureChecking.h"

@class H2FHealthManager;
@class CoreDataStack;

@interface H2FAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong) H2FHealthManager *healthManager;
@property(nonatomic, strong) CoreDataStack *coreDataStack;

+ (H2FAppDelegate *)sharedInstance;
@end