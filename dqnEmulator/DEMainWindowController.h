//
//  MainWindowController.h
//  dqnEmulater
//
//  Created by ito on 2008/12/27.
//  Copyright 2008 Ito. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* const nStatusMessageNotification;

@interface DEMainWindowController : NSWindowController {

	NSString*	_srcCode;
	IBOutlet id _codeTextView;
	IBOutlet id _statusLabel;
}

@property(retain, nonatomic) NSString* sourceCode;


- (void)setErrorLines:(NSArray*)err;
- (void)setStepLineNumber:(NSUInteger)lineNum;
- (void)setHighlightLineNumber:(NSUInteger)lineNum popup:(BOOL)popup;
- (NSArray*)bookmarks;

@end
