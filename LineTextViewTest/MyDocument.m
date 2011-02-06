//
//  MyDocument.m
//  LineTextViewTest
//
//  Created by ito on ?? 20/12/27.
//  Copyright Ito 2008 . All rights reserved.
//

#import "MyDocument.h"
#import "MNLineNumberingRulerView.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		_errorImage = [[NSImage alloc] initByReferencingFile:
					   [[NSBundle bundleForClass:[self class]] pathForResource:@"error-marker" ofType:@"tiff"]];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (IBAction)addErrorMarker:(id)sender
{
	MNLineNumberingRulerView* rv = (MNLineNumberingRulerView*)[[_textView enclosingScrollView] verticalRulerView];
	
	/*
	NSLog(@"ruler ? %@", [rv className]);
	
	
	NSRulerMarker* rm = [[NSRulerMarker alloc] initWithRulerView:rv markerLocation:0 image:_errorImage imageOrigin:NSZeroPoint];
	[rv addMarker:rm];
	[rm autorelease];
*/
	srandom(time(NULL));
	int para = random()%20;
	NSLog(@"marker set at %d", para);
	
	[rv setMarkerWithKind:MNMarkerStep atLineIndex:para];
	
	[rv setMarkerWithKind:MNMarkerError atLineIndex:para];
	
	//NSLog(@"markers=%@",[[rv markers] description]);
}

- (IBAction)clearErrorMarker:(id)sender
{
	MNLineNumberingRulerView* rv = (MNLineNumberingRulerView*)[[_textView enclosingScrollView] verticalRulerView];
	
		[rv clearAllOfMarkers:MNMarkerError];
	[rv clearAllOfMarkers:MNMarkerStep];
	
	NSLog(@"bookmarks %@", [[rv bookmarks] description]);
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	// Set up font
	NSFont* textFont = [NSFont fontWithName:@"Monaco" size:11];
	[_textView setFont:textFont];
	/*
	// Disable word wrapping
	NSMutableParagraphStyle* paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByClipping];
	[_textView setDefaultParagraphStyle:paraStyle];
	const CGFloat LargeNumberForText = 1.0e7;
	[[_textView textContainer] setContainerSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
    [[_textView textContainer] setWidthTracksTextView:NO];
    [[_textView textContainer] setHeightTracksTextView:NO];
    [_textView setAutoresizingMask:NSViewNotSizable];
	[_textView setMaxSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
    [_textView setHorizontallyResizable:YES];
    [_textView setVerticallyResizable:YES];
    */
	[super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

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
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

@end
