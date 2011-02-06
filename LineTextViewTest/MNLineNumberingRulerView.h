//
//  MNLineNumberingRulerView.h
//  
//
//  Created by Masatoshi Nishikata on 29/10/05.
//  Copyright 2005 Masatoshi Nishikata. All rights reserved.
//	http://homepage.mac.com/mnishikata/iblog/

//ORIGINAL
//
//  MyTextView.m
//  LineNumbering
//
//  Created by Koen van der Drift on Sat May 01 2004.
//  Copyright (c) 2004 Koen van der Drift. All rights reserved.
//

//
// Modified by Yusuke Ito on 2008/12/27
//


#import <Cocoa/Cocoa.h>
#import "MNLineNumberingTextStorage.h"


extern const int MNNoLineNumbering;
extern const int MNParagraphNumber;
extern const int MNCharacterNumber;
extern const int MNLineNumber;
extern const int MNDrawBookmarks;

@interface MNLineNumberingRulerView : NSRulerView {
	
	//nib outlets
	IBOutlet id dialogueView;
    IBOutlet id radioButtons;
    IBOutlet id textField;

	
	NSTextView*			textView;
	NSLayoutManager*	layoutManager;
	
	NSImage*			markerImage;
	NSImage*			m_errorMarkerImage;
	NSImage*			m_stepMarkerImage;
	
	int						rulerOption;
	
	NSMutableDictionary*	marginAttributes;	
	
	BOOL					markerDeleteReservationFlag;
	
}

-(void)startSheet;
// Start 'Jump To...' sheet.

-(BOOL)showParagraph:(NSUInteger)paragraphNum;

-(BOOL)showLine:(NSUInteger)lineNum;

-(BOOL)showCharacter:(NSUInteger)charIndex granularity:(NSSelectionGranularity)granularity;
	// show line in document text view
	// Granularity is one of NSSelectByCharacter, NSSelectByWord, NSSelectByParagraph, or -1(select by line)

-(void)setVisible:(BOOL)flag;
-(BOOL)isVisible;
// Set and Return Ruler View visiblity.


-(void)setOption:(NSUInteger)option;
// option is 
/*
	extern const int MNNoLineNumbering;
	extern const int MNParagraphNumber;
	extern const int MNCharacterNumber;
	extern const int MNLineNumber;
	extern const int MNDrawBookmarks;
*/


- (void)setMarkerWithKind:(MNMarkerKind)kind atLineIndex:(NSUInteger)index;
- (void)clearAllOfMarkers:(MNMarkerKind)kind;

- (NSArray*)bookmarks;

@end
