

#import "RootViewController.h"
#import "MyViewController.h"

static NSString *kNameKey = @"nameKey";
static NSString *kImageKey = @"imageKey";

@interface RootViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic) NSUInteger current_page;
@property (nonatomic) NSUInteger direction;


@end

#pragma mark -

@implementation RootViewController

CGPoint startPos;
int     scrollDirection;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUInteger numberPages = self.contentList.count;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    //self.scrollView.contentSize =
    //    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.scrollView.frame)* numberPages, CGRectGetHeight(self.scrollView.frame)* numberPages);
    //self.scrollView.showsHorizontalScrollIndicator = YES;
    //self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.directionalLockEnabled = YES;
    self.pageControl.numberOfPages = numberPages;
    self.pageControl.currentPage = 1;
    self.direction = 0;
    self.current_page = 1;
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0 direction:0];
    [self loadScrollViewWithPage:1 direction:0];
    [self loadScrollViewWithPage:2 direction:0];
    [self loadScrollViewWithPage:0 direction:1];
    [self loadScrollViewWithPage:1 direction:1];
    [self loadScrollViewWithPage:2 direction:1];
}

// rotation support for iOS 5.x and earlier, note for iOS 6.0 and later this will not be called
//
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // return YES for supported orientations
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#endif

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    // remove all the subviews from our scrollview
//    for (UIView *view in self.scrollView.subviews)
//    {
//        [view removeFromSuperview];
//    }
//    
//    NSUInteger numPages = self.contentList.count;
//    
//    // adjust the contentSize (larger or smaller) depending on the orientation
//    self.scrollView.contentSize =
//        CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numPages, CGRectGetHeight(self.scrollView.frame)* numPages);
//    
//    // clear out and reload our pages
//    self.viewControllers = nil;
//    NSMutableArray *controllers = [[NSMutableArray alloc] init];
//    for (NSUInteger i = 0; i < numPages; i++)
//    {
//		[controllers addObject:[NSNull null]];
//    }
//    self.viewControllers = controllers;
//    
//    [self loadScrollViewWithPage:self.pageControl.currentPage - 1];
//    [self loadScrollViewWithPage:self.pageControl.currentPage];
//    [self loadScrollViewWithPage:self.pageControl.currentPage + 1];
//    [self gotoPage:NO]; // remain at the same page (don't animate)
//}

- (void)loadScrollViewWithPage:(NSUInteger)page
                 direction: (NSUInteger) direction
{
    if (page >= self.contentList.count)
        return;
    
    // replace the placeholder if necessary
    MyViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[MyViewController alloc] initWithPageNumber:page];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        switch (direction) {
            //  0= horizontal, 1 = vertical
            case 0:
                frame.origin.x = CGRectGetWidth(frame) * page;
                frame.origin.y = 0;
                break;
                
            case 1:
                frame.origin.x = 0;
                frame.origin.y = CGRectGetHeight(frame) * page;;
                break;
        }
        controller.view.frame = frame;

        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        
        NSDictionary *numberItem = [self.contentList objectAtIndex:page];
        controller.numberImage.image = [UIImage imageNamed:[numberItem valueForKey:kImageKey]];
        controller.numberTitle.text = [numberItem valueForKey:kNameKey];
    }
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible

     CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
     NSUInteger pageH = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
     CGFloat pageHeight = CGRectGetHeight(self.scrollView.frame);
     NSUInteger pageV = floor((self.scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    if (pageH!= self.current_page) {
        self.current_page = pageH;
        self.direction = 0;
    }
    else if (pageV!= self.current_page) {
        self.current_page = pageV;
        self.direction = 1;
    }
    

    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:self.current_page - 1 direction: self.direction];
    [self loadScrollViewWithPage:self.current_page direction: self.direction];
    [self loadScrollViewWithPage:self.current_page + 1 direction: self.direction];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    startPos = scrollView.contentOffset;
    scrollDirection=0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollDirection==0){//we need to determine direction
        //use the difference between positions to determine the direction.
        if (abs(startPos.x-scrollView.contentOffset.x)<abs(startPos.y-scrollView.contentOffset.y)){
            NSLog(@"Vertical Scrolling");
            scrollDirection=1;
        } else {
            NSLog(@"Horitonzal Scrolling");
            scrollDirection=2;
        }
    }
    //Update scroll position of the scrollview according to detected direction.
    if (scrollDirection==1) {
        [scrollView setContentOffset:CGPointMake(startPos.x,scrollView.contentOffset.y) animated:NO];
    } else if (scrollDirection==2){
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x,startPos.y) animated:NO];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        scrollDirection=3;
    }
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;

    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1 direction:self.direction];
    [self loadScrollViewWithPage:page direction:self.direction];
    [self loadScrollViewWithPage:page + 1 direction:self.direction];
    
	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    //bounds.origin.x = CGRectGetWidth(bounds) * page;
    //bounds.origin.y = 0;
    bounds.origin.x = CGRectGetWidth (bounds) *page;
    bounds.origin.y = CGRectGetHeight(bounds) *page;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];    // YES = animate
}

@end
