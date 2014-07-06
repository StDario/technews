//
//  NewsArticle.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import "NewsArticle.h"

@implementation NewsArticle


-(void)initWithDictionary:(NSDictionary *)dict
{
    for (NSString *key in [dict allKeys]) {
        [self setValue:dict[key] forKey:key];
    }
}

@end
