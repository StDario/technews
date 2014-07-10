//
//  CustomTableViewCell.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/7/14.
//
//

#import "CustomTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomTableViewCell

@synthesize title;
@synthesize backgroundImage;
@synthesize timeAgo;
double secondsInAnHour = 3600;
double secondsInAnDay = 3600 * 24;
double secondsInAnMinute = 60;

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
//    CALayer *sublayer = [CALayer layer];
//    sublayer.shadowOffset = CGSizeMake(0, 5);
//    sublayer.shadowRadius = 5.0;
//    sublayer.shadowColor = [UIColor blackColor].CGColor;
//    sublayer.shadowOpacity = 1.0;
//    sublayer.frame = CGRectMake(0, 0, self.contentView.frame.size.width + 2, self.contentView.frame.size.height + 2);
//    [self.contentView.layer addSublayer:sublayer];
    
    self.contentView.backgroundColor = [self colorFromHexString:@"#CACED9"];
    //self.contentView.backgroundColor = [self colorFromHexString:@"#5EC4DB"];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
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
    NSDate *now = [NSDate date];
    
    NSTimeInterval distance = [now timeIntervalSinceDate:article.publishDate];
    NSInteger days = distance / secondsInAnDay;
    
    if(days <= 0)
    {
        NSInteger hours = distance / secondsInAnHour;
        if(hours <= 0){
            NSInteger minutes = distance / secondsInAnMinute;
            timeAgo.text = [NSString stringWithFormat:@"%im ago", minutes];
        }
        else
            timeAgo.text = [NSString stringWithFormat:@"%ih ago", hours];
    }
    else {
        timeAgo.text = [NSString stringWithFormat:@"%id ago", days];
    }
    
    [self.imageLoader startAnimating];
}



@end
