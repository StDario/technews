//
//  DetailViewController.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import <UIKit/UIKit.h>
#import "NewsArticle.h"
#import "UAProgressView.h"

@interface DetailViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NewsArticle *newsArticle;

@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;

@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;

@property (nonatomic, assign) CGFloat lastContentOffset;

@property (nonatomic, weak) IBOutlet UAProgressView *progressView;

@property (nonatomic, weak) NSTimer *timer;

- (IBAction)shareOnFacebook:(id)sender;

- (IBAction)shareOnTwitter:(id)sender;
@end
