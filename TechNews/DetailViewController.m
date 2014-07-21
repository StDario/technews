//
//  DetailViewController.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import "DetailViewController.h"
#import <Social/Social.h>
#import "NewsContent.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

static NSString * const DownloadUrlString = @"http://skopjeparking.byethost7.com/fetchArticleHtml.php?";
static NSString * const DownloadContentUrlString = @"http://skopjeparking.byethost7.com/NewsContent.php?";
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@implementation DetailViewController

bool flag = false;
UIScrollView *scrollView;
int nextY;
CGSize screenSize;
int scrollHeight;
int margins;

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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.scrollView.delegate = self;
//    self.scrollView.scrollEnabled = YES;
//    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

-(void)setSocialButtons1
{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"twitter" ofType: @"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile: path];
    [self.btnTwitter setImage:image forState:UIControlStateNormal];
    path = [[NSBundle mainBundle] pathForResource: @"twitter-background" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [self.btnTwitter setImage:image forState:UIControlStateHighlighted];
    
    path = [[NSBundle mainBundle] pathForResource: @"facebook" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [self.btnFacebook setImage:image forState:UIControlStateNormal];
    path = [[NSBundle mainBundle] pathForResource: @"facebook-background" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [self.btnFacebook setImage:image forState:UIControlStateHighlighted];
}

-(void)setSocialButtons:(UIButton *)btnTwitter Facebook :(UIButton *)btnFacebook
{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"twitter" ofType: @"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile: path];
    [btnTwitter setImage:image forState:UIControlStateNormal];
    path = [[NSBundle mainBundle] pathForResource: @"twitter-background" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [btnTwitter setImage:image forState:UIControlStateHighlighted];
    
    path = [[NSBundle mainBundle] pathForResource: @"facebook" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [btnFacebook setImage:image forState:UIControlStateNormal];
    path = [[NSBundle mainBundle] pathForResource: @"facebook-background" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [btnFacebook setImage:image forState:UIControlStateHighlighted];
    
    [btnTwitter addTarget:self
                 action:@selector(shareOnTwitter:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [btnFacebook addTarget:self
                 action:@selector(shareOnFacebook:)
       forControlEvents:UIControlEventTouchUpInside];
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
    //[self downloadArticleContent];
    [self downloadNewsArticleContent];
    //[self setSocialButtons];
    //self.articleTitle.text =_newsArticle.title;
    //self.author.text = _newsArticle.author;
    //self.publishDate.text = [NSDateFormatter localizedStringFromDate:_newsArticle.publishDate
                                                                                   //dateStyle:NSDateFormatterShortStyle
                                                                                   //timeStyle:NSDateFormatterFullStyle]
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

-(void)showLayoutForiPad:(NewsContent *)content
{
    screenSize = self.view.frame.size;
    scrollHeight = 500;
    margins = 20;
    nextY = 0;
    int titleHeight = 200;
    int authorHeight = 20;
    int authorWidht = 300;
    int dateHeight = 20;
    int dateWidth = 200;
    int sourceNameHeight = 20;
    int sourceNameWidth = 100;
    int sourceImageHeight = 30;
    int sourceImageWidth = 30;
    int socialButtonHeight = 40;
    int socialButtonWidth = 40;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, nextY, screenSize.width - margins, titleHeight)];
    title.font = [UIFont fontWithName:@"HelveticaNeue" size:26];
    title.lineBreakMode = NSLineBreakByWordWrapping;
    title.numberOfLines = 0;
    title.text = _newsArticle.title;
    scrollHeight += titleHeight;
    nextY += titleHeight + 30;
    
    UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(screenSize.width - margins - authorWidht, nextY, authorWidht, authorHeight)];
    author.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    author.text = _newsArticle.author;
    author.textAlignment = NSTextAlignmentRight;
    
    UILabel *sourceName = [[UILabel alloc] initWithFrame:CGRectMake(10, nextY, sourceNameWidth, sourceNameHeight)];
    sourceName.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    sourceName.text = _newsArticle.sourceName;
    
    
    scrollHeight += authorHeight;
    nextY += authorHeight;
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(screenSize.width - margins - dateWidth, nextY, dateWidth, dateHeight)];
    date.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    NSString *artDate = [NSDateFormatter localizedStringFromDate:_newsArticle.publishDate
                                                       dateStyle:NSDateFormatterMediumStyle
                                                       timeStyle:0];
    date.text = artDate;
    date.textAlignment = NSTextAlignmentRight;
    
    
    
    UIImageView *sourceImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, nextY, sourceImageWidth, sourceImageHeight)];
    [self downloadPicture:_newsArticle.sourceImage forImageView:sourceImage];
    
    
    scrollHeight += dateHeight;
    nextY += dateHeight;
    
    UIButton *btnTwitter = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - margins - 2 * socialButtonWidth - 10, nextY, socialButtonWidth, socialButtonHeight)];
    UIButton *btnFacebook = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - margins - socialButtonWidth, nextY, socialButtonWidth, socialButtonHeight)];
    
    [self setSocialButtons:btnTwitter Facebook:btnFacebook];
    
    scrollHeight += socialButtonHeight;
    nextY += socialButtonHeight;
    
    CGSize maximumLabelSize = CGSizeMake((screenSize.width - margins) / 2, FLT_MAX);
    
    int textLength = content.text.length;
    int charsPerSection = 500;
    int sections = textLength / charsPerSection + 1 + content.images.count;
    int newRow = 0;
    int nextX = 10;
    int nextText = 0;
    int textAdded = textLength / charsPerSection + 1;
    int videosAdded = content.videos.count;
    int imagesAdded = content.images.count;
    int nextYFirstColumn = nextY;
    int nextYSecondColumn = nextY;
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, screenSize.width, screenSize.height)];
    scrollView.backgroundColor = [UIColor whiteColor];
    
    for(int i = 0; i < sections; i++){
        
        int heightToAdd = 0;
        int r = arc4random() % 3;
        
        if(i == 0 || (textAdded != 0 && r == 0) || (imagesAdded == 0)){
            if(newRow == 0)
                nextY = nextYFirstColumn;
            else
                nextY = nextYSecondColumn;
            
            UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(nextX, nextY, (screenSize.width - margins) / 2 - 5, 700)];
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:18];
            textView.font = font;
            
            NSRange fileRange;
            if(nextText * charsPerSection + charsPerSection > textLength)
            {
                fileRange = NSMakeRange(nextText * charsPerSection, textLength - nextText * charsPerSection);
            }
            else {
                fileRange = NSMakeRange(nextText * charsPerSection, charsPerSection);
            }
            NSString *text = [content.text substringWithRange: fileRange];
            
            CGSize t = [text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{
                                                    NSFontAttributeName : textView.font
                                                    }
                                          context:nil].size;
            
            CGRect frame = textView.frame;
            frame.size.height = t.height;
            textView.frame = frame;
            textView.text = text;
            textView.lineBreakMode = NSLineBreakByWordWrapping;
            textView.numberOfLines = 0;
            heightToAdd = t.height;
            
            nextText++;
            [scrollView addSubview:textView];
            textAdded--;
        }
        else if((r == 1 && imagesAdded != 0))
        {
            if(newRow == 0)
                nextY = nextYFirstColumn;
            else
                nextY = nextYSecondColumn;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(nextX, nextY, (screenSize.width - margins) / 2 - 5, 300)];
            [self downloadContentPictures:content.images[content.images.count - imagesAdded] forImageView:imageView];
            [scrollView addSubview:imageView];
            heightToAdd = 300;
            imagesAdded--;
        }
//        else
//        {
//            if(newRow == 0)
//                nextY = nextYFirstColumn;
//            else
//                nextY = nextYSecondColumn;
//            
//            NSString *urlStr = [content.videos[content.videos.count - videosAdded] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
//            NSURL *url = [NSURL URLWithString:urlStr];
//            NSURLRequest *request = [NSURLRequest requestWithURL:url];
//            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(nextX, nextY, screenSize.width - margins / 2 - 5, 300)];
//            [webView loadRequest:request];
//            heightToAdd = 300;
//            scrollView.contentSize = CGSizeMake(screenSize.width, scrollHeight);
//            [scrollView addSubview:webView];
//            videosAdded--;
//        }
        
        if(newRow == 0){
            nextX += (screenSize.width - margins) / 2 + 5;
            newRow = 1;
            nextYFirstColumn += heightToAdd + 20;
        }
        else
        {
            scrollHeight += heightToAdd;
            nextX = 10;
            newRow = 0;
            nextYSecondColumn += heightToAdd + 20;
        }
        
    }
    
    if(nextYFirstColumn > nextYSecondColumn)
        nextY = nextYFirstColumn;
    else
        nextY = nextYSecondColumn;
    
    
    
    
    
    
    scrollView.contentSize = CGSizeMake(screenSize.width, scrollHeight);
    scrollView.delegate = self;
    scrollView.scrollEnabled = YES;
    [scrollView addSubview:title];
    [scrollView addSubview:author];
    [scrollView addSubview:date];
    [scrollView addSubview:sourceName];
    [scrollView addSubview:sourceImage];
    [scrollView addSubview:btnFacebook];
    [scrollView addSubview:btnTwitter];
    
    
//    for(NSString *imageUrl in content.images)
//    {
//        UIImageView *imageView = [[UIImageView alloc] init];
//        [self downloadContentPictures:imageUrl forImageView:imageView];
//        [scrollView addSubview:imageView];
//    }
//    
    for(NSString *videoUrl in content.videos)
    {
        NSString *urlStr = [videoUrl stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, nextY, screenSize.width - margins, 300)];
        [webView loadRequest:request];
        scrollHeight += 300;
        nextY += 300;
        scrollView.contentSize = CGSizeMake(screenSize.width, scrollHeight);
        [scrollView addSubview:webView];
    }
    
    
    [self.view addSubview:scrollView];
}

-(void)downloadContentPictures:(NSString *)url forImageView:(UIImageView *)imageView{
    
    
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
            
            //CGRect frame = CGRectMake(0, nextY, screenSize.width - margins, image.size.height);
            //imageView.frame = frame;
            imageView.image = image;
            //nextY += image.size.height;
            //scrollHeight += image.size.height;
            //frame = CGRectMake(10, 70, screenSize.width, scrollHeight);
            //scrollView.contentSize = CGSizeMake(screenSize.width, scrollHeight);
        });
    });
}

-(void)showLayoutForiPhone:(NewsContent *)content
{
    screenSize = self.view.frame.size;
    scrollHeight = 100;
    margins = 20;
    nextY = 0;
    int titleHeight = 100;
    int authorHeight = 20;
    int authorWidht = 300;
    int dateHeight = 20;
    int dateWidth = 200;
    int sourceNameHeight = 20;
    int sourceNameWidth = 100;
    int sourceImageHeight = 30;
    int sourceImageWidth = 30;
    int socialButtonHeight = 40;
    int socialButtonWidth = 40;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY, screenSize.width - margins, titleHeight)];
    title.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
    title.lineBreakMode = NSLineBreakByWordWrapping;
    title.numberOfLines = 0;
    title.text = _newsArticle.title;
    scrollHeight += titleHeight;
    nextY += titleHeight + 30;
    
    UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(screenSize.width - margins - authorWidht, nextY, authorWidht, authorHeight)];
    author.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    author.text = _newsArticle.author;
    author.textAlignment = NSTextAlignmentRight;
    
    UILabel *sourceName = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY, sourceNameWidth, sourceNameHeight)];
    sourceName.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    sourceName.text = _newsArticle.sourceName;

    
    scrollHeight += authorHeight;
    nextY += authorHeight;
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(screenSize.width - margins - dateWidth, nextY, dateWidth, dateHeight)];
    date.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    NSString *artDate = [NSDateFormatter localizedStringFromDate:_newsArticle.publishDate
                                                       dateStyle:NSDateFormatterMediumStyle
                                                       timeStyle:0];
    date.text = artDate;
    date.textAlignment = NSTextAlignmentRight;
    
    
    
    UIImageView *sourceImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, nextY, sourceImageWidth, sourceImageHeight)];
    [self downloadPicture:_newsArticle.sourceImage forImageView:sourceImage];

    
    scrollHeight += dateHeight;
    nextY += dateHeight;
    
    UIButton *btnTwitter = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - margins - 2 * socialButtonWidth - 10, nextY, socialButtonWidth, socialButtonHeight)];
    UIButton *btnFacebook = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - margins - socialButtonWidth, nextY, socialButtonWidth, socialButtonHeight)];
    
    [self setSocialButtons:btnTwitter Facebook:btnFacebook];
    
    scrollHeight += socialButtonHeight;
    nextY += socialButtonHeight;
    
    CGSize maximumLabelSize = CGSizeMake(screenSize.width - margins, FLT_MAX);
    
    
    
    
    UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY, screenSize.width - margins, 700)];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    textView.font = font;
    CGSize t = [content.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin
        attributes:@{
             NSFontAttributeName : textView.font
             }
            context:nil].size;
    
    //CGSize expectedLabelSize = [content.text sizeWithFont:textView.font constrainedToSize:maximumLabelSize lineBreakMode:textView.lineBreakMode];
    CGRect frame = textView.frame;
    frame.size.height = t.height;
    textView.frame = frame;
    textView.text = content.text;
    textView.lineBreakMode = NSLineBreakByWordWrapping;
    textView.numberOfLines = 0;
    //textView.editable = false;
    scrollHeight += t.height;
    nextY += t.height;
    
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 70, screenSize.width, screenSize.height)];
    scrollView.contentSize = CGSizeMake(screenSize.width, scrollHeight);
    scrollView.delegate = self;
    scrollView.scrollEnabled = YES;
    [scrollView addSubview:title];
    [scrollView addSubview:author];
    [scrollView addSubview:date];
    [scrollView addSubview:sourceName];
    [scrollView addSubview:sourceImage];
    [scrollView addSubview:textView];
    [scrollView addSubview:btnFacebook];
    [scrollView addSubview:btnTwitter];
    
    
    for(NSString *imageUrl in content.images)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self downloadContentPictures:imageUrl forImageView:imageView];
        [scrollView addSubview:imageView];
    }
    
    for(NSString *videoUrl in content.videos)
    {
        NSString *urlStr = [videoUrl stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, nextY, screenSize.width - margins, 300)];
        [webView loadRequest:request];
        scrollHeight += 300;
        nextY += 300;
        scrollView.contentSize = CGSizeMake(screenSize.width, scrollHeight);
        [scrollView addSubview:webView];
    }
    
    
    [self.view addSubview:scrollView];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        ScrollDirection scrollDirection;
        if (self.lastContentOffset > scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionUp;
        else if (self.lastContentOffset < scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionDown;
        
        self.lastContentOffset = scrollView.contentOffset.y;
        
        
        
        if(scrollDirection == ScrollDirectionUp)
        {
            [self.navigationController setNavigationBarHidden: NO animated:YES];
        }
        else if(self.lastContentOffset > 0)
        {
            [self.navigationController setNavigationBarHidden: YES animated:YES];
        }
    }
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
//    
//    if(translation.y < 0)
//    {
//        // react to dragging down
//        [self.navigationController setNavigationBarHidden: YES animated:YES];
//    } else
//    {
//        // react to dragging up
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//    }
//}

-(void)handleResponse:(NewsContent *)content
{
    [self removeSubviewsFromScrollView];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self showLayoutForiPad:content];
    }
    else
    {
        [self showLayoutForiPhone:content];
    }
}

-(void)downloadNewsArticleContent
{
    int location = [_newsArticle.file rangeOfString:@"/" options:NSBackwardsSearch].location;
    NSRange fileRange = NSMakeRange(location + 1, _newsArticle.file.length - location - 1);
    NSString *file = [_newsArticle.file substringWithRange: fileRange];
    NSString *urlString = [NSString stringWithFormat:@"%@source=%@&file=%@", DownloadContentUrlString, _newsArticle.sourceName, file];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *result = (NSDictionary *)responseObject;
        NewsContent *content = [[NewsContent alloc] init];
        [content initWithDictionary:result];
        [self handleResponse:content];
        
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
        
//        NSString *result = [operation responseString];
//        [self handleResponse:result];
        
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
    if(flag == false)
        flag = true;
    else
        return;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"5EC4DB"];
}

-(void)removeSubviewsFromScrollView
{
    NSArray *viewsToRemove = [scrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
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
