//
//  DEMemoryWindowController.h
//  dqnEmulater
//
//  Created by Yusuke Ito on 2008/12/27.
//  Copyright 2008 Yusuke Ito. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DEMemoryWindowController : NSWindowController {
	IBOutlet NSTableView* _memoryTable;
	uint16_t*			_memory; // not owner
	NSMutableArray*			_changedAddress;
	id _delegate;
	NSInteger			_hilightaddr;
}

@property(assign) id delegate;

- (void)setMemory:(uint16_t*)aMem;
- (void)setMemoryDataChangedAddress:(NSArray*)aAddr;
- (void)setMemoryDataHighlighted:(NSInteger)addr;

@end


@interface NSObject(DEMemoryWindowControllerDelegate);

- (void)memorySelected:(uint16_t)addr;

@end
