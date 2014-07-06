//
//  DownloadHelper.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import "DownloadHelper.h"

@implementation DownloadHelper


static NSString * const DownloadUrlString = @"http://skopjeparking.byethost7.com/technews.php";


- (id)downloadNewsArticles
{
    NSURL *url = [NSURL URLWithString:DownloadUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *result = (NSDictionary *)responseObject;
        NSArray *results = result[@"results"];
        //[self handleResponse:results];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    // 5
    [operation start];
    
    return nil;
}


@end
