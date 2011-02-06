//
//  LineNumberingTextView.m
//  SampleApp
//
//  Created by Masatoshi Nishikata on 06/03/24.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

//
// Modified by Yusuke Ito on 2008/12/27
//

#import "MNLineNumberingTextView.h"


@implementation DELineTextView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
	MNLineNumberingTextStorage* ts = [[MNLineNumberingTextStorage alloc] init];

	[[self layoutManager] replaceTextStorage:ts]; 	
	[[self textStorage] setDelegate:self];

	NSScrollView* scrollView = [self enclosingScrollView];
	
	// *** set up main text View *** //
	//textView setting -- add ruler to textView
	MNLineNumberingRulerView* aNumberingRulerView = 
		[[MNLineNumberingRulerView alloc] initWithScrollView:scrollView orientation:NSVerticalRuler];
	
	[scrollView setVerticalRulerView:aNumberingRulerView ];
	
	//configuration
	[scrollView setHasVerticalRuler:YES];
	[scrollView setHasHorizontalRuler:NO];
	
	[scrollView setRulersVisible:YES];
	
	[aNumberingRulerView release];
	
	if ([[self superclass] instancesRespondToSelector:@selector(awakeFromNib)]) {
		[super awakeFromNib];
	}
}

-(void)dealloc
{
	[super dealloc];
}

// Message forwarding

- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
    id signature = [[[self enclosingScrollView] verticalRulerView] methodSignatureForSelector: sel]; 
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	MNLineNumberingRulerView* rv = (MNLineNumberingRulerView*)[[self enclosingScrollView] verticalRulerView];
    if ([rv respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:rv];
	} else {
        [super forwardInvocation:anInvocation];
	}
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;
    else {
		if ([[[self enclosingScrollView] verticalRulerView] respondsToSelector:aSelector]) {
			return YES;
		}
    }
    return NO;
}

/*
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSMenuItem* customMenuItem;
	NSMenu* aContextMenu = [super menuForEvent:theEvent];

	//add separator
	customMenuItem = [NSMenuItem separatorItem];
	[customMenuItem setRepresentedObject:@"MN"];
	[aContextMenu addItem:customMenuItem ];
	
	// 
	customMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show/Hide Gutter"
												action:@selector(toggleGutterVisiblity) keyEquivalent:@""];
	[customMenuItem setRepresentedObject:@"MN"];
	[aContextMenu addItem:customMenuItem ];
	[customMenuItem release];	
	//
	
	// 
	customMenuItem = [[NSMenuItem alloc] initWithTitle:@"Jump to..."
												action:@selector(jumpTo) keyEquivalent:@""];
	[customMenuItem setRepresentedObject:@"MN"];
	[aContextMenu addItem:customMenuItem ];
	[customMenuItem release];	
	
	return aContextMenu;
}*/

-(void)toggleGutterVisiblity
{
	MNLineNumberingRulerView* rv = (MNLineNumberingRulerView*)[[self enclosingScrollView] verticalRulerView];
	[rv setVisible:![rv isVisible]];	
}

-(void)jumpTo
{
	[(MNLineNumberingRulerView*)[[self enclosingScrollView] verticalRulerView] startSheet];
}

@end
