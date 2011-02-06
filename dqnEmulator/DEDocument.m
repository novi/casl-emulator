//
//  MyDocument.m
//  dqnEmulater
//
//  Created by ito on 2008/12/21.
//  Copyright Ito 2008 . All rights reserved.
//

#import "DEDocument.h"
#import "DEMainWindowController.h"
#import "DEMemoryWindowController.h"
#import "DERegisterWindowController.h"
#import "CSAssembler.h"

#define kMainMemoryBytes (sizeof(uint16_t)*0xffff)

static NSString* errorStr[9];
//static NSString* errorExeStr[];


@interface DEDocument(Private)

- (void)updateRegisterFromEmuRegister:(CMTEmuRegister)reg;

@end


@implementation DEDocument

+(void)initialize
{
	errorStr[0] = NSLocalizedString(@"No Error", nil);
	errorStr[1] = NSLocalizedString(@"Parse error", nil);
	errorStr[2] = NSLocalizedString(@"Label already exist", nil);
	errorStr[3] = NSLocalizedString(@"Label not found", nil);
	errorStr[4] = NSLocalizedString(@"Invalid operand", nil);
	errorStr[5] = NSLocalizedString(@"Invalid label", nil);
	errorStr[6] = NSLocalizedString(@"No END", nil);
	errorStr[7] = NSLocalizedString(@"No START", nil);
	errorStr[8] = NSLocalizedString(@"Invalid constant", nil);
}

- (id)init
{
    self = [super init];
    if (self) {
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		_enableItemAssemble = YES;
		_enableItemRun = NO;
		_enableItemStep = NO;
		_mainMemory = NSZoneMalloc([self zone], kMainMemoryBytes);
		_AddrToLineNum = NSZoneMalloc([self zone], kMainMemoryBytes);
		_breakPoint = NSZoneMalloc([self zone], sizeof(BOOL)*0xffff);
		//malloc(sizeof(uint16_t)*0xffff);
		/*int i;
		 for (i = 0; i <= 0xffff; i++) {
		 _mainMemory[i] = i;
		 }*/
    }
    return self;
}

- (void) dealloc
{
	if (_mainMemory) {
		NSZoneFree([self zone], _mainMemory);
		_mainMemory = NULL;
	}
	//free(_mainMemory);
	if (_AddrToLineNum) {
		NSZoneFree([self zone], _AddrToLineNum);
		_AddrToLineNum = NULL;
	}
	if (_breakPoint) {
		NSZoneFree([self zone], _breakPoint);
		_breakPoint = NULL;
	}
	[_assembler release];
	// Release owned window controllers
	//[_mainWindowController release];
	[_memoryWindowController release];
	[_registerWindowController release];
	NSLog(@"src retain count %d", [_srcCode retainCount]);
	[_srcCode release];
	NSLog(@"document released");
	[super dealloc];
}




- (MenuItem)emuAssemble:(id)sender
{
	// Create assembler
	[_assembler release];
	_assembler = nil;
	CSAssembler* assembler = [[CSAssembler alloc] init];
	
	// Set assemble code
	assembler.source = _mainWindowController.sourceCode;
	
	[assembler assemble:self];
	
	BOOL verbose = NO;
	
	if (verbose) {
		NSLog(@"-----Label Table-----");
		NSEnumerator *enumerator = [assembler.labelTable keyEnumerator];
		NSString* ltKey;
		uint16_t ltAddr;
		while ((ltKey = [enumerator nextObject])) {
			ltAddr = [[assembler.labelTable objectForKey:ltKey] unsignedIntegerValue];
			NSLog(@"%@ = %04x(%d)", ltKey, ltAddr, ltAddr);
		}
	}
	
	// If error occured 
	if ([assembler.error count]) {
		NSMutableArray* errArray = [NSMutableArray array];
		NSLog(@"-----Error List-----");
		for (NSValue* asmErrorObj in assembler.error) {
			AsmError* asmError = [asmErrorObj pointerValue];
			[errArray addObject:[NSNumber numberWithUnsignedInteger:asmError->line]];
			NSLog(@"%d: %@", asmError->line+1, errorStr[asmError->errorType]);
		}
		
		// Clear highlight
		[_mainWindowController setStepLineNumber:0];
		[_mainWindowController setHighlightLineNumber:0 popup:NO];
		
		// Notify errors
		[_mainWindowController setErrorLines:errArray];
		_enableItemStep = NO;
		_enableItemRun = NO;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:nStatusMessageNotification object:NSLocalizedString(@"Assemble error.", nil)];
		
		// NO error //
	} else {
		
		// Create main memory
		uint16_t* memory = _mainMemory;
		memset(memory, 0, kMainMemoryBytes);
		
		// Create address to line number table
		memset(_AddrToLineNum, 0, kMainMemoryBytes);
		
		// Set object code to main memory
		NSUInteger i;
		AsmLine* al;
		NSUInteger addr = 0;
		for (i = 0; i < [assembler.asmLines count]; i++) {
			al = [[assembler.asmLines objectAtIndex:i] pointerValue];
			if (al->opListIndex) {
				// Set object code to main memory
				*(memory+addr) = (al->objCode >> 16);
				*(memory+addr+1) = al->objCode;
				
				// Set address table to line number
				_AddrToLineNum[addr] = al->realLine+1;
				_AddrToLineNum[addr+1] = al->realLine+1;
				
				if (verbose) {
					NSLog(@"%d: %04x %08x - %@",al->realLine+1, addr, al->objCode, al->realStr);
				} else {
					//printf("%04x %08x\n", addr, al->objCode);
				}
				addr += al->memSize;
			}
			if (al->macroListIndex) {
				if (al->memSize) {
					//printf("memsize %d\n", al->memSize);
					if (al->memSize == 1) {
						*(memory+addr) = al->objCode;
					}
					if (al->memSize == 2) {
						*(memory+addr) = (al->objCode >> 16);
						*(memory+addr+1) = al->objCode;
					}
					// Set address table to line number
					int iAt;
					for (iAt = 0; iAt < al->memSize; iAt++) {
						_AddrToLineNum[addr+iAt] = al->realLine+1;
					}
					
					if (verbose) {
						NSLog(@"m%d: %04x %04x - %@",al->realLine, addr, al->objCode, al->realStr);
					}else {
						//printf("%04x %04x\n", addr, al->objCode);
					}
					addr += al->memSize;
				}
				
			}
		}
		
		
		
		
		NSLog(@"Start at %04x(%d)", assembler.startAddress, assembler.startAddress);
		
		// Jump dock icon
		[NSApp requestUserAttention:NSInformationalRequest];
		
		// Clear errors
		[_mainWindowController setErrorLines:nil];
		
		[_memoryWindowController setMemoryDataChangedAddress:nil];
		
		// Prepare Emulator
		CMTEmuRelease(_emu);
		_emu = CMTEmuCreate(_mainMemory);
		CMTSetPC(_emu, assembler.startAddress);
		
		[self updateRegisterFromEmuRegister:CMTGetRegister(_emu)];
		
		_enableItemRun = YES;
		_enableItemStep = YES;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:nStatusMessageNotification object:NSLocalizedString(@"Assemble finished.", nil)];
	}
	
	
	
	//[assembler release];
	_assembler = assembler;
	
	/*
	 NSUInteger iMem;
	 for (iMem = 0; iMem < 50; iMem++) {
	 printf("0x%04x,", _mainMemory[iMem]);
	 //NSLog(@"%04x %04x ",iMem, memory[iMem]);
	 }*/
}

- (void)updateRegisterFromEmuRegister:(CMTEmuRegister)reg
{
	// Update register window
	_registerWindowController.FR = reg.fr;
	_registerWindowController.PC = reg.pc;
	_registerWindowController.GR = reg.gr;
	[_registerWindowController updateRegister:self];
}

- (MenuItem)emuRun:(id)sender
{
	
	BOOL addressChanged[kMainMemoryBytes];
	memset(addressChanged, NO, kMainMemoryBytes);
	
	// Create break point table
	memset(_breakPoint, NO, sizeof(BOOL)*0xffff);
	
	CSAssembler* assembler = _assembler;
	NSUInteger i;
	AsmLine* al;
	NSUInteger addr = 0;
	for (i = 0; i < [assembler.asmLines count]; i++) {
		al = [[assembler.asmLines objectAtIndex:i] pointerValue];
		if (al->opListIndex) {
			// Set break point
			for (NSNumber* breakPtNum in [_mainWindowController bookmarks]) {
				if ([breakPtNum unsignedIntegerValue] == al->realLine) {
					//NSLog(@"break point set %d", [breakPtNum unsignedIntegerValue]);
					_breakPoint[addr] = YES;
				}
			}
			addr += al->memSize;
		}
	}
	
	CMTExecuteResult result;
	NSUInteger iStep;
	BOOL finByBreak = NO;
	CMTEmuRegister reg;
	for (iStep = 0; iStep < 10000; iStep++) {
	// Step run
		result = CMTExecuteStep(_emu);
		if (result.addr_changed == CMTTrue) {
			addressChanged[result.changed_addr] = YES;
		}
		// If exit or error
		if (result.exit_op == CMTTrue || result.return_flag != CMTNoError) {
			finByBreak = YES;
			break;
		}
		// If break point
		reg = CMTGetRegister(_emu);
		if (_breakPoint[reg.pc] == YES) {
			finByBreak = YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:nStatusMessageNotification object:NSLocalizedString(@"Program reached breakpoint.", nil)];
			break;
		}
	}
	
	// Update register window
	reg = CMTGetRegister(_emu);
	[self updateRegisterFromEmuRegister:reg];
	
	// Update memory
	NSUInteger iAddr;
	NSMutableArray* changedAddr = [NSMutableArray array];
	for (iAddr = 0; iAddr < kMainMemoryBytes; iAddr++) {
		if (addressChanged[iAddr] == YES) {
			[changedAddr addObject:[NSNumber numberWithUnsignedInteger:iAddr]];
		}
	}
	[_memoryWindowController setMemoryDataChangedAddress:changedAddr];
	
	// Run step over specify count
	if (finByBreak == NO) {
		[[NSNotificationCenter defaultCenter] postNotificationName:nStatusMessageNotification object:NSLocalizedString(@"Operation step exceed specify count. Program has halted.", nil)];
		NSLog(@"step over specify count");
	}
	
	// If exit program
	if (result.exit_op == CMTTrue) {
		// Jump dock icon
		[NSApp requestUserAttention:NSInformationalRequest];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:nStatusMessageNotification object:NSLocalizedString(@"Program has exited.", nil)];
		NSLog(@"EXIT PROGRAM");
		_enableItemRun = NO;
		_enableItemStep = NO;
		return;
	}
	
	// Program exception
	if (result.return_flag != CMTNoError) {
		NSString* str = [NSString stringWithFormat:NSLocalizedString(@"Execute exception occured. Error:%d", nil), result.return_flag];
		[[NSNotificationCenter defaultCenter] postNotificationName:nStatusMessageNotification object:str];
		NSLog(@"ERROR PROGRAM %d", result.return_flag);
		_enableItemRun = NO;
		_enableItemStep = NO;
		return;
	}
	
	// Set current step number
	// "-1" means show one old step
	[_mainWindowController setStepLineNumber:_AddrToLineNum[reg.pc]];	
	[_mainWindowController setHighlightLineNumber:_AddrToLineNum[reg.pc]-1 popup:NO];

	
}


- (MenuItem)emuStep:(id)sender
{
	// Step run
	CMTExecuteResult result = CMTExecuteStep(_emu);
	
	//NSLog(@"flag %d, change %d addr %04X, exit %d", result.return_flag,result.addr_changed,result.changed_addr,result.exit_op);
	//CMTEmu* emu = _emu;
	//printf("GR0:%04X, GR1:%04X, GR2:%04X, GR3:%04X, GR4:%04X, FR:%X, PC:%04X\n",emu->gr[0], emu->gr[1], emu->gr[2], emu->gr[3], emu->gr[4], emu->fr, emu->pc);
	
	// Update register window
	CMTEmuRegister reg = CMTGetRegister(_emu);
	[self updateRegisterFromEmuRegister:reg];
	
	// If chaned address is true
	if (result.addr_changed == CMTTrue) {
		[_memoryWindowController setMemoryDataChangedAddress:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:result.changed_addr]]];
	} else {
		[_memoryWindowController setMemoryDataChangedAddress:nil];
	}
	
	
	// If exit program
	if (result.exit_op == CMTTrue) {
		[[NSNotificationCenter defaultCenter] postNotificationName:nStatusMessageNotification object:NSLocalizedString(@"Program has exited.", nil)];
		NSLog(@"EXIT PROGRAM");
		_enableItemRun = NO;
		_enableItemStep = NO;
		return;
	}
	
	// Program exception
	if (result.return_flag != CMTNoError) {
		//NSString* error = @"E";
		NSString* str = [NSString stringWithFormat:NSLocalizedString(@"Execute exception occured. Error:%d", nil), result.return_flag];
		[[NSNotificationCenter defaultCenter] postNotificationName:nStatusMessageNotification object:str];
		NSLog(@"ERROR PROGRAM %d", result.return_flag);
		_enableItemRun = NO;
		_enableItemStep = NO;
		return;
	}
	
	// If out of memory
	if (_AddrToLineNum[reg.pc] == 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:nStatusMessageNotification object:NSLocalizedString(@"Emulator accessed invalid memory area.", nil)];
		NSLog(@"OUT of memory");
		_enableItemRun = NO;
		_enableItemStep = NO;
		return;
	}
	
	// Set current step number
	// "-1" means show one old step
	[_mainWindowController setStepLineNumber:_AddrToLineNum[reg.pc]];	
	[_mainWindowController setHighlightLineNumber:oldpos popup:NO];
	[_memoryWindowController setMemoryDataHighlighted:reg.pc];
	oldpos = _AddrToLineNum[reg.pc];
	
}

#pragma mark DEMemoryWindowControllerDelegate

- (void)memorySelected:(uint16_t)addr
{
	[_mainWindowController setHighlightLineNumber:_AddrToLineNum[addr] popup:YES];
//	[_mainWindowController performSelector:@selector(showWindow:) withObject:self afterDelay:0];
}

#pragma mark Menu item management

- (BOOL)validateMenuItem:(id)menuItem
{
	if ([menuItem tag] == kTagShowMemoryMap ||
		[menuItem tag] == kTagRegisterMap) {
		return YES;
	}
	
	if ([menuItem tag] == kTagStep) {
		return _enableItemStep;
	}
	
	if ([menuItem tag] == kTagAssemble) {
		return _enableItemAssemble;
	}
	
	if ([menuItem tag] == kTagRun) {
		return _enableItemRun;
	}
	
	return YES;
}

- (BOOL)validateToolbarItem:(NSToolbarItem*)item
{
	return [self validateMenuItem:item];
}


#pragma mark Window controller management

- (void)makeWindowControllers
{
    _mainWindowController = [[[DEMainWindowController alloc] initWithWindowNibName:@"DEDocument"] autorelease];
    [self addWindowController:_mainWindowController];
	_mainWindowController.sourceCode = _srcCode;

	_memoryWindowController = [[DEMemoryWindowController alloc] initWithWindowNibName:@"DEMemory"];
	//[_memoryWindowController autorelease];
	[_memoryWindowController setMemory:_mainMemory];
	_memoryWindowController.delegate = self;
	[_memoryWindowController showWindow:self];
	//[self addWindowController:_memoryWindowController];
	
	_registerWindowController = [[DERegisterWindowController alloc] initWithWindowNibName:@"DERegister"];
	//[_registerWindowController autorelease];
	//[self addWindowController:_registerWindowController];
	[_registerWindowController showWindow:self];
}

- (MenuItem)showMemoryMap:(id)sender
{
	[_memoryWindowController showWindow:self];
	return;
}

- (MenuItem)showRegister:(id)sender
{
	//	NSLog(@"window ctrlers %@", [[self windowControllers] description]);
	
	[_registerWindowController showWindow:self];
	/*
	 int i;
	 NSMutableArray* changed = [NSMutableArray array];
	 NSNumber* addrNum;
	 srandom(time(NULL));
	 for (i = 0 ; i < 10; i++) {
	 addrNum = [NSNumber numberWithUnsignedLong:random()%500];
	 [changed addObject:addrNum];
	 }
	 [_memoryWindowController setMemoryDataChangedAddress:changed];
	 */
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}


#pragma mark Open and store document

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
	
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	
	NSLog(@"save type as %@", typeName);
	
	NSData* data = [_mainWindowController.sourceCode dataUsingEncoding:NSUTF8StringEncoding];
	
	return data;
	
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
	
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
   
	[_srcCode release];
	_srcCode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

@end
