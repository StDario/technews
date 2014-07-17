//
//  NewsContent.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/17/14.
//
//

#import "NewsContent.h"

@implementation NewsContent


-(void)initWithDictionary:(NSDictionary *)dict
{
    for (NSString *key in [dict allKeys]) {
        [self setValue:dict[key] forKey:key];
    }
}

@end
