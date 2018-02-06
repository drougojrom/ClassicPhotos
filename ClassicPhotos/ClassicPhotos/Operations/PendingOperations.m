//
//  PendingOperations.m
//  ClassicPhotos
//
//  Created by Roman Ustiantcev on 06/02/2018.
//  Copyright © 2018 Roman Ustiantcev. All rights reserved.
//

#import "PendingOperations.h"
#import <UIKit/UIKit.h>

@interface PendingOperations()

@end

@implementation PendingOperations

@synthesize downloadQueue = _downloadQueue;
@synthesize filtrationQueue = _filtrationQueue;

- (NSOperationQueue *)downloadQueue
{
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Download queue";
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    
    return _downloadQueue;
}

- (NSOperationQueue *)filtrationQueue
{
    if (!_filtrationQueue) {
        _filtrationQueue = [[NSOperationQueue alloc] init];
        _filtrationQueue.name = @"Image Filtration queue";
        _filtrationQueue.maxConcurrentOperationCount = 1;
    }
    return _filtrationQueue;
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    return self;
}


@end
