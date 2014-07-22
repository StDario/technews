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
#import "SavedArticlesHelper.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

static NSString * const DownloadUrlString = @"http://skopjeparking.byethost7.com/technews.php?page=";
static NSString * const DownloadImageUrlString = @"http://skopjeparking.byethost7.com/imageScaller.php?url=";

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
bool showingSavedArticles = false;

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

-(void)loadFacebookAccount
{
//    NSDictionary *parameters = [NSDictionary dictionaryWithObject:@"CAAH0XFKBtlIBAKZCG9QmsdzZBDEm4OmmkHtvzYpFVu9Ub027umYg6j778jaDOhZAd9sjrPLJsE7xQNmMFr4m40ZABaRZCPtVTLZBaeNZC9RZBVuxiTkBGRUnG4KzZCc17DFeaekoHkp0wBZAm8vPY9kaZCGx0ndJy9jYWBZCtJ5PI3IMwZAUzBbOYtWvPmMc3UsJJ9twDnk5d368l4biIJAddVedl" forKey:@"access_token"];
//    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];
//    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
//                                            requestMethod:SLRequestMethodGET
//                                                      URL:url
//                                               parameters:parameters];
//    request.account = self.account;
//    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//        NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"Response data: %@", response);
//        NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
//        NSString *username = myDictionary[@"username"];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:username forKey:@"facebookUsername"];
//    }];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookTypeAccount = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                          options:@{ACFacebookAppIdKey: @"550152335111762"}
                                        completion:^(BOOL granted, NSError *error) {
                                            if(granted){
                                                NSArray *accounts = [accountStore accountsWithAccountType:facebookTypeAccount];
                                                ACAccount *facebookAccount = [accounts lastObject];
                                                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                [defaults setObject:facebookAccount.username forKey:@"facebookUsername"];
                                                
                                            }else{
                                                // ouch
                                                NSLog(@"Fail");
                                                NSLog(@"Error: %@", error);
                                            }
                                        }];
}

-(void)loadTwitterAccount
{
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"%@",twitterAccount.username);
                NSLog(@"%@",twitterAccount.accountType);
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:twitterAccount.username forKey:@"twitterUsername"];
            }
        }
    }];
}

-(void)loadSavedArticles
{
    NSMutableArray *articles = [SavedArticlesHelper loadArticleData];
    [_objects removeAllObjects];
    [_objects addObjectsFromArray:articles];
    [self.tableView reloadData];
    
    [self showBarButtonLeft];
    self.navigationItem.rightBarButtonItem = nil;
    showingSavedArticles = true;
}

-(void)loadNewArticles
{
    [_objects removeAllObjects];
    [self downloadNewsArticles:1];
    [self showBarButtonRight];
    self.navigationItem.leftBarButtonItem = nil;
    showingSavedArticles = false;
}

-(void)showBarButtonLeft
{
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(loadNewArticles)];
    [back setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = back;
}

-(void)showBarButtonRight
{
    UIBarButtonItem *saved = [[UIBarButtonItem alloc] initWithTitle:@"Saved" style:UIBarButtonItemStylePlain target:self action:@selector(loadSavedArticles)];
    [saved setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = saved;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    [self showBarButtonRight];

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"Cell"];
    _objects = [[NSMutableArray alloc] init];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"5EC4DB"];
    
    if(!showingSavedArticles)
        [self downloadNewsArticles:1];
    
    //[SavedArticlesHelper removeAllArticles];
    
    [self loadFacebookAccount];
    //[self loadTwitterAccount];
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
    return 252;
}

-(UIImage *)changeImage:(UIImage *)image withStartColor:(UIColor *)startColor withEndColor:(UIColor *)endColor
{
    CGFloat scale = image.scale;
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scale, image.size.height * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect rect = CGRectMake(0, 0, image.size.width * scale, image.size.height * scale);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // Create gradient
    
    
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, NULL);
    
    // Apply gradient
    
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0,image.size.height * scale), 0);
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return gradientImage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NewsArticle *article = [_objects objectAtIndex:indexPath.row];
    [cell updateCellWithArticle:article];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"placeholder" ofType: @"png"];
    [cell updateImage:[[UIImage alloc] initWithContentsOfFile: path]];
    
    
    
    if([[ImageCache sharedImageCache] DoesExist:article.title]){
        [cell updateImage:[[ImageCache sharedImageCache] GetImage:article.title]];
    }
    else {
        dispatch_async(kBgQueue, ^{
            //NSString *imageUrl = [NSString stringWithFormat:@"%@%@", DownloadImageUrlString, article.imageUrl];
            NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:article.imageUrl]];
            if (imgData) {
                UIImage *image = [UIImage imageWithData:imgData];
                if (image && imgData.length > 50) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //CustomTableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        CGSize newSize;
                        newSize.height = 150;
                        newSize.width = 300;
                        UIGraphicsBeginImageContext(newSize);
                        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
                        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        newImage = [self changeImage:newImage withStartColor:[UIColor blackColor] withEndColor:[UIColor whiteColor]];
                        [cell updateImage:newImage];
                        
                        [[ImageCache sharedImageCache] AddImageReference:article.title AddImage:newImage];
                    });
                }
                else {
                    NSString *path = [[NSBundle mainBundle] pathForResource: @"placeholder" ofType: @"png"];
                    [cell updateImage:[[UIImage alloc] initWithContentsOfFile: path]];
                }
            }
        });
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!showingSavedArticles)
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
