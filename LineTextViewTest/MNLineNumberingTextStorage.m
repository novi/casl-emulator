//
//  FugoCompletionTextStorage.m
//  SampleApp
//
//  Created by Masatoshi Nishikata on 13/02/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//
// Modified by Yusuke Ito on 2008/12/27
//

#import "MNLineNumberingTextStorage.h"

#define UNIQUECODE [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]

const NSString* MarkerAttributeName	= @"MarkerAttributeName";
const NSString* ErrorMarkerAttributeName = @"ErrorMarkerAttributeName";
const NSString* MarkerStepAttributeName = @"stepmarker";

@interface MNLineNumberingTextStorage ( NSTextStorage )

- (NSString*)string;
- (NSDictionary*)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)str;
- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange;

@end

@implementation MNLineNumberingTextStorage

- (id)init {
    self = [super init];
    if (self) {
		// fundamental
		m_attributedString = [[NSMutableAttributedString alloc] init];
		m_bookmarks = [[NSMutableArray alloc] init];
    }    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[m_attributedString release];
	[m_bookmarks release];
	[super dealloc];
}

-(BOOL)hasBookmarkAtIndex:(NSUInteger)index inTextView:(NSTextView*)textView
{
	NSRange paragraphRange = 
	[textView selectionRangeForProposedRange:NSMakeRange(index, 1) granularity:NSSelectByParagraph];
	
	id attribute = [self attribute:(NSString*)MarkerAttributeName atIndex:NSMaxRange(paragraphRange) -1 effectiveRange:NULL];
	if( attribute != NULL )
	{
		return [attribute boolValue] ;
	}
	return NO;
}

- (BOOL)hasMarkerAtIndex:(NSUInteger)index inTextView:(NSTextView*)textView kind:(MNMarkerKind)kind
{
	NSRange paragraphRange = [textView selectionRangeForProposedRange:NSMakeRange(index, 1) granularity:NSSelectByParagraph];
	
	if (paragraphRange.location == NSNotFound) {
		return NO;
	}
	
	id attribute;
	if (kind == MNMarkerBookMark) {
		attribute = [self attribute:(NSString*)MarkerAttributeName atIndex:NSMaxRange(paragraphRange) -1 effectiveRange:NULL];
		if(attribute) {
			return [attribute boolValue] ;
		}
	}
	if (kind == MNMarkerError) {
		attribute = [self attribute:(NSString*)ErrorMarkerAttributeName atIndex:NSMaxRange(paragraphRange) -1 effectiveRange:NULL];
		if(attribute) {
			return [attribute boolValue] ;
		}
	}
	if (kind == MNMarkerStep) {
		attribute = [self attribute:(NSString*)MarkerStepAttributeName atIndex:NSMaxRange(paragraphRange) -1 effectiveRange:NULL];
		if(attribute) {
			return [attribute boolValue] ;
		}
	}
	return NO;
}

-(void)setBookmarkAtIndex:(NSUInteger)index flag:(BOOL)flag  inTextView:(NSTextView*)textView
{
	NSRange paragraphRange = [textView selectionRangeForProposedRange:NSMakeRange(index, 1) granularity:NSSelectByParagraph];
	[self addAttribute:(NSString*)MarkerAttributeName value:[NSNumber numberWithBool:flag] range:NSMakeRange(NSMaxRange(paragraphRange)-1,1)];
	
	NSUInteger bookmarkIndex = index;
	if (bookmarkIndex > 0) {
		bookmarkIndex--;
	}
	
	if (flag) {
		// set bookmark
		[m_bookmarks addObject:[NSNumber numberWithUnsignedInteger:[self paragraphNumberAtIndex:bookmarkIndex]]];
	} else {
		// removebookmark
		for (NSNumber* para in [m_bookmarks reverseObjectEnumerator]) {
			if ([para isEqualToNumber:[NSNumber numberWithUnsignedInteger:[self paragraphNumberAtIndex:bookmarkIndex]]]) {
				[m_bookmarks removeObject:para];
			}
		}
	}
}

- (NSArray*)bookmarks
{
	return [[m_bookmarks retain] autorelease];
}

-(void)setMarkerAtIndex:(NSUInteger)index flag:(BOOL)flag  inTextView:(NSTextView*)textView kind:(MNMarkerKind)kind
{
	NSRange paragraphRange = [textView selectionRangeForProposedRange:NSMakeRange(index, 1) granularity:NSSelectByParagraph];
	//NSLog(@"para %@", NSStringFromRange(paragraphRange));
	if (kind == MNMarkerError) {
		[self addAttribute:(NSString*)ErrorMarkerAttributeName value:[NSNumber numberWithBool:flag] range:NSMakeRange(NSMaxRange(paragraphRange)-1,1)];
	}
	if (kind == MNMarkerStep) {
		[self addAttribute:(NSString*)MarkerStepAttributeName value:[NSNumber numberWithBool:flag] range:NSMakeRange(NSMaxRange(paragraphRange)-1,1)];
	}
}

-(NSUInteger)paragraphNumberAtIndex:(NSUInteger)index
{
	int paragraphNumber = 1;
	NSString* str = [self string];
	
	NSUInteger hoge;
	for( hoge = 0; hoge < [str length]; hoge ++ ) {
		if( index <= hoge )
			break;
		
		unichar	characterToCheck = [str characterAtIndex:hoge];
		
		if (characterToCheck == '\n' || characterToCheck == '\r' ||
			characterToCheck == 0x2028 || characterToCheck == 0x2029)
			
			paragraphNumber++;
	}
	return paragraphNumber;
}

@end


//  ######## fundamental subclassing ##########
@implementation MNLineNumberingTextStorage (NSTextStorage)

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
	
    [m_attributedString replaceCharactersInRange:range withString:str];
    
    int lengthChange = [str length] - range.length;
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:lengthChange];
	
}


- (NSString *)string
{
    return [m_attributedString string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    return [m_attributedString attributesAtIndex:index effectiveRange:aRange];
}



- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)range
{
    [m_attributedString setAttributes:attributes range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
	
}


@end

