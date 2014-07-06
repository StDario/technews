//
//  MasterViewController.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
