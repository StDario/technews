//
//  SavedArticlesHelper.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/21/14.
//
//

#import "SavedArticlesHelper.h"
#import "NewsArticle.h"
#import "NewsContent.h"

@implementation SavedArticlesHelper

+ (void)saveArticlesData:(NSMutableArray *)articles
{
    
    NSMutableArray *articlesData = [NSMutableArray arrayWithCapacity:articles.count];
    //NSMutableArray *contentsData = [NSMutableArray arrayWithCapacity:articles.count];
    
    for(int i = 0; i < articles.count; i++){
        NewsArticle *art = articles[i];
        //NewsContent *cont = contents[i];
        NSData *articleData = [NSKeyedArchiver archivedDataWithRootObject:art];
        [articlesData addObject:articleData];
        //NSData *contData = [NSKeyedArchiver archivedDataWithRootObject:cont];
        //[contentsData addObject:contData];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:articlesData forKey:@"articles"];
    //[defaults setObject:contentsData forKey:@"contents"];
}

+ (NSMutableArray *)loadArticleData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *articlesData = [defaults arrayForKey:@"articles"];
    //NSArray *contentsData = [defaults arrayForKey:@"contents"];
    
    if (!articlesData) {
        //        return [[NSMutableArray alloc] init];
        return  nil;
    }
    
    NSMutableArray *articles = [NSMutableArray arrayWithCapacity:articlesData.count];
    //NSMutableArray *contents = [NSMutableArray arrayWithCapacity:contentsData.count];
    
    for (NSData *art in articlesData) {
        NewsArticle *article = (NewsArticle *) [NSKeyedUnarchiver unarchiveObjectWithData:art];
        [articles addObject:article];
    }
    
    return articles;
}

+ (void)addArticle:(NewsArticle *)article
{
    NSMutableArray *articles = [self loadArticleData];
    if (!articles) {
        articles = [[NSMutableArray alloc] init];
    }
    
    [articles addObject:article];
    [self saveArticlesData:articles];
}

+(void)removeAllArticles
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"articles"];
}

+ (void)removeArticle:(NewsArticle *)article;
{
//    NSMutableArray *places = [self loadPlaceData];
//    if (!places) {
//        return;
//    }
//    
//    Place *placeToDelete;
//    for (Place *p in places) {
//        if ([p.name isEqualToString:place.name]) {
//            placeToDelete = p;
//            break;
//        }
//    }
//    [places removeObject:placeToDelete];
//    [self savePlaceData:places];
}

+ (BOOL)isArticleSaved:(NewsArticle *)article;
{
//    NSMutableArray *places = [self loadPlaceData];
//    for (Place *p in places) {
//        if ([p.name isEqualToString:place.name]) {
//            return true;
//        }
//    }
    return false;
}

@end
