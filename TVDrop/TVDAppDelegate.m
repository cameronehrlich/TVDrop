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

@implementation TVDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.window center];
    
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
