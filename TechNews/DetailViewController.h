//
//  DetailViewController.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import <UIKit/UIKit.h>
#import "NewsArticle.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NewsArticle *newsArticle;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet UITextView *articleContent;

@property (weak, nonatomic) IBOutlet UILabel *sourceName;

@property (weak, nonatomic) IBOutlet UIImageView *sourceImage;

@property (weak, nonatomic) IBOutlet UILabel *publishDate;

@property (weak, nonatomic) IBOutlet UILabel *author;

@property (weak, nonatomic) IBOutlet UILabel *articleTitle;

@property (weak, nonatomic) IBOutlet UIImageView *articleImage;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;

@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@end
