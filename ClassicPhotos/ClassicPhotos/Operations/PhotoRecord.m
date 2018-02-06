//
//  PhotoOperations.m
//  ClassicPhotos
//
//  Created by Roman Ustiantcev on 06/02/2018.
//  Copyright © 2018 Roman Ustiantcev. All rights reserved.
//

#import "PhotoRecord.h"

@interface PhotoRecord ()

@end

@implementation PhotoRecord

- (instancetype)initWithUrl:(NSString *)name :(NSURL *)url
{
    self = [super init];
    
    if (self) {
        self.name = name;
        self.url = url;
    }
    
    return self;
}

@end
