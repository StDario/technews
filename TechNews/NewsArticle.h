//
//  NewsArticle.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import <Foundation/Foundation.h>

@interface NewsArticle : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *publishDate;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *sourceName;

-(void)initWithDictionary:(NSDictionary *)dict;

@end
