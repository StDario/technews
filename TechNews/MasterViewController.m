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
#import "ImageHelper.h"

static NSString * const DownloadUrlString = @"http://skopjeparking.byethost7.com/technews.php?page=";
static NSString * const DownloadImageUrlString = @"http://skopjeparking.byethost7.com/imageScaller.php?url=";

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
bool showingSavedArticles = false;
bool downloaded = false;
int previousCount = 0;
int articlesPerDownload = 12;

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

@synthesize page;


- (void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)loadFacebookAccount
{
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
    [self.collectionView reloadData];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    [self showBarButtonLeft];
    self.navigationItem.rightBarButtonItem = nil;
    showingSavedArticles = true;
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#CF69FF"];
}

-(void)loadNewArticles
{
    [_objects removeAllObjects];
    [self downloadNewsArticles:1];
    page = 1;
    [self showBarButtonRight];
    self.navigationItem.leftBarButtonItem = nil;
    showingSavedArticles = false;
    //[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0] ];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#5EC4DB"];
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
    [self showBarButtonRight];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
//        self.collectionView.frame = CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height);
//        self.view.backgroundColor = [self colorFromHexString:@"#CACED9"];
    }
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle: nil] forCellWithReuseIdentifier:@"Cell"];
    _objects = [[NSMutableArray alloc] init];
    self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"5EC4DB"];
    self.collectionView.backgroundColor = [self colorFromHexString:@"#CACED9"];
    
    [self loadFacebookAccount];
    [self loadTwitterAccount];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    
    
    
    if(!showingSavedArticles)
        [self downloadNewsArticles:1];
    
    page = 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        {
            return UIEdgeInsetsMake(0, 20, 0, 20);
        }
        else
        {
            return UIEdgeInsetsMake(0, 30, 0, 30);
        }
    }
    else
    {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))){
        return 0;
    }
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))){
        return 0;
    }
    return 10.0;
}

-(void)handleResponse:(NSArray *)articles
{
    
    for(id article in articles){
        NewsArticle *newsArticle = [[NewsArticle alloc] init];
        [newsArticle initWithDictionary:article];
        [_objects addObject:newsArticle];
    }

    [self.collectionView reloadData];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)downloadNewsArticles:(int)pageNum
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *twitterUsername;
    NSString *facebookUsername;
    
    if([defaults objectForKey:@"twitterUsername"] != nil)
        twitterUsername = [defaults objectForKey:@"twitterUsername"];
    else
        twitterUsername = @"";
    
    if([defaults objectForKey:@"facebookUsername"] != nil)
        facebookUsername = [defaults objectForKey:@"facebookUsername"];
    else
        facebookUsername = @"";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%i&twitterUsername=%@&facebookUsername=%@", DownloadUrlString, pageNum, twitterUsername, facebookUsername];
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _objects.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 252;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    
    if(self.navigationItem.leftBarButtonItem == nil)
    {
        [_objects removeAllObjects];
        [self downloadNewsArticles:1];
    }
    
    [self.collectionView reloadData];
    page = 1;
    
}

- (BOOL)splitViewController:(UISplitViewController*)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *oldCell = (CustomTableViewCell *)cell;
    NSString *path = [[NSBundle mainBundle] pathForResource: @"placeholder" ofType: @"png"];
    [oldCell updateImage:[[UIImage alloc] initWithContentsOfFile: path]];
    [oldCell updateTitleColor:[UIColor blackColor]];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = (CustomTableViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NewsArticle *article = [_objects objectAtIndex:indexPath.row];
    [cell updateCellWithArticle:article];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"placeholder" ofType: @"png"];
    [cell updateImage:[[UIImage alloc] initWithContentsOfFile: path]];
    [cell updateTitleColor:[UIColor blackColor]];
    
    
    if([[ImageCache sharedImageCache] DoesExist:article.title]){
        [cell updateImage:[[ImageCache sharedImageCache] GetImage:article.title]];
        [cell updateTitleColor:[UIColor whiteColor]];
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
                        UIImage* newImage = [ImageHelper scaleImage:image toSize:newSize];
                        newImage = [ImageHelper changeImage:newImage withStartColor:[UIColor blackColor] withEndColor:[UIColor whiteColor]];
                        [cell updateImage:newImage];
                        [cell updateTitleColor:[UIColor whiteColor]];
                        [[ImageCache sharedImageCache] AddImageReference:article.title AddImage:newImage];
                        
                    });
                }
                else {
                    NSString *path = [[NSBundle mainBundle] pathForResource: @"placeholder" ofType: @"png"];
                    [cell updateImage:[[UIImage alloc] initWithContentsOfFile: path]];
                    [cell updateTitleColor:[UIColor blackColor]];
                }
            }
        });
    }
    
    if(!showingSavedArticles){
        if([indexPath isEqual:[NSIndexPath indexPathForRow:[self collectionView:self.collectionView numberOfItemsInSection:0] -1 inSection:0]]){
            page += articlesPerDownload;
            [self downloadNewsArticles:page];
        }
        else if(indexPath.row == _objects.count - 1){
            page += articlesPerDownload;
            previousCount = _objects.count;
            [self downloadNewsArticles:page];
            downloaded = true;
        }
    }
    
    return cell;
}

-(void)viewWillAppear:(BOOL)animated
{
    if(showingSavedArticles)
        self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#CF69FF"];
    else
        self.navigationController.navigationBar.barTintColor = [self colorFromHexString:@"#5EC4DB"];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
        NewsArticle *object = _objects[indexPath.row];
        [[segue destinationViewController] setNewsArticle:object];
    }
}

@end
