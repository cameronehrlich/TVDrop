//
//  TVDAppDelegate.m
//  TVDrop
//
//  Created by Cameron Ehrlich on 4/29/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import "TVDAppDelegate.h"
#import <NSString+RMURLEncoding.h>

@implementation TVDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.foundDevices = [NSMutableSet set];
    
    [self.dropdown removeAllItems];
    
    self.airplayManager = [[AKAirplayManager alloc] init];
    [self.airplayManager setDelegate:self];
    [self.airplayManager findDevices];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.webServer = [[GCDWebServer alloc] init];
        [self.webServer addGETHandlerForBasePath:@"/" directoryPath:NSHomeDirectory() indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
        [self.webServer runWithPort:8080 bonjourName:nil];
    });
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

#pragma mark AKAirPlayManagerDelegate

-(void)airplayManager:(AKAirplayManager *)manager didFindDevice:(AKDevice *)device
{
    [self.foundDevices addObject:device];
    [self.dropdown addItemWithTitle:device.displayName];
}

-(void)airplayManager:(AKAirplayManager *)manager didConnectToDevice:(AKDevice *)device
{
    self.connectedDevice = device;
    [self playFileAtURL:self.fileToPlayURL];
}


- (IBAction)browseButtonAction:(id)sender
{
    [self openFileBrowser];
}

- (NSArray *)musicTypes
{
    return @[ @"m4a", @"mp3" ];
}

- (NSArray *)videoTypes
{
    return @[ @"mp4", @"mov", @"ts", @"m4v" ];
}

- (NSArray *)imageTypes
{
    return @[ @"png", @"jpg", @"tiff" ];
}

- (void)openFileBrowser
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    NSArray *fileTypesArray = [[[self musicTypes] arrayByAddingObjectsFromArray:[self videoTypes]] arrayByAddingObjectsFromArray:[self imageTypes]];
    
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowedFileTypes:fileTypesArray];
    [openPanel setAllowsMultipleSelection:NO];

    if ([openPanel runModal] == NSOKButton ) {
    
        self.fileToPlayURL = [openPanel URL];
        [self connectAndPlay];
        
    }
}

- (void)connectAndPlay
{
    NSString *selectedItem = [[self.dropdown selectedItem] title];
    for (AKDevice *device in self.foundDevices) {
        if ([selectedItem isEqualToString:device.displayName]) {
            [device setDelegate:self];
            [self.airplayManager connectToDevice:device];
            break;
        }
    }
}

- (void)playFileAtURL:(NSURL *)fileURL
{
    if ([[self imageTypes] containsObject:fileURL.pathExtension]) {
        NSLog(@"Sending image: %@", fileURL);
        [self.connectedDevice sendImage:[[NSImage alloc] initWithContentsOfURL:fileURL]];
    }else{
        NSString *address = [self.webServer serverURL].absoluteString;
        NSString *pathToFile = [[fileURL.path stringByReplacingOccurrencesOfString:[NSHomeDirectory() stringByAppendingString:@"/"] withString:@""] rm_URLEncodedString];
        NSString *finalURL = [address stringByAppendingString:pathToFile];
        
        NSLog(@"Sending URL: %@", finalURL);
        
        [self.connectedDevice sendContentURL: finalURL];
    }
}

@end
