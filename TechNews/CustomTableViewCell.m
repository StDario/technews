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

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

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
    
//    if(self.shadowAdded == 0){
//        UIView *dropshadowView = [[UIView alloc] init];
//        dropshadowView.backgroundColor = [UIColor colorWithWhite:0.25 alpha:0.55];
//        dropshadowView.frame = CGRectMake( 10.0f, 170.0f, 300.0f, 50.0f);
//        [self.contentView addSubview:dropshadowView];
//        
//        CALayer *layer = dropshadowView.layer;
//        layer.masksToBounds = NO;
//        layer.shadowRadius = 5.0f;
//        layer.shadowOpacity = 0.7f;
//        layer.shadowOffset = CGSizeMake( 0.0f, 11.0f);
//        layer.shouldRasterize = YES;
//        layer.
//        
//        self.shadowAdded = 1;
//        
//        [self.contentView bringSubviewToFront:self.title];
//    }
    
    if(self.shadowAdded == 0)
    {
        //image = [self colorizeImage:image withColor:[UIColor grayColor]];
        //image = [self applyGradientOnImage:image withStartColor:[UIColor lightGrayColor] endColor:[UIColor darkGrayColor]];
        //image = [self changeImage:image withStartColor:[UIColor darkGrayColor] withEndColor:[UIColor whiteColor]];
        //self.backgroundImage.image = image;
        //self.shadowAdded = 1;
    }
    
//    if(self.shadowAdded == 0)
//    {
//        [self addGradientToView:self.contentView];
//    }
}

- (void)addGradientToView:(UIView *)view
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = @[(id)[[UIColor lightGrayColor] CGColor],
                        (id)[[UIColor whiteColor] CGColor]];
    
    [view.layer insertSublayer:gradient atIndex:0];
}

-(UIImage *)changeImage:(UIImage *)image withStartColor:(UIColor *)startColor withEndColor:(UIColor *)endColor
{
    CGFloat scale = image.scale;
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scale, image.size.height * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect rect = CGRectMake(0, 0, image.size.width * scale, image.size.height * scale);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // Create gradient
    
    
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, NULL);
    
    // Apply gradient
    
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0,image.size.height * scale), 0);
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return gradientImage;
}

- (UIImage *)applyGradientOnImage:(UIImage *)image withStartColor:(UIColor *)color1 endColor:(UIColor *)color2 {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    //CGContextDrawImage(context, rect, image.CGImage);
    
    // Create gradient
    NSArray *colors = [NSArray arrayWithObjects:(id)color2.CGColor, (id)color1.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
    
    // Apply gradient
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0, image.size.height), 0);
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
    
    return gradientImage;
}

- (UIImage *)applyColor:(UIColor *)color toImage:(UIImage*)toImage{
    UIGraphicsBeginImageContextWithOptions(toImage.size, NO, toImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, toImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, toImage.size.width, toImage.size.height);
    //CGContextDrawImage(context, rect, toImage.CGImage);
    
    // Create gradient
    NSArray *colors = [NSArray arrayWithObjects:(id)color.CGColor, (id)color.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
    
    // Apply gradient
    CGContextClipToMask(context, rect, toImage.CGImage);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0, toImage.size.height), 0);
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
    
    return coloredImage;
}

-(UIImage *)colorizeImage:(UIImage *)image withColor:(UIColor *)color {
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -area.size.height);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, area, image.CGImage);
    
    [color set];
    CGContextFillRect(context, area);
    
    CGContextRestoreGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGContextDrawImage(context, area, image.CGImage);
    
    UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return colorizedImage;
}

- (void)updateCellWithArticle:(NewsArticle *)article
{
    [self downloadPicture:article.sourceImage forImageView:self.sourceImage];
    
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
