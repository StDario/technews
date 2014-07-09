//
//  CustomTableViewCell.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/7/14.
//
//

#import <UIKit/UIKit.h>
#import "NewsArticle.h"

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageLoader;
@property (nonatomic, weak) IBOutlet UIView *content;

- (void)initCell;
- (void)clearCell;
- (void)updateCellWithArticle:(NewsArticle *)article;
- (void)updateImage:(UIImage *)image;

@end
