//
//  ImageCache.h
//  TravelAndTourism
//
//  Created by Dario Stojanovski on 4/8/14.
//
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

@property (nonatomic, retain) NSCache *imgCache;


#pragma mark - Methods

+ (ImageCache*)sharedImageCache;
- (void) AddImageReference:(NSString *)imageURL AddImage:(UIImage *)image;
- (UIImage*) GetImage:(NSString *)imageURL;
- (BOOL) DoesExist:(NSString *)imageURL;

@end