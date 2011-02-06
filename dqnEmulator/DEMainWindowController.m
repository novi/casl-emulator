//
//  MainWindowController.m
//  dqnEmulater
//
//  Created by ito on 2008/12/27.
//  Copyright 2008 Ito. All rights reserved.
//

#import "DEMainWindowController.h"

#import "MNLineNumberingRulerView.h"

NSString* const nStatusMessageNotification = @"statusMessageNofity";

@implementation DEMainWindowController


- (void)windowDidLoad
{
	
	NSTextView* textView = _codeTextView;
	// Set up font
	NSFont* textFont = [NSFont fontWithName:@"Monaco" size:11];
	[textView setFont:textFont];
	
	// Disable word wrapping
	NSMutableParagraphStyle* paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByClipping];
	[textView setDefaultParagraphStyle:paraStyle];
	const CGFloat LargeNumberForText = 1.0e7;
	[[textView textContainer] setContainerSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
	[[textView textContainer] setWidthTracksTextView:NO];
	[[textView textContainer] setHeightTracksTextView:NO];
	[textView setAutoresizingMask:NSViewNotSizable];
	[textView setMaxSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
	[textView setHorizontallyResizable:YES];
	[textView setVerticallyResizable:YES];
	
	
	if (_srcCode) {
		[textView setString:_srcCode];
	} else {	
		[textView setString:@"\tstart\n; Enter code here\n\texit\n\tend\n"];
	}
	
	// Set default message
	[(NSTextField*)_statusLabel setStringValue:NSLocalizedString(@"New document", nil)];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusMessageNotification:) name:nStatusMessageNotification object:nil];
	
	//	[_codeTextView setSelectedRange:NSMakeRange(0, [[_codeTextView string] length])];
	//	[_codeTextView centerSelectionInVisibleArea:self];
	
	
	
	[self showWindow:self];
	
	[[_codeTextView window] makeFirstResponder:self];
	[_codeTextView setSelectedRange:NSMakeRange(0, 0)];
	[_codeTextView centerSelectionInVisibleArea:self];
	
	
}

- (void) dealloc
{
	[_srcCode release];
	[super dealloc];
}


- (void)statusMessageNotification:(id)aNotification
{
	[_statusLabel setStringValue:[aNotification object]];

}

-(NSString*)sourceCode
{
	return [_codeTextView string];
}

- (void)setSourceCode:(NSString*)str
{
	//NSLog(@"src %@", str);
	if (str != _srcCode) {
		[_srcCode release];
		_srcCode = [str retain];
		[_codeTextView setString:str];
		
	}
}

- (void)setErrorLines:(NSArray*)err
{
	// Get rular view
	//MNLineNumberingRulerView* rv = (MNLineNumberingRulerView*)[[_codeTextView enclosingScrollView] verticalRulerView];
	
	// Clear current marker
	if ([_codeTextView respondsToSelector:@selector(clearAllOfMarkers:)]) {
		[_codeTextView clearAllOfMarkers:MNMarkerError];
	}
	
	if ([_codeTextView respondsToSelector:@selector(setMarkerWithKind:atLineIndex:)]) {
		[err retain];
		// Set error marker
		for (NSNumber* line in err) {
			[_codeTextView setMarkerWithKind:MNMarkerError atLineIndex:[line unsignedIntegerValue]];
		}
		[err release];		
	}
	
}

- (void)setStepLineNumber:(NSUInteger)lineNum
{
	// Clear current marker
	if ([_codeTextView respondsToSelector:@selector(clearAllOfMarkers:)]) {
		[_codeTextView clearAllOfMarkers:MNMarkerStep];
	}	
	
	if (lineNum == 0) {
		return;
	}
	
	// Set marker
	if ([_codeTextView respondsToSelector:@selector(setMarkerWithKind:atLineIndex:)]) {
		[_codeTextView setMarkerWithKind:MNMarkerStep atLineIndex:lineNum-1];
	}
}

- (void)setHighlightLineNumber:(NSUInteger)lineNum popup:(BOOL)popup;
{
	
	if (lineNum == 0) {
		[_codeTextView setSelectedRange:NSMakeRange(0, 0)];
		return;
	}
	//[_codeTextView setSelectedRange:NSMakeRange(0, 10)];
	//[_codeTextView centerSelectionInVisibleArea:self];
	//[[_codeTextView window] makeFirstResponder:self];
	
	// Set Highlighted
	
	if ([_codeTextView respondsToSelector:@selector(showParagraph:)]) {
		[_codeTextView showParagraph:lineNum-1];
		if (popup) {
			[_codeTextView centerSelectionInVisibleArea:self];
			[[_codeTextView window] makeFirstResponder:self];
		}
		//	
	}
}

- (NSArray*)bookmarks
{
	//NSLog(@"bookmark get");
	if ([_codeTextView respondsToSelector:@selector(bookmarks)]) {
		//	NSLog(@"bookmark %@", [_codeTextView bookmarks]);
		return [_codeTextView bookmarks];
	}
	return nil;
}

@end
