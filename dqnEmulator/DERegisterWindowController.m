//
//  DERegisterWindowController.m
//  dqnEmulator
//
//  Created by ito on 2008/12/27.
//  Copyright 2008 Ito. All rights reserved.
//

#import "DERegisterWindowController.h"

NSString* const kRegFormatFR = @"%01X";
NSString* const kRegFormatGeneral = @"%04X (%d)";
NSString* const kRegFRContents[] = {@"00", @"01", @"10", @"11"};


@implementation DERegisterWindowController

- (void)windowDidLoad
{
	//NSLog(@"window did load DERegCtrler");
	[_textFR setStringValue:@"00 (00)"];
	[_textGR0 setStringValue:@"0000 (0)"];
	[_textGR1 setStringValue:@"0000 (0)"];
	[_textGR2 setStringValue:@"0000 (0)"];
	[_textGR3 setStringValue:@"0000 (0)"];
	[_textGR4 setStringValue:@"0000 (0)"];
	[_textPC setStringValue:@"0000 (0)"];
}


- (void) dealloc
{
	NSLog(@"release reg ctrler");
	[super dealloc];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return [NSString stringWithFormat:NSLocalizedString(@"%@ - Register", nil), displayName];
}

#pragma mark Setter/Getter
	
- (void) setFR:(uint8_t)aFR
{
	if (aFR != _FR) {
		_FR = aFR;
		_changedFR = YES;
	} else {
		_changedFR = NO;
	}
}

- (uint8_t)FR
{
	return _FR;
}


- (void)setGR:(int16_t*)aGR
{
	int i;
	for (i = 0; i < 5; i++) {
		if (aGR[i] != _GR[i]) {
			_GR[i] = aGR[i];
			_changedGR[i] = YES;
		} else {
			_changedGR[i] = NO;
		}
	}
}

- (int16_t*)GR
{
	return _GR;
}

- (void)setPC:(uint16_t)aPC
{
	if (aPC != _PC) {
		_PC = aPC;
		_changedPC = YES;
	} else {
		_changedPC = NO;
	}
	
}

- (uint16_t)PC
{
	return _PC;
}



- (void)updateRegister:(id)sender
{
	NSColor* defColor = [NSColor blackColor];
	NSColor* changedColor = [NSColor redColor];
	
	if (_changedFR) {
		[_textFR setTextColor:changedColor];
		NSString* frStr = [NSString stringWithFormat:kRegFormatFR, _FR];
		if (_FR <= 3) {
			frStr = [frStr stringByAppendingFormat:@" (%@)", kRegFRContents[_FR]];
			if (_FR == 0) {
				frStr = [frStr stringByAppendingString:@" p"];
			} else if (_FR == 1) {
				frStr = [frStr stringByAppendingFormat:@" z"];
			} else if (_FR == 2) {
				frStr = [frStr stringByAppendingFormat:@" m"];
			}
		}

		[_textFR setStringValue:frStr];
	} else {
		[_textFR setTextColor:defColor];
	}

	if (_changedGR[0]) {
		[_textGR0 setTextColor:changedColor];
		[_textGR0 setStringValue:[NSString stringWithFormat:kRegFormatGeneral, _GR[0], _GR[0]]];
	} else {
		[_textGR0 setTextColor:defColor];
	}

	if (_changedGR[1]) {
		[_textGR1 setTextColor:changedColor];
		[_textGR1 setStringValue:[NSString stringWithFormat:kRegFormatGeneral, _GR[1], _GR[1]]];
	} else {
		[_textGR1 setTextColor:defColor];
	}
	
	if (_changedGR[2]) {
		[_textGR2 setTextColor:changedColor];
		[_textGR2 setStringValue:[NSString stringWithFormat:kRegFormatGeneral, _GR[2], _GR[2]]];
	} else {
		[_textGR2 setTextColor:defColor];
	}
	
	if (_changedGR[3]) {
		[_textGR3 setTextColor:changedColor];
		[_textGR3 setStringValue:[NSString stringWithFormat:kRegFormatGeneral, _GR[3], _GR[3]]];
	} else {
		[_textGR3 setTextColor:defColor];
	}
	
	if (_changedGR[4]) {
		[_textGR4 setTextColor:changedColor];
		[_textGR4 setStringValue:[NSString stringWithFormat:kRegFormatGeneral, _GR[4], _GR[4]]];
	} else {
		[_textGR4 setTextColor:defColor];
	}
	
	if (_changedPC) {
		[_textPC setTextColor:changedColor];
		[_textPC setStringValue:[NSString stringWithFormat:kRegFormatGeneral, _PC, _PC]];
	} else {
		[_textPC setTextColor:defColor];
	}
	
}

@end
