//
//  TVDModel.m
//  TVDrop
//
//  Created by Cameron Ehrlich on 4/29/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import "TVDModel.h"

@implementation TVDModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.foundDevices   = [NSMutableSet set];

        self.airplayManager = [[AKAirplayManager alloc] init];
        [self.airplayManager setDelegate:self];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.webServer = [[GCDWebServer alloc] init];
            [self.webServer setDelegate:self];
            [self.webServer addGETHandlerForBasePath:@"/" directoryPath:NSHomeDirectory() indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
            
            [self.webServer runWithPort:8080 bonjourName:nil];
        });
    }
    return self;
}

#pragma mark -
#pragma mark GCDWebServerDelegate

+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startFindingDevices
{
    [self.airplayManager findDevices];
}

#pragma mark AKAirPlayManagerDelegate

-(void)airplayManager:(AKAirplayManager *)manager didFindDevice:(AKDevice *)device
{
    NSMutableSet *newDeviceSet = [[NSMutableSet alloc] initWithSet:self.foundDevices];
    [newDeviceSet addObject:device];
    self.foundDevices = [newDeviceSet copy];
}

-(void)airplayManager:(AKAirplayManager *)manager didConnectToDevice:(AKDevice *)device
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)connectAndPlay:(NSString *)selectedItemTitle
{
    for (AKDevice *device in self.foundDevices) {
        if ([selectedItemTitle isEqualToString:device.displayName]) {
            [device setDelegate:self];
            [self.airplayManager connectToDevice:device];
            break;
        }
    }
}

- (void)playFileAtURL:(NSURL *)fileURL
{
    [self setFileURL:fileURL];
    
    if ([[self imageTypes] containsObject:[fileURL.pathExtension lowercaseString]]) {
        NSLog(@"Sending image: %@", fileURL);
        [[[[TVDModel sharedInstance] airplayManager] connectedDevice] sendStop];
        [self.airplayManager.connectedDevice sendImage:[[NSImage alloc] initWithContentsOfURL:fileURL]];
    }else{
        NSString *address = [self.webServer serverURL].absoluteString;
        NSString *pathToFile = [[fileURL.path stringByReplacingOccurrencesOfString:[NSHomeDirectory() stringByAppendingString:@"/"] withString:@""] rm_URLEncodedString];
        NSString *finalURL = [address stringByAppendingString:pathToFile];
        
        NSLog(@"Sending URL: %@", finalURL);
        [self.airplayManager.connectedDevice sendContentURL: finalURL];
        
    }
}

- (NSArray *)musicTypes
{
    return @[@"m4a", @"mp3"];
}

- (NSArray *)videoTypes
{
    return @[@"mp4", @"mov", @"ts", @"m4v"];
}

- (NSArray *)imageTypes
{
    return @[@"png", @"jpg", @"tiff", @"psd"];
}

- (NSArray *)allTypes
{
    NSArray *fileTypesArray = [[[self musicTypes] arrayByAddingObjectsFromArray:[self videoTypes]] arrayByAddingObjectsFromArray:[self imageTypes]];
    return fileTypesArray;
}

@end
