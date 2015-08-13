#import <UIKit/UIKit.h>

@class AFOAuth1Client;
@class H2FHealthManager;
@class H2FAppDelegate;

@interface H2FMainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UIButton *reloginButton;
@property (weak, nonatomic) IBOutlet UIView *logView;

- (H2FHealthManager *)healthManager;
@end

