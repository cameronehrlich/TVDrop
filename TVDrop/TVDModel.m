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
        self.foundDevices = [NSMutableSet set];
        
        self.airplayManager = [[AKAirplayManager alloc] init];
        [self.airplayManager setDelegate:self];
        [self.airplayManager findDevices];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            self.webServer = [[GCDWebServer alloc] init];
            [self.webServer addGETHandlerForBasePath:@"/" directoryPath:NSHomeDirectory() indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
            [self.webServer runWithPort:8080 bonjourName:nil];
        });
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark AKAirPlayManagerDelegate

-(void)airplayManager:(AKAirplayManager *)manager didFindDevice:(AKDevice *)device
{
    [self.foundDevices addObject:device];
}

-(void)airplayManager:(AKAirplayManager *)manager didConnectToDevice:(AKDevice *)device
{
    [self setConnectedDevice:device];
    [self playFileAtURL:self.fileToPlayURL];
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
