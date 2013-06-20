
#import "MyViewController.h"

@interface MyViewController ()
{
    int pageNumber;
}
@end

@implementation MyViewController

// load the view nib and initialize the pageNumber ivar
- (id)initWithPageNumber:(NSUInteger)page
{
    if (self = [super initWithNibName:@"MyView" bundle:nil])
    {
        pageNumber = page;
    }
    return self;
}

// set the label and background color when the view has finished loading
- (void)viewDidLoad
{
    self.pageNumberLabel.text = [NSString stringWithFormat:@"Page Landy %d", pageNumber + 1];
}

@end
