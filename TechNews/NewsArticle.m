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
    
    NSString *dateString = dict[@"publishDate"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if([self.sourceName isEqualToString:@"The Verge"]){
        [dateFormat setDateFormat:@"yyyy-LL-dTHH:mm:ss Z"];
    }
    else {
        [dateFormat setDateFormat:@"EE, d LLLL yyyy HH:mm:ss Z"];
    }
    
    self.publishDate = [dateFormat dateFromString: dateString];
}

@end
