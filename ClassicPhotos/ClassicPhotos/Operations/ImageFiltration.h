//
//  ImageFiltration.h
//  ClassicPhotos
//
//  Created by Roman Ustiantcev on 06/02/2018.
//  Copyright © 2018 Roman Ustiantcev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoOperations.h"
#import "RecordState.h"

@interface ImageFiltration : NSOperation

@property (nonatomic, assign) PhotoOperations *photoRecord;

- (instancetype)initWithRecord:(PhotoOperations *)record;

@end
