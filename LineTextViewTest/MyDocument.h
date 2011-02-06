//
//  MyDocument.h
//  LineTextViewTest
//
//  Created by ito on ?? 20/12/27.
//  Copyright Ito 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface MyDocument : NSDocument
{
	IBOutlet NSTextView* _textView;
	NSImage*		_errorImage;
}

- (IBAction)addErrorMarker:(id)sender;
- (IBAction)clearErrorMarker:(id)sender;


@end
