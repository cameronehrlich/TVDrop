//
//  AKServiceManager.m
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import "AKAirplayManager.h"

@implementation AKAirplayManager

#pragma mark -
#pragma mark Initialization

- (id)init
{
    self = [super init];

	if(self) {
		self.foundServices = [[NSMutableArray alloc] init];
	}
	
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)findDevices
{
	self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
	[self.serviceBrowser setDelegate:self];
	[self.serviceBrowser searchForServicesOfType:@"_airplay._tcp" inDomain:@"local."];
}

- (void)connectToDevice:(AKDevice *)device
{
    self.connectedDevice = device;
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error;
    [self.socket connectToHost:self.connectedDevice.hostname onPort:self.connectedDevice.port error:&error];
    if (error) {
        NSLog(@"%@", error);
    }

}

#pragma mark -
#pragma mark Net Service Browser Delegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	[aNetService setDelegate:self];
	[aNetService resolveWithTimeout:20.0];
	[self.foundServices addObject:aNetService];
	
}

#pragma mark -
#pragma mark Net Service Delegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	AKDevice *device = [[AKDevice alloc] init];
	device.hostname = sender.hostName;
	device.port = sender.port;
	
    if(!self.delegate) {
        NSLog(@"Airplay Manager Delegate not set.");
        return;
    }
    
    [self.delegate airplayManager:self didFindDevice:device];
}

#pragma mark -
#pragma mark AsyncSocket Delegate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	self.connectedDevice.socket = sock;
	self.connectedDevice.connected = YES;
    
	if(!self.delegate) {
        NSLog(@"Airplay Manager Delegate not set.");
        return;
    }
    
    [self.connectedDevice sendReverse];
    [self.delegate airplayManager:self didConnectToDevice:self.connectedDevice];

}

@end
