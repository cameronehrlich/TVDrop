//
//  TVDAppDelegate.m
//  TVDrop
//
//  Created by Cameron Ehrlich on 4/29/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import "TVDAppDelegate.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation TVDAppDelegate
{
    TVDModel *model;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    model = [TVDModel sharedInstance];
    
    [RACObserve(model, fileToPlayURL) subscribeNext:^(id x) {
        if(x){
            [self.statusLabel setStringValue:[(NSURL *)x lastPathComponent]];
        }
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.dropdown removeAllItems];
        for (AKDevice *device in [[TVDModel sharedInstance] foundDevices]) {
            [self.dropdown addItemWithTitle:device.displayName];
        }
        
    });
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}


- (IBAction)chooseFileButtonAction:(id)sender
{
    [self openFileBrowser];
}


- (void)openFileBrowser
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowedFileTypes:[[TVDModel sharedInstance] allTypes]];
    [openPanel setAllowsMultipleSelection:NO];
    
    if ([openPanel runModal] == NSOKButton ) {
        
        [[TVDModel sharedInstance] setFileToPlayURL:[openPanel URL]];
        [[TVDModel sharedInstance] connectAndPlay:[[self.dropdown selectedItem] title]];
    }
}

- (IBAction)stopButtonAction:(id)sender
{
    [self.statusLabel setStringValue:@""];
    [[[TVDModel sharedInstance] connectedDevice] sendStop];
}

@end
