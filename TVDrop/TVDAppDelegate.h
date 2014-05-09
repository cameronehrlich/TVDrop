//
//  TVDAppDelegate.h
//  TVDrop
//
//  Created by Cameron Ehrlich on 4/29/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TVDDropView.h"
#import "TVDModel.h"

@interface TVDAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet TVDDropView *dropView;
@property (nonatomic, strong) IBOutlet NSTextField *statusLabel;
@property (nonatomic, strong) IBOutlet NSMenuItem *airplayDevicesMenuItem;

- (IBAction)stopButtonAction:(id)sender;
- (IBAction)playPause:(id)sender;

@end