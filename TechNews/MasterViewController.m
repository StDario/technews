//
//  MasterViewController.m
//  TechNews
//
//  Created by Dario Stojanovski on 7/6/14.
//
//

#import "MasterViewController.h"
#import "NewsArticle.h"
#import "CustomTableViewCell.h"
#import "ImageCache.h"

static NSString * const DownloadUrlString = @"http://skopjeparking.byethost7.com/technews.php?page=";
static NSString * const DownloadImageUrlString = @"http://skopjeparking.byethost7.com/imageScaller.php?url=";

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

int page = 1;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"Cell"];
    _objects = [[NSMutableArray alloc] init];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"5EC4DB"];
    [self downloadNewsArticles:1];
}

-(void)handleResponse:(NSArray *)articles
{
    
    for(id article in articles){
        NewsArticle *newsArticle = [[NewsArticle alloc] init];
        [newsArticle initWithDictionary:article];
        [_objects addObject:newsArticle];
    }
    
    [self.tableView reloadData];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)downloadNewsArticles:(int)page
{
    NSString *urlString = [NSString stringWithFormat:@"%@%i", DownloadUrlString, page];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *result = (NSArray *)responseObject;
        [self handleResponse:result];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving news"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    // 5
    [operation start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 219;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NewsArticle *article = [_objects objectAtIndex:indexPath.row];
    [cell updateCellWithArticle:article];
    
    
    if([[ImageCache sharedImageCache] DoesExist:article.title]){
        [cell updateImage:[[ImageCache sharedImageCache] GetImage:article.title]];
    }
    else {
        dispatch_async(kBgQueue, ^{
            //NSString *imageUrl = [NSString stringWithFormat:@"%@%@", DownloadImageUrlString, article.imageUrl];
            NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:article.imageUrl]];
            if (imgData) {
                UIImage *image = [UIImage imageWithData:imgData];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //CustomTableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        CGSize newSize;
                        newSize.height = 150;
                        newSize.width = 300;
                        UIGraphicsBeginImageContext(newSize);
                        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
                        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        [cell updateImage:newImage];
                        [[ImageCache sharedImageCache] AddImageReference:article.title AddImage:newImage];
                    });
                }
            }
        });
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath isEqual:[NSIndexPath indexPathForRow:[self tableView:self.tableView numberOfRowsInSection:0] -1 inSection:0]]){
        page += _objects.count;
        [self downloadNewsArticles:page];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NewsArticle *object = _objects[indexPath.row];
        self.detailViewController.newsArticle = object;
    }
    else {
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NewsArticle *object = _objects[indexPath.row];
        [[segue destinationViewController] setNewsArticle:object];
    }
}

@end
