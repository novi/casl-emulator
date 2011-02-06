//
//  dqnEmuAppDelegate.m
//  dqnEmu
//
//  Created by ito on 平成 21/01/06.
//  Copyright Ito 2009. All rights reserved.
//

#import "dqnEmuAppDelegate.h"
#import "dqnEmuViewController.h"
#import "DEMemoryController.h"

@implementation dqnEmuAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
