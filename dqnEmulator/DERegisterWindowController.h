//
//  DERegisterWindowController.h
//  dqnEmulator
//
//  Created by ito on 2008/12/27.
//  Copyright 2008 Ito. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DERegisterWindowController : NSWindowController {
	
	IBOutlet NSTextField* _textFR;
	IBOutlet NSTextField* _textGR0;
	IBOutlet NSTextField* _textGR1;
	IBOutlet NSTextField* _textGR2;
	IBOutlet NSTextField* _textGR3;
	IBOutlet NSTextField* _textGR4;
	IBOutlet NSTextField* _textPC;

	uint8_t _FR;
	int16_t _GR[5];
	uint16_t _PC;
	
	BOOL	_changedFR;
	BOOL	_changedGR[5];
	BOOL	_changedPC;
}

@property(assign) uint8_t FR;
@property(assign) int16_t* GR;
@property(assign) uint16_t PC;

- (void)updateRegister:(id)sender;

@end
