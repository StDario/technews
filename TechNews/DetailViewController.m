//
//  DetailViewController.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import "DetailViewController.h"
#import <Social/Social.h>

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

static NSString * const DownloadUrlString = @"http://skopjeparking.byethost7.com/fetchArticleHtml.php?";
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setNewsArticle:(id)newDetailItem
{
    if (_newsArticle != newDetailItem) {
        _newsArticle = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

-(void)setSocialButtons
{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"twitter" ofType: @"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile: path];
    [self.btnTwitter setImage:image forState:UIControlStateNormal];
    path = [[NSBundle mainBundle] pathForResource: @"twitter-background 2" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [self.btnTwitter setImage:image forState:UIControlStateHighlighted];
    
    path = [[NSBundle mainBundle] pathForResource: @"facebook" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [self.btnFacebook setImage:image forState:UIControlStateNormal];
    path = [[NSBundle mainBundle] pathForResource: @"facebook-background 2" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [self.btnFacebook setImage:image forState:UIControlStateHighlighted];
}

- (void)configureView
{
    // Update the user interface for the detail item.

//    if (self.newsArticle) {
//        self.detailDescriptionLabel.text = self.newsArticle.title;
//        self.sourceName.text = self.newsArticle.sourceName;
//        self.sourceName.text = _newsArticle.sourceName;
//        [self downloadPicture:_newsArticle.sourceImage forImageView:self.sourceImage];
//        self.articleTitle.text =_newsArticle.title;
//        self.author.text = _newsArticle.author;
//        self.publishDate.text = [NSDateFormatter localizedStringFromDate:_newsArticle.publishDate
//                                                                                       dateStyle:NSDateFormatterShortStyle
//                                                                                       timeStyle:NSDateFormatterFullStyle];
//        [self downloadPicture:_newsArticle.imageUrl forImageView:self.articleImage];
//        [self downloadArticleContent];
//    }
    [self downloadArticleContent];
    [self setSocialButtons];
    self.articleTitle.text =_newsArticle.title;
    self.author.text = _newsArticle.author;
    self.publishDate.text = [NSDateFormatter localizedStringFromDate:_newsArticle.publishDate
                                                                                   dateStyle:NSDateFormatterShortStyle
                                                                                   timeStyle:NSDateFormatterFullStyle];
    
}

-(void)downloadPicture:(NSString *)url forImageView:(UIImageView *)imageView{
    
    
    dispatch_async(kBgQueue, ^{
        NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image;
            if (imgData) {
                image = [[UIImage alloc] initWithData:imgData];
            }
            else {
                image = nil;
            }
            imageView.image = image;
        });
    });
}

-(void)handleResponse:(NSString *)text
{
    //self.articleContent.text = text;
}

-(void)downloadArticleContent
{
    int location = [_newsArticle.file rangeOfString:@"/" options:NSBackwardsSearch].location;
    NSRange fileRange = NSMakeRange(location + 1, _newsArticle.file.length - location - 1);
    NSString *file = [_newsArticle.file substringWithRange: fileRange];
    NSString *urlString = [NSString stringWithFormat:@"%@sourceName=%@&file=%@", DownloadUrlString, _newsArticle.sourceName, file];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *result = [operation responseString];
        [self handleResponse:result];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Article Content"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    // 5
    [operation start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"5EC4DB"];

}

- (IBAction)shareOnFacebook:(id)sender;
{
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
//    {
//        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        
//        NSString *initialText = _newsArticle.link;
//        
//        [facebookSheet setInitialText: initialText];
//        [self presentViewController:facebookSheet animated:YES completion:nil];
//    }
//    else
//    {
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:@"Sorry"
//                                  message:@"You can't share on facebook right now, make sure your device has an internet connection and you have at least one Twitter account setup"
//                                  delegate:self
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil];
//        [alertView show];
//    }
}


- (IBAction)shareOnTwitter:(id)sender;
{
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
//    {
//        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//        
//        NSString *initialText = _newsArticle.link;
//        
//        [tweetSheet setInitialText: initialText];
//        [self presentViewController:tweetSheet animated:YES completion:nil];
//    }
//    else
//    {
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:@"Sorry"
//                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
//                                  delegate:self
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil];
//        [alertView show];
//    }
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
