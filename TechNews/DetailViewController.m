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
#import "SavedArticlesHelper.h"
#import "UAProgressView.h"
#import "ImageHelper.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

static NSString * const DownloadUrlString = @"http://skopjeparking.byethost7.com/fetchArticleHtml.php?";
static NSString * const DownloadContentUrlString = @"http://skopjeparking.byethost7.com/NewsContent.php?";
static NSString * const UpdateUserProfileUrlString = @"http://skopjeparking.byethost7.com/updateUserProfile.php?";
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
}

-(void)setSocialButtons:(UIButton *)btnTwitter Facebook :(UIButton *)btnFacebook
{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"twitter" ofType: @"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile: path];
    [btnTwitter setImage:image forState:UIControlStateNormal];
    path = [[NSBundle mainBundle] pathForResource: @"twitter-background 2" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [btnTwitter setImage:image forState:UIControlStateHighlighted];
    
    path = [[NSBundle mainBundle] pathForResource: @"facebook" ofType: @"png"];
    image = [[UIImage alloc] initWithContentsOfFile: path];
    [btnFacebook setImage:image forState:UIControlStateNormal];
    path = [[NSBundle mainBundle] pathForResource: @"facebook-background 2" ofType: @"png"];
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
    self.navigationController.navigationBar.tintColor = [self colorFromHexString:@"#FFFFFF"];
    [self setCustomProgressView];
    
    [self downloadNewsArticleContent];
    [self updateUserProfile];
    
    [self setNavigationBarButtonRight];
}

-(void)updateUserProfile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *facebookUsername = [defaults objectForKey:@"facebookUsername"];
    NSString *twitterUsername = [defaults objectForKey:@"twitterUsername"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@textEntryId=%@&twitterUsername=%@&facebookUsername=%@", UpdateUserProfileUrlString, _newsArticle.textEntryId, twitterUsername, facebookUsername];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    // 5
    [operation start];
}

-(void)addFillToProgress
{
    [self.progressView addFill];
    [NSTimer scheduledTimerWithTimeInterval: 0.8 target: self
                                   selector: @selector(removeFillFromProgress) userInfo: nil repeats: NO];
}

-(void)removeFillFromProgress
{
    [self.progressView removeFillAnimated:YES];
}

-(void)setCustomProgressView
{
    screenSize = self.view.frame.size;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, screenSize.width, screenSize.height)];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(screenSize.width, screenSize.height);
    scrollView.delegate = self;
    scrollView.scrollEnabled = YES;
    scrollView.delaysContentTouches = NO;
    
    CGSize progressSize = CGSizeMake(120, 120);
    UAProgressView *progress = [[UAProgressView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - progressSize.width / 2, screenSize.height / 2 - progressSize.height / 2 - 50, progressSize.width, progressSize.height)];
    
    
    progress.tintColor = [self getProgressColor];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90.0, 32.0)];
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = progress.tintColor;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = @"Fetching";
    progress.centralView = textLabel;
    progress.borderWidth = 1.0;
    progress.lineWidth = 1.0;
    
    [NSTimer scheduledTimerWithTimeInterval: 2 target: self
                                   selector: @selector(addFillToProgress) userInfo: nil repeats: YES];
    
    [scrollView addSubview:progress];
    progress.fillChangedBlock = ^(UAProgressView *progressView, BOOL filled, BOOL animated){
		UIColor *color = (filled ? [UIColor whiteColor] : progressView.tintColor);
		if (animated) {
			[UIView animateWithDuration:0.8 animations:^{
				((UILabel *)progressView.centralView).textColor = color;
			}];
		} else {
			((UILabel *)progressView.centralView).textColor = color;
		}
	};
    
    self.progressView = progress;
    [self.view addSubview:scrollView];
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
    nextY = -40;
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
    
    nextY += 10;
    scrollHeight += 10;
    
    UIButton *btnTwitter = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - margins - 2 * socialButtonWidth - 10, nextY, socialButtonWidth, socialButtonHeight)];
    UIButton *btnFacebook = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - margins - socialButtonWidth, nextY, socialButtonWidth, socialButtonHeight)];
    
    [self setSocialButtons:btnTwitter Facebook:btnFacebook];
    
    scrollHeight += socialButtonHeight;
    nextY += socialButtonHeight;
    
    nextY += 10;
    scrollHeight += 10;
    
    CGSize maximumLabelSize = CGSizeMake((screenSize.width - margins) / 2, FLT_MAX);
    
    int textLength = content.text.length;
    int charsPerSection = 500;
    int sections = textLength / charsPerSection + 1 + content.images.count;
    int newRow = 0;
    int nextX = 10;
    int nextText = 0;
    int textAdded = textLength / charsPerSection + 1;
    //int videosAdded = content.videos.count;
    int imagesAdded = content.images.count;
    int nextYFirstColumn = nextY;
    int nextYSecondColumn = nextY;
    int skipCharTo = 0;
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, screenSize.width, screenSize.height)];
    scrollView.backgroundColor = [UIColor whiteColor];
    
    for(int i = 0; i < sections; i++){
        
        int heightToAdd = 0;
        int r = arc4random() % 2;
        
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
                fileRange = NSMakeRange(nextText * charsPerSection + skipCharTo, textLength - nextText * charsPerSection - skipCharTo);
            }
            else {
                
                int prevSkip = skipCharTo;
                NSRange nextFileRange;
                
                if((nextText + 1) * charsPerSection + charsPerSection > textLength)
                {
                    nextFileRange = NSMakeRange((nextText + 1) * charsPerSection + prevSkip, textLength - (nextText + 1) * charsPerSection - prevSkip);
                }
                else {
                    nextFileRange = NSMakeRange((nextText + 1) * charsPerSection + prevSkip, charsPerSection - prevSkip);
                }
                
                NSString *nextT = [content.text substringWithRange:nextFileRange];
                NSCharacterSet *letters = [NSCharacterSet alphanumericCharacterSet];
                unichar c = [nextT characterAtIndex:0];
                if([letters characterIsMember:c]){
                    NSRange range = [nextT rangeOfString:@" "];
                    skipCharTo = range.location;
                }
                
                
                fileRange = NSMakeRange(nextText * charsPerSection + prevSkip, charsPerSection + skipCharTo - prevSkip);
            }
            NSString *text = [[content.text substringWithRange: fileRange] stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceCharacterSet]];
            
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
        else if((r == 1 && imagesAdded != 0) || textAdded == 0)
        {
            if(newRow == 0)
                nextY = nextYFirstColumn;
            else
                nextY = nextYSecondColumn;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(nextX, nextY, (screenSize.width - margins) / 2 - 5, 300)];
            NSString *path = [[NSBundle mainBundle] pathForResource: @"placeholder" ofType: @"png"];
            imageView.image = [[UIImage alloc] initWithContentsOfFile: path];
            [self downloadContentPictures:content.images[content.images.count - imagesAdded] forImageView:imageView];
            [scrollView addSubview:imageView];
            heightToAdd = 300;
            imagesAdded--;
        }
        
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
    scrollView.delaysContentTouches = NO;
    [scrollView addSubview:title];
    [scrollView addSubview:author];
    [scrollView addSubview:date];
    [scrollView addSubview:sourceName];
    [scrollView addSubview:sourceImage];
    [scrollView addSubview:btnFacebook];
    [scrollView addSubview:btnTwitter];
    
 
    for(NSString *videoUrl in content.videos)
    {
        NSString *urlStr = [videoUrl stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, nextY, screenSize.width - margins, 400)];
        [webView loadRequest:request];
        scrollHeight += 400;
        nextY += 400;
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
            imageView.image = image;
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
    
    nextY += 10;
    scrollHeight += 10;
    
    UIButton *btnTwitter = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - margins - 2 * socialButtonWidth - 10, nextY, socialButtonWidth, socialButtonHeight)];
    UIButton *btnFacebook = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - margins - socialButtonWidth, nextY, socialButtonWidth, socialButtonHeight)];
    
    [self setSocialButtons:btnTwitter Facebook:btnFacebook];
    
    scrollHeight += socialButtonHeight;
    nextY += socialButtonHeight;
    
    nextY += 10;
    scrollHeight += 10;
    
    CGSize maximumLabelSize = CGSizeMake(screenSize.width - margins, FLT_MAX);
    
    int textLength = content.text.length;
    int charsPerSection = 500;
    int sections = textLength / charsPerSection + 1 + content.images.count;
    int nextText = 0;
    int textAdded = textLength / charsPerSection + 1;
    //int videosAdded = content.videos.count;
    int imagesAdded = content.images.count;
    int skipCharTo = 0;
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 70, screenSize.width, screenSize.height)];
    scrollView.backgroundColor = [UIColor whiteColor];
    
    for(int i = 0; i < sections; i++){
        
        int heightToAdd = 0;
        int r = arc4random() % 2;
        
        if(i == 0 || (textAdded != 0 && r == 0) || (imagesAdded == 0)){
            
            UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(5, nextY, screenSize.width - margins - 5, 700)];
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:18];
            textView.font = font;
            
            NSRange fileRange;
            if(nextText * charsPerSection + charsPerSection > textLength)
            {
                fileRange = NSMakeRange(nextText * charsPerSection + skipCharTo, textLength - nextText * charsPerSection - skipCharTo);
            }
            else {
                
                int prevSkip = skipCharTo;
                NSRange nextFileRange;
                
                if((nextText + 1) * charsPerSection + charsPerSection > textLength)
                {
                    nextFileRange = NSMakeRange((nextText + 1) * charsPerSection + prevSkip, textLength - (nextText + 1) * charsPerSection - prevSkip);
                }
                else {
                    nextFileRange = NSMakeRange((nextText + 1) * charsPerSection + prevSkip, charsPerSection - prevSkip);
                }
                
                NSString *nextT = [content.text substringWithRange:nextFileRange];
                NSCharacterSet *letters = [NSCharacterSet alphanumericCharacterSet];
                unichar c = [nextT characterAtIndex:0];
                if([letters characterIsMember:c]){
                    NSRange range = [nextT rangeOfString:@" "];
                    skipCharTo = range.location;
                }
                
                
                fileRange = NSMakeRange(nextText * charsPerSection + prevSkip, charsPerSection + skipCharTo - prevSkip);
            }
            
            
            NSString *text = [[content.text substringWithRange: fileRange] stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceCharacterSet]];
            
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
        else if((r == 1 && imagesAdded != 0) || textAdded == 0)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, nextY, screenSize.width - margins - 5, 300)];
            NSString *path = [[NSBundle mainBundle] pathForResource: @"placeholder" ofType: @"png"];
            imageView.image = [[UIImage alloc] initWithContentsOfFile: path];
            [self downloadContentPictures:content.images[content.images.count - imagesAdded] forImageView:imageView];
            [scrollView addSubview:imageView];
            heightToAdd = 300;
            imagesAdded--;
        }
        
        nextY += heightToAdd + 10;
        scrollHeight += heightToAdd + 10;
        
    }
    
    
    scrollView.contentSize = CGSizeMake(screenSize.width, scrollHeight);
    scrollView.delegate = self;
    scrollView.scrollEnabled = YES;
    scrollView.delaysContentTouches = NO;
    [scrollView addSubview:title];
    [scrollView addSubview:author];
    [scrollView addSubview:date];
    [scrollView addSubview:sourceName];
    [scrollView addSubview:sourceImage];
    [scrollView addSubview:btnFacebook];
    [scrollView addSubview:btnTwitter];
    
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
            [UIView animateWithDuration:0.25 animations:^{
                scrollView.frame = CGRectMake(10, 70, screenSize.width, screenSize.height);
            }];
        }
        else if(self.lastContentOffset > 0)
        {
            [self.navigationController setNavigationBarHidden: YES animated:YES];
            [UIView animateWithDuration:0.25 animations:^{
                scrollView.frame = CGRectMake(10, 30, screenSize.width, screenSize.height);
            }];
        }
    }
}

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
    
    self.navigationController.navigationBar.tintColor = [self colorFromHexString:@"#FFFFFF"];
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
                                                            message:@"Don't worry, we're working on it"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    // 5
    [operation start];
}

-(void)saveArticle
{
    if([SavedArticlesHelper isArticleSaved:self.newsArticle]){
        [SavedArticlesHelper removeArticle:self.newsArticle];
        [self scheduleNotification:@"Removed"];
    }
    else{
        [SavedArticlesHelper addArticle:_newsArticle];
        [self scheduleNotification:@"Saved"];
    }
    
    [self setNavigationBarButtonRight];
}

-(void)scheduleNotification: (NSString *)message{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    
    NSDate *now = [NSDate date];
    //int daysToAdd = 14;
    NSDate *notifyDate = [now dateByAddingTimeInterval:1];
    
    localNotif.fireDate = notifyDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
	// Notification details
    NSRange titleRange = NSMakeRange(0, 20);
    
    localNotif.alertBody = [NSString stringWithFormat:@"%@ article %@", message, [self.newsArticle.title substringWithRange:titleRange] ];
	// Set the action button
    localNotif.alertAction = @"View";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
	// Specify custom data for the notification
    //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    //localNotif.userInfo = infoDict;
    
	// Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self setBarTintColor];
}

-(UIColor *)getProgressColor
{
    UIColor *color;
    
    if([self.newsArticle.sourceName isEqualToString:@"Engadget"])
        color = [self colorFromHexString:@"#1797FF"];
    else if([self.newsArticle.sourceName isEqualToString:@"Wired"])
        color = [self colorFromHexString:@"#FF63F2"];
    else if([self.newsArticle.sourceName isEqualToString:@"The Verge"])
        color = [self colorFromHexString:@"#FF5E74"];
    else if([self.newsArticle.sourceName isEqualToString:@"TechCrunch"])
        color = [self colorFromHexString:@"#6DCF13"];
    
    return color;
}

-(void)setBarTintColor
{
    if([self.newsArticle.sourceName isEqualToString:@"Engadget"])
        self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#1797FF"];
    else if([self.newsArticle.sourceName isEqualToString:@"Wired"])
        self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#FF63F2"];
    else if([self.newsArticle.sourceName isEqualToString:@"The Verge"])
        self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#FF5E74"];
    else if([self.newsArticle.sourceName isEqualToString:@"TechCrunch"])
        self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#6DCF13"];
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
    self.navigationController.navigationBar.tintColor = [self colorFromHexString:@"#FFFFFF"];
    
    UISwipeGestureRecognizer *mSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMaster)];
    
    [mSwipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [[self view] addGestureRecognizer:mSwipeUpRecognizer];
}

-(void)showMaster
{
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    //}
}

-(void)setNavigationBarButtonRight
{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"plus-32" ofType: @"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile: path];
    if([SavedArticlesHelper isArticleSaved:self.newsArticle])
        image = [ImageHelper imageRotatedByDegrees:image deg:45];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(saveArticle)];
    [self.navigationItem setRightBarButtonItem:barButton];
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
