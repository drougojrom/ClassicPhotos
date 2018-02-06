//
//  ListViewController.h
//  ClassicPhotos
//
//  Created by Roman Ustiantcev on 06/02/2018.
//  Copyright © 2018 Roman Ustiantcev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoOperations.h"
#import "PendingOperations.h"

@interface ListViewController : UITableViewController
@property (nonatomic, readonly) NSMutableArray *photos;
@property (nonatomic, readonly) PendingOperations *pendingOperations;
@end
