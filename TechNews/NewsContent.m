//
//  NewsContent.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/17/14.
//
//

#import "NewsContent.h"
#import "NSString+HTML.h"

@implementation NewsContent

static NSString *const kText = @"text";
static NSString *const kImages = @"images";
static NSString *const kVideos = @"videos";

-(void)initWithDictionary:(NSDictionary *)dict
{
    for (NSString *key in [dict allKeys]) {
        [self setValue:dict[key] forKey:key];
    }
    
    self.text = [self.text stringByDecodingHTMLEntities];
    self.text = [self.text stringByReplacingOccurrencesOfString:@"â€™" withString:@"'"];
    self.text = [self.text stringByReplacingOccurrencesOfString:@"â€œ" withString:@"\""];
    self.text = [self.text stringByReplacingOccurrencesOfString:@"â€" withString:@"\""];
    self.text = [self.text stringByReplacingOccurrencesOfString:@"Ã©" withString:@"é"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.text = [aDecoder decodeObjectForKey:kText];
    self.images = [aDecoder decodeObjectForKey:kImages];
    self.videos = [aDecoder decodeObjectForKey:kVideos];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.text forKey:kText];
    [aCoder encodeObject:self.images forKey:kImages];
    [aCoder encodeObject:self.videos forKey:kVideos];
}

@end
