//
//  DEMemoryWindowController.m
//  dqnEmulater
//
//  Created by ito on 2008/12/27.
//  Copyright 2008 Ito. All rights reserved.
//

#import "DEMemoryWindowController.h"


@implementation DEMemoryWindowController


@synthesize delegate = _delegate;


NSString* const kTableMemIDAddress = @"addr";
NSString* const kTableMemIDContentFormat = @"add%d";
static NSUInteger kTableMemIDContentHash[16];

#define kTableMemWidth 40
#define kTableMemMaxWidth 60

#define MemoryDataOfRowAndColumn(row, col) (*(_memory+((row)*0x10)+(col)))
#define RowIndexOfAddress(addr) ((addr)/0x10)
#define ColIndexOfAddress(addr) ((addr)%0x10)

+(void)initialize
{
	// Create table column identifier hash
	NSInteger iHex;
	for (iHex = 0; iHex < 16; iHex++) {
		kTableMemIDContentHash[iHex] = [[NSString stringWithFormat:kTableMemIDContentFormat, iHex] hash];
	}
}

- (void)windowDidLoad
{
	//NSLog(@"windowWillLoad Memory Ctrler");
	NSArray* columns = [_memoryTable tableColumns];
	for (NSTableColumn* col in columns) {
		if (![[col identifier] isEqualToString:kTableMemIDAddress]) {
			[col setMinWidth:kTableMemWidth];
			[col setMaxWidth:kTableMemMaxWidth];
			[col setWidth:kTableMemWidth];
		}
	}
	
	_hilightaddr = -1;
	
	[self showWindow:self];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return [NSString stringWithFormat:NSLocalizedString(@"%@ - Memory Map", nil), displayName];
}

- (void) dealloc
{
	[_changedAddress release];
	NSLog(@"Release Memory Ctrler");
	[super dealloc];
}



#pragma mark Setter/Getter

- (void)setMemory:(uint16_t*)aMem
{
	_memory = aMem;
	[_memoryTable reloadData];
}


- (void)setMemoryDataChangedAddress:(NSArray*)aAddr
{
	if (aAddr != _changedAddress) {
		[_changedAddress release];
		_changedAddress = [aAddr retain];
	}
	[_memoryTable reloadData];
}

- (void)setMemoryDataHighlighted:(NSInteger)addr
{
	_hilightaddr = addr;
	[_memoryTable reloadData];
}


#pragma mark Memory Table delegate and data source


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return 4096;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	// Show addr line
	if ([[aTableColumn identifier] isEqualToString:kTableMemIDAddress]) {
		return [NSString stringWithFormat:@"%04X", rowIndex*(0x10)];
	}
	
	NSUInteger hash = [[aTableColumn identifier] hash];
	uint16_t data = 0xc;
	int i;
	for (i = 0; i < 16; i++) {
		if (kTableMemIDContentHash[i] == hash) {
			data = MemoryDataOfRowAndColumn(rowIndex,i);
			break;
		}
	}
	
	return [NSString stringWithFormat:@"%04X", data];
	
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSUInteger iAddr;
	uint16_t addr;
	
	// Set text color by default
	[aCell setTextColor:[NSColor blackColor]];
	
	NSTextFieldCell* cell = aCell;
	
	for (iAddr = 0; iAddr < [_changedAddress count]; iAddr++) {
		addr = [[_changedAddress objectAtIndex:iAddr] unsignedLongValue];
		if (rowIndex == RowIndexOfAddress(addr)) {
			if ([[aTableColumn identifier] isEqualToString:[NSString stringWithFormat:kTableMemIDContentFormat, ColIndexOfAddress(addr)]]) {
				//NSLog(@"changed %x row %d col %x", addr, addr/0x10, addr%0x10);
				[cell setTextColor:[NSColor redColor]];
//				[aCell setSelectedRange:NSMakeRange(0, 10)];
//				[aCell centerSelectionInVisibleArea:self];
			//	[[aCell window] makeFirstResponder:self];
			}
		}
	}
	
	if (_hilightaddr >= 0) {
		if (rowIndex == RowIndexOfAddress(_hilightaddr)) {
			if ([[aTableColumn identifier] isEqualToString:[NSString stringWithFormat:kTableMemIDContentFormat, ColIndexOfAddress(_hilightaddr)]]) {
				[cell setHighlighted:YES];
			}
		}
	}
	
}	

-(BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	NSInteger row = [aTableView clickedRow];
	NSInteger col = [aTableView clickedColumn];
	if (row >=0 && col >= 0) {
		uint16_t addr = (row*0x10)+(col-1);
		//NSLog(@"select %04x", (row*0x10)+(col-1));
		//NSTableColumn* columns = [aTableView tableColumnWithIdentifier:[NSString stringWithFormat:kTableMemIDContentFormat, addr%0x10]]; 
		//NSTextFieldCell* cell = [columns dataCellForRow:row];
		//NSLog(@"cell %@ col %@",[cell description], [columns description]);
		
		if ([_delegate respondsToSelector:@selector(memorySelected:)]) {
			[_delegate memorySelected:addr];
		}
		//[cell setHighlighted:YES];
		//[aTableView selectRow:row byExtendingSelection:NO];
		//[aTableView selectColumn:col byExtendingSelection:NO];
	}
	return NO;
} 

@end
