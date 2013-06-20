

#import "AppDelegate.h"
#import "ContentController.h"

@interface AppDelegate ()
@property (nonatomic, strong) IBOutlet ContentController *contentController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // decide which kind of content we need based on the device idiom,
    // when we load the proper nib, the "ContentController" class will take it from here
    //
    NSString *nibTitle = @"PadContent";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		nibTitle = @"PhoneContent";
    }
    [[NSBundle mainBundle] loadNibNamed:nibTitle owner:self options:nil];
    
	[self.window makeKeyAndVisible];
}

@end
