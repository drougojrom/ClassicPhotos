//
//  PhotoOperations.m
//  ClassicPhotos
//
//  Created by Roman Ustiantcev on 06/02/2018.
//  Copyright © 2018 Roman Ustiantcev. All rights reserved.
//

#import "PhotoOperations.h"

@interface PhotoOperations ()

@end

@implementation PhotoOperations

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
