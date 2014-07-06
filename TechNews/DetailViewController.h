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

@property (strong, nonatomic) NewsArticle *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
