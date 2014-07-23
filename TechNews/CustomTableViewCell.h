//
//  CustomTableViewCell.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/7/14.
//
//

#import <UIKit/UIKit.h>
#import "NewsArticle.h"

@interface CustomTableViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoader;
@property (nonatomic, weak) IBOutlet UIView *content;
@property (nonatomic, weak) IBOutlet UILabel *timeAgo;
@property (nonatomic, readwrite) int shadowAdded;
@property (nonatomic, weak) IBOutlet UIImageView *sourceImage;

- (void)initCell;
- (void)clearCell;
- (void)updateCellWithArticle:(NewsArticle *)article;
- (void)updateImage:(UIImage *)image;

@end
