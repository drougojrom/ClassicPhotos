//
//  ListViewController.m
//  ClassicPhotos
//
//  Created by Roman Ustiantcev on 06/02/2018.
//  Copyright © 2018 Roman Ustiantcev. All rights reserved.
//

#import "ListViewController.h"
#import <CoreImage/CoreImage.h>
#import "ImageDownloader.h"
#import "ImageFiltration.h"

@interface ListViewController ()

@end

@implementation ListViewController
{
    NSURL *dataSourceURL;
}
@synthesize photos = _photos;
@synthesize pendingOperations = _pendingOperations;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Classic photos";
    dataSourceURL = [NSURL URLWithString:@"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist"];
    [self fetchPhotoDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)photos {
    if (!_photos) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

- (PendingOperations *)pendingOperations
{
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (UIImage *)applySepiaFilter:(UIImage *)unfilteredImage
{
    NSData *inputImage = UIImagePNGRepresentation(unfilteredImage);
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"sepia"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@0.8 forKey:@"inputIntensity"];
    
    return [UIImage imageWithCGImage:[context createCGImage:filter.outputImage fromRect:filter.outputImage.extent]];
}

- (void)fetchPhotoDetails
{
    NSURLRequest *request = [NSURLRequest requestWithURL:dataSourceURL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            NSDictionary *datasourceDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
            
            [datasourceDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
                NSString *name = key;
                NSURL *url = [NSURL URLWithString:value];
                PhotoOperations *record = [[PhotoOperations alloc] initWithUrl:name :url];
                [self.photos addObject:record];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
        if (error != nil) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Something wrong has happenned" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL];
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:NULL];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
    
    [task resume];
    [session finishTasksAndInvalidate];
}

- (void)startOperationsForPhotoRecord:(PhotoOperations *)photo forIndexPath:(NSIndexPath *)indexPath
{
    if (photo.state == New) {
        [self startDownloadForRecord:photo forIndexPath:indexPath];
    } else if (photo.state == Downloaded) {
        [self startFiltrationForRecord:photo forIndexPath:indexPath];
    } else {
        NSLog(@"Do nothing");
    }
}

- (void)startDownloadForRecord:(PhotoOperations *)photo forIndexPath:(NSIndexPath *)indexPath
{
    if (self.pendingOperations.downloadInProgress[indexPath]) {
        return;
    }
    
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithRecord:photo];
    [imageDownloader setCompletionBlock:^{
        if (imageDownloader.cancelled) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pendingOperations.downloadInProgress removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
    }];
    
    self.pendingOperations.downloadInProgress[indexPath] = imageDownloader;
    [self.pendingOperations.downloadQueue addOperation:imageDownloader];
}

- (void)startFiltrationForRecord:(PhotoOperations *)photo forIndexPath:(NSIndexPath *)indexPath
{
    if (self.pendingOperations.filtrationsInProgress[indexPath]) {
        return;
    }
    
    ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithRecord:photo];
    imageFiltration.completionBlock = ^{
        if (imageFiltration.cancelled) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
    };
    self.pendingOperations.filtrationsInProgress[indexPath] = imageFiltration;
    [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
}

- (void)suspendAllOperations
{
    self.pendingOperations.downloadQueue.suspended = YES;
    self.pendingOperations.filtrationQueue.suspended = YES;
}

- (void)resumeAllOperations
{
    self.pendingOperations.downloadQueue.suspended = NO;
    self.pendingOperations.filtrationQueue.suspended = NO;
}

- (void)loadImagesForOnscreenCells
{
    NSArray *pathsArray = [self.tableView indexPathsForVisibleRows];
    NSMutableSet *allPendingOperations = [[NSMutableSet alloc] initWithObjects:
                                          self.pendingOperations.downloadInProgress.allKeys,
                                          self.pendingOperations.filtrationsInProgress.allKeys,
                                          nil];
    NSMutableSet *toBeCancelled = allPendingOperations;
    NSSet *visiblePaths = [[NSSet alloc] initWithArray:pathsArray];
    [toBeCancelled minusSet: visiblePaths];
    
    NSMutableSet *toBeStarted = [[NSMutableSet alloc] initWithSet:visiblePaths];
    [toBeStarted minusSet:allPendingOperations];
    
    for (NSIndexPath *indexPath in toBeCancelled) {
        if (self.pendingOperations.downloadInProgress[indexPath]) {
            [self.pendingOperations.downloadInProgress[indexPath] cancel];
        }
        [self.pendingOperations.downloadInProgress removeObjectForKey:indexPath];
        
        if (self.pendingOperations.filtrationsInProgress[indexPath]) {
            [self.pendingOperations.filtrationsInProgress[indexPath] cancel];
        }
        [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
    }
    
    for (NSIndexPath *indexPath in toBeStarted) {
        PhotoOperations *photo = self.photos[indexPath.row];
        [self startOperationsForPhotoRecord:photo forIndexPath:indexPath];
    }
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.photos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    if (cell.accessoryView == nil) {
        cell.accessoryView = indicator;
    }
    
    PhotoOperations *photo = self.photos[indexPath.row];
    cell.textLabel.text = photo.name;
    cell.imageView.image = photo.image;
    
    switch (photo.state) {
            case Filtered:
            [indicator stopAnimating];
            break;
            case Failed:
            [indicator stopAnimating];
            cell.textLabel.text = @"Failed to download";
        default:
            [indicator startAnimating];
            if (!self.tableView.isDragging && !self.tableView.isDecelerating) {
                [self startOperationsForPhotoRecord:photo forIndexPath:indexPath];
            }
            break;
    }
    return cell;
}

#pragma mark scrollView delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self suspendAllOperations];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self loadImagesForOnscreenCells];
        [self resumeAllOperations];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenCells];
    [self resumeAllOperations];
}

@end
