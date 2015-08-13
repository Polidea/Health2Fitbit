#import <HealthKit/HealthKit.h>
#import <Bolts/BFExecutor.h>
#import "H2FMainViewController.h"
#import "UIControl+BlocksKit.h"
#import "libextobjc/EXTScope.h"
#import "H2FHealthManager.h"
#import "H2FAppDelegate.h"
#import "UIForLumberjack.h"
#import "BFTask+H2FFailureChecking.h"
#import "UIAlertView+BlocksKit.h"
#import "MBProgressHUD.h"

@interface H2FMainViewController ()
@end


@implementation H2FMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self styleReLoginButton];

    @weakify(self)
    [self.reloginButton bk_addEventHandler:^(id sender) {
        @strongify(self)

        if ([self.healthManager loggedIn]) {
            [self.healthManager clearFitbitCredentials];
            [self styleReLoginButton];
        } else {
            [[[self.healthManager loginToFitbitWithForcedLogin:YES] continueWithSuccessBlock:^id(BFTask *task) {
                [self styleReLoginButton];
                return nil;
            }] continueWithBlock:^id(BFTask *task) {
                if ([task h2f_hasFailed]) {
                    [[UIAlertView bk_alertViewWithTitle:@"Login error" message:[task h2f_failureDescriptionError].localizedDescription] show];
                }
                return nil;
            }];
        }


    }                     forControlEvents:UIControlEventTouchUpInside];

    [self.refreshButton bk_addEventHandler:^(id sender) {
        @strongify(self)
        DDLogInfo(@"Will refresh from main screen");
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Refreshing";

        [[[[self healthManager] processStepsFromLastWeek] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
            DDLogInfo(@"Succeded refreshing from main screen");
            return nil;
        }] continueWithBlock:^id(BFTask *task) {
            [hud hide:YES];
            if ([task h2f_hasFailed]) {
                DDLogError(@"Failed to refresh from main screen: %@", [task h2f_failureDescriptionError].localizedDescription);
                DDLogError(@"More info: %@", [task h2f_failureDescriptionError].userInfo);
            }

            return nil;
        }];
    }                     forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [[UIForLumberjack sharedInstance] showLogInView:self.view];
    }
}

- (void)styleReLoginButton {
    NSString *title = [self.healthManager loggedIn] ? @"Clear credentials (including last sync date)" : @"Login";
    [self.reloginButton setTitle:title forState:UIControlStateNormal];
}

- (H2FHealthManager *)healthManager {
    return ((H2FAppDelegate *) [[UIApplication sharedApplication] delegate]).healthManager;
}
@end
