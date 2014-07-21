//
//  NewsContent.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/17/14.
//
//

#import <Foundation/Foundation.h>

@interface NewsContent : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) NSString *text;

-(void)initWithDictionary:(NSDictionary *)dict;

@end
