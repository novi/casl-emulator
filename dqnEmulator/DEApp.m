//
//  DEApp.m
//  dqnEmulator
//
//  Created by ito on 2008/12/29.
//  Copyright 2008 Ito. All rights reserved.
//

#import "DEApp.h"


NSString* const pluginFileName[] = {@"DELineTextView.bundle"};

@implementation DEApp

+(void)initialize
{
	// Load pluin from bundle
	int i;
	for (i = 0; i < (sizeof(pluginFileName)/sizeof(NSString*)); i++) {
		NSBundle* bndl = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pluginFileName[i]]];
		if (bndl) {
			if ([bndl load]) {
				NSLog(@"Bundle loaded: %@", [bndl bundleIdentifier]);
			}
		}
	}
}

@end
