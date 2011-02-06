//
// Modified by Yusuke Ito on 2008/12/27
//


#import <Cocoa/Cocoa.h>

enum e_MarkerKind {
	MNNoMarker = 0,
	MNMarkerBookMark = 1,
	MNMarkerError = 2,
	MNMarkerStep = 3,
};

typedef enum e_MarkerKind MNMarkerKind;

extern const NSString* MarkerAttributeName;
extern const NSString* ErrorMarkerAttributeName;
extern const NSString* MarkerStepAttributeName;

@interface MNLineNumberingTextStorage : NSTextStorage
{
	NSMutableAttributedString *m_attributedString;
	NSMutableArray* m_bookmarks;
}

- (BOOL)hasBookmarkAtIndex:(NSUInteger)index inTextView:(NSTextView*)textView;
	// Check if the paragraph contains index is bookmarked.

- (void)setBookmarkAtIndex:(NSUInteger)index flag:(BOOL)flag  inTextView:(NSTextView*)textView;
	// Set bookmark to the paragraph contains index.

	// ** note **  
	// Bookmarks are added to paragraphs, not characters.
	// A bookmark is stored as an attribute 'MarkerAttributeName' embedded to return code. 


- (NSUInteger)paragraphNumberAtIndex:(NSUInteger)index;
	// return paragraph number contains index

- (void)setMarkerAtIndex:(NSUInteger)index flag:(BOOL)flag  inTextView:(NSTextView*)textView kind:(MNMarkerKind)kind;
- (BOOL)hasMarkerAtIndex:(NSUInteger)index inTextView:(NSTextView*)textView kind:(MNMarkerKind)kind;

- (NSArray*)bookmarks;

@end
