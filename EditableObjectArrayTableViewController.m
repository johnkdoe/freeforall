//
//  EditableObjectArrayTableViewController.m
//  xolawareUI
//
//  Created by kb on 2012.11.10.

#import "xolawareOpenSourceCopyright.h"

#import "EditableObjectArrayTableViewController.h"

@implementation EditableObjectArrayTableViewController

//- (void)setObjects:(NSArray*)newObjects {
//	int delta;
//	__weak NSArray* _objects = _editableObjectsDataSource.editableObjects;
//	NSUInteger newCount = newObjects.count;
//	NSUInteger oldCount = _objects.count;
//	if (_objects && newObjects && 0 < (delta = newCount - oldCount))
//	{
//		NSArray* newObjects1N = [newObjects subarrayWithRange:NSMakeRange(0, oldCount)];
//		if ([newObjects1N isEqualToArray:_objects])
//		{
//			// update tableView
//			NSMutableArray* newIndexPaths = [NSMutableArray arrayWithCapacity:delta];
//			for (int i = oldCount; i < newCount ; ++i)
//				[newIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
//
//			[self.tableView beginUpdates];
//			[[self editableObjectsDataSource] setEditableObjects:newObjects];
//			[self.tableView insertRowsAtIndexPaths:newIndexPaths
//								  withRowAnimation:UITableViewRowAnimationBottom];
//			[self.tableView endUpdates];
//
//			return;
//		}
//	}
//
//	[self.editableObjectsDataSource setEditableObjects:newObjects];
//
//	if (!self.isEditing)
//		[self.tableView reloadData];
//}

#pragma mark - public implementation

- (void)removeObjectFromObjects:(id)object {
	NSMutableArray* objectsMinusThis = _editableObjectsDataSource.editableObjects.mutableCopy;
	[objectsMinusThis removeObject:object];
	[_editableObjectsDataSource setEditableObjects:objectsMinusThis.copy];
}

- (void)removeObjectFromObjectsAtIndex:(NSUInteger)index {
	NSMutableArray* objectsMinusThis = _editableObjectsDataSource.editableObjects.mutableCopy;
	[objectsMinusThis removeObjectAtIndex:index];
	[_editableObjectsDataSource setEditableObjects:objectsMinusThis.copy];
}

#pragma mark - view controller life cycle overrides

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//	if (editing && self.tableView.indexPathForSelectedRow)
//		self.rowPriorToEditing = self.tableView.indexPathForSelectedRow.row;
//	else
//		self.rowPriorToEditing = NSNotFound;
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;     // our number of sections for a simple array of objects
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _editableObjectsDataSource.editableObjects.count;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)	 tableView:(UITableView*)tableView
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
	 forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self removeObjectFromObjectsAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
	}
}

-(void)		 tableView:(UITableView*)tableView
	moveRowAtIndexPath:(NSIndexPath*)sourceIndexPath
		   toIndexPath:(NSIndexPath*)destinationIndexPath
{
	NSMutableArray* reorderedObjects = _editableObjectsDataSource.editableObjects.mutableCopy;
	NSObject* objectToMove = [reorderedObjects objectAtIndex:sourceIndexPath.row];
	[reorderedObjects removeObjectAtIndex:sourceIndexPath.row];
	[reorderedObjects insertObject:objectToMove atIndex:destinationIndexPath.row];
	[_editableObjectsDataSource setEditableObjects:reorderedObjects.copy];
}

@end
