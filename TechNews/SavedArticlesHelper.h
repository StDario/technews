//
//  SavedArticlesHelper.h
//  TechNews
//
//  Created by Dario Stojanovski on 7/21/14.
//
//

#import <Foundation/Foundation.h>
#import "NewsArticle.h"

@interface SavedArticlesHelper : NSObject

+ (void)saveArticlesData:(NSMutableArray *)articles;
+ (NSMutableArray *)loadArticleData;
+ (void)addArticle:(NewsArticle *)article;
+ (void)removeArticle:(NewsArticle *)article;
+ (BOOL)isArticleSaved:(NewsArticle *)article;

@end
