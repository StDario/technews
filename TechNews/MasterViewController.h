//
//  MasterViewController.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@class DetailViewController;

@interface MasterViewController : UICollectionViewController <UICollectionViewDelegate>


@property (strong, nonatomic) ACAccount *account;
@property (nonatomic, readwrite) int page;

@end
