//
//  TVDAppDelegate.m
//  TVDrop
//
//  Created by Cameron Ehrlich on 4/29/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import "TVDAppDelegate.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <POP/POP.h>

#define kMinWindowSize CGSizeMake(75, 75)

@implementation TVDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.window setAlphaValue:0];
    [self.window setInitialFirstResponder:self.dropView];
    [self.window makeFirstResponder:self.dropView];
//    [self.window setLevel:NSMainMenuWindowLevel + 2];
    [self.window setMinSize:CGSizeMake(kMinWindowSize.width, kMinWindowSize.height)];
    [self.window setStyleMask: (NSBorderlessWindowMask) ];
    NSRect windowRect = NSRectFromCGRect(CGRectMake(
                                                    10,
                                                    10,
                                                    kMinWindowSize.width,
                                                    kMinWindowSize.height));
    
    [self.window setFrame:windowRect display:YES animate:NO];

    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window setOpaque:NO];
    [self.window setHasShadow:NO];
    
    [self.dropView.layer setOpacity:1];
    [self.dropView.layer setCornerRadius:kMinWindowSize.height/2];

    
    [RACObserve([TVDModel sharedInstance], fileURL) subscribeNext:^(id x) {

        NSLog(@"File name: %@", x);

        if(x){
            [self.statusLabel setStringValue:[(NSURL *)x lastPathComponent]];
        }else{
            [self.statusLabel setStringValue:@""];
        }
        
    }];
    
    [RACObserve([TVDModel sharedInstance], foundDevices) subscribeNext:^(id x) {
        if ([(NSSet *)x count] == 0) {
            [self.airplayDevicesMenuItem.submenu removeAllItems];
        }else{
            [self.airplayDevicesMenuItem.submenu removeAllItems];
            for (AKDevice *device in [[TVDModel sharedInstance] foundDevices]) {
                NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:device.displayName action:@selector(dropdownDidChange:) keyEquivalent:@""];
                [self.airplayDevicesMenuItem.submenu addItem:menuItem];
            }
            if (![[[TVDModel sharedInstance] airplayManager] connectedDevice]) {
                AKDevice *newDevice = [[[[TVDModel sharedInstance] foundDevices] allObjects] objectAtIndex:0];
                [[[TVDModel sharedInstance] airplayManager] connectToDevice:newDevice];
            }
        }
    }];

    [[TVDModel sharedInstance] startFindingDevices];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.window setAlphaValue:0.9];
    });


}


- (void)dropdownDidChange:(id)sender
{
    [[[[[TVDModel sharedInstance] airplayManager] connectedDevice] socket] disconnect];
    [[[TVDModel sharedInstance] airplayManager] setConnectedDevice:nil];
    
    for (AKDevice *device in [[TVDModel sharedInstance] foundDevices]) {
        if ([device.displayName isEqualToString:[sender title]]) {
            [[[TVDModel sharedInstance] airplayManager] connectToDevice:device];
            break;
        }
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (IBAction)stopButtonAction:(id)sender
{
    [[[[TVDModel sharedInstance] airplayManager] connectedDevice] sendStop];
}

- (IBAction)playPause:(id)sender
{
    [[[[TVDModel sharedInstance] airplayManager] connectedDevice] sendReverse];
}

@end
