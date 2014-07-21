//
//  NewsArticle.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import <Foundation/Foundation.h>

@interface NewsArticle : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *publishDate;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSString *sourceImage;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSString *textEntryId;
@property (nonatomic, strong) NSString *concept;
@property (nonatomic, strong) NSMutableArray *tags;

-(void)initWithDictionary:(NSDictionary *)dict;

@end
