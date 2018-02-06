//
//  PhotoOperations.h
//  ClassicPhotos
//
//  Created by Roman Ustiantcev on 06/02/2018.
//  Copyright © 2018 Roman Ustiantcev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordState.h"

@interface PhotoOperations : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic) enum PhotoRecordState state;
@property (nonatomic) UIImage *image;

- (instancetype)initWithUrl:(NSString *)name :(NSURL *)url;

@end
