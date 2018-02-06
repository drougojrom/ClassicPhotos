//
//  ImageDownloader.m
//  ClassicPhotos
//
//  Created by Roman Ustiantcev on 06/02/2018.
//  Copyright © 2018 Roman Ustiantcev. All rights reserved.
//

#import "ImageDownloader.h"

@implementation ImageDownloader

- (instancetype)initWithRecord:(PhotoOperations *)record
{
    self = [super init];
    
    if (self) {
        self.photoRecord = record;
    }
    
    return self;
}

-(void)main
{
    if (self.cancelled) {
        return;
    }
    
    NSData *imageData = [NSData dataWithContentsOfURL:self.photoRecord.url];
    
    if (self.cancelled) {
        return;
    }
    
    if ([imageData length] > 0) {
        self.photoRecord.image = [UIImage imageWithData:imageData];
        self.photoRecord.state = Downloaded;
    } else {
        self.photoRecord.state = Failed;
        self.photoRecord.image = [UIImage imageNamed:@"Failder"];
    }
}


@end
