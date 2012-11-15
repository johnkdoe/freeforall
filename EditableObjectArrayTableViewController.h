//
//  EditableObjectArrayTableViewController.h
//  xolawareUI
//
//  Created by kb on 2012.11.10.

#import "xolawareOpenSourceCopyright.h"

#import <UIKit/UIKit.h>

@protocol EditableObjectArrayDataSource
@property (strong, nonatomic) NSArray* editableObjects;
@end

@interface EditableObjectArrayTableViewController : UITableViewController

@property (strong, nonatomic)	id<EditableObjectArrayDataSource> editableObjectsDataSource;

// override these including a call to [super …] to do this combined with syncing with server
- (void)removeObjectFromObjects:(id)object;
- (void)removeObjectFromObjectsAtIndex:(NSUInteger)index;

@end
