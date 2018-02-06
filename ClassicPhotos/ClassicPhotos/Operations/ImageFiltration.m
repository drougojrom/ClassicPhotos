//
//  ImageFiltration.m
//  ClassicPhotos
//
//  Created by Roman Ustiantcev on 06/02/2018.
//  Copyright © 2018 Roman Ustiantcev. All rights reserved.
//

#import "ImageFiltration.h"
#import <UIKit/UIKit.h>

@implementation ImageFiltration

- (instancetype)initWithRecord:(PhotoRecord *)record
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
    
    if (self.photoRecord.state != Downloaded) {
        return;
    }
    
    UIImage *filteredImage = [self applySepiaFilter:self.photoRecord.image];
    self.photoRecord.image = filteredImage;
    self.photoRecord.state = Filtered;
    
}

- (UIImage *)applySepiaFilter:(UIImage *)unfilteredImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *ciImage = [[CIImage alloc] initWithImage:unfilteredImage];
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@0.8 forKey:@"inputIntensity"];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGRect extent = [result extent];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    
    UIImage *filteredImage = [[UIImage alloc] initWithCGImage:cgImage];
    
    return filteredImage;
}

@end
