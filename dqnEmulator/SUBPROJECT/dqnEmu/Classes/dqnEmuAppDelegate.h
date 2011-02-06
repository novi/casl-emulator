//
//  dqnEmuAppDelegate.h
//  dqnEmu
//
//  Created by ito on 平成 21/01/06.
//  Copyright Ito 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class dqnEmuViewController, DEMemoryController;

@interface dqnEmuAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    DEMemoryController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DEMemoryController *viewController;

@end

