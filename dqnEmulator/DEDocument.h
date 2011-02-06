//
//  MyDocument.h
//  dqnEmulater
//
//  Created by ito on 2008/12/21.
//  Copyright Ito 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "CMTEmulator.h"

#define kTagShowMemoryMap 1001
#define kTagAssemble 1002
#define kTagRegisterMap 1003
#define kTagRun 1004
#define kTagStep 1005

typedef void MenuItem;

@class DEMainWindowController, CSAssembler, DEMemoryWindowController, DERegisterWindowController;

@interface DEDocument : NSDocument
{
	BOOL _enableItemRun;
	BOOL _enableItemAssemble;
	BOOL _enableItemStep;
	
	DEMainWindowController* _mainWindowController; // no retain
	DEMemoryWindowController* _memoryWindowController; //no retain
	DERegisterWindowController* _registerWindowController; //no retain
	
	NSString* _srcCode;
	
	// COMET main memory
	uint16_t*		_mainMemory;
	uint16_t*		_AddrToLineNum;
	//uint16_t*		
	BOOL*		_breakPoint;
	CMTEmu*			_emu;
	CSAssembler*    _assembler;
	
	NSInteger oldpos;
}

@end
