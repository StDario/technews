//
//  ImageHelper.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/31/14.
//
//

#import <Foundation/Foundation.h>

@interface ImageHelper : NSObject

+(UIImage *)changeImage:(UIImage *)image withStartColor:(UIColor *)startColor withEndColor:(UIColor *)endColor;
+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
+(UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees;

@end
