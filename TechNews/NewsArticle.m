//
//  NewsArticle.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import "NewsArticle.h"

@implementation NewsArticle

static NSString *const kTitle = @"title";
static NSString *const kLink = @"link";
static NSString *const kPublishDate = @"publishDate";
static NSString *const kImageUrl = @"imageUrl";
static NSString *const kSourceName = @"sourceName";
static NSString *const kSourceImage = @"sourceImage";
static NSString *const kFile = @"file";
static NSString *const kTextEntryId = @"textEntryId";
static NSString *const kConcept = @"concept";
static NSString *const kTags = @"tags";

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

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.title = [aDecoder decodeObjectForKey:kTitle];
    self.link = [aDecoder decodeObjectForKey:kLink];
    self.publishDate = [aDecoder decodeObjectForKey:kPublishDate];
    self.imageUrl = [aDecoder decodeObjectForKey:kImageUrl];
    self.sourceImage = [aDecoder decodeObjectForKey:kSourceImage];
    self.sourceName = [aDecoder decodeObjectForKey:kSourceName];
    self.file = [aDecoder decodeObjectForKey:kFile];
    self.textEntryId = [aDecoder decodeObjectForKey:kTextEntryId];
    self.concept = [aDecoder decodeObjectForKey:kConcept];
    self.tags = [aDecoder decodeObjectForKey:kTags];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:kTitle];
    [aCoder encodeObject:self.link forKey:kLink];
    [aCoder encodeObject:self.publishDate forKey:kPublishDate];
    [aCoder encodeObject:self.imageUrl forKey:kImageUrl];
    [aCoder encodeObject:self.sourceName forKey:kSourceName];
    [aCoder encodeObject:self.sourceImage forKey:kSourceImage];
    [aCoder encodeObject:self.file forKey:kFile];
    [aCoder encodeObject:self.textEntryId forKey:kTextEntryId];
    [aCoder encodeObject:self.concept forKey:kConcept];
    [aCoder encodeObject:self.tags forKey:kTags];
}

@end
