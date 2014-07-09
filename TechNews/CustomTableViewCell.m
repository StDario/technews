//
//  CustomTableViewCell.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/7/14.
//
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

@synthesize title;
@synthesize backgroundImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)clearCell
{
    //[self.imageLoader startAnimating];
    self.backgroundImage.image = nil;
    self.title.text = @"Name";
}

- (void)updateImage:(UIImage *)image
{
    [self.imageLoader stopAnimating];
    self.backgroundImage.image = image;
}


- (void)updateCellWithArticle:(NewsArticle *)article
{
    self.title.text = article.title;
    [self.imageLoader startAnimating];
}

@end
