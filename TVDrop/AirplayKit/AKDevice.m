//
//  AKDevice.m
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import "AKDevice.h"
#import "AKRequest.h"

#define kSocketTimeout 30
#define kKeepAliveInterval 5.0

@implementation AKDevice

#pragma mark -
#pragma mark Initialization

- (id) init
{
    self = [super init];
    
	if(self){
		self.connected = NO;
	}
	
	return self;
}

- (NSString *)displayName
{
	NSString *name = self.hostname;
    
	if([self.hostname rangeOfString:@"-"].length != 0)
	{
		name = [self.hostname stringByReplacingCharactersInRange:[self.hostname rangeOfString:@"-"] withString:@" "];
	}
	
	if([name rangeOfString:@".local."].length != 0)
	{
		name = [name stringByReplacingCharactersInRange:[name rangeOfString:@".local."] withString:@""];
	}
	
	return name;
}

#pragma mark -
#pragma mark Public Methods

- (void)sendRawData:(NSData *)data
{
	self.socket.delegate = self;
	[self.socket writeData:data withTimeout:kSocketTimeout tag:1];
	[self.socket readDataWithTimeout:kSocketTimeout tag:1];
}

- (void)sendContentURL:(NSString *)url
{
    self.playing = YES;

    NSString *body = [[NSString alloc] initWithFormat:
                      @"Content-Location: %@\r\n"
                      "Start-Position: 0\r\n\r\n", url];
    
    
    AKRequest *request = [[AKRequest alloc] init];
    [request setRequestType:AKRequestTypePOST];
    [request setPath:@"play"];
    [request addParameterKey:@"Content-Length" withValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]]];
    [request setBody:body];
    
    [self sendRawData:[request requestData]];
    
//	NSUInteger length = [body length];
//	
//	NSString *message = [[NSString alloc] initWithFormat:
//                         @"POST /play HTTP/1.1\r\n"
//                         "Content-Length: %lu\r\n"
//                         "User-Agent: MediaControl/1.0\r\n\r\n%@", (unsigned long)length, body];
//    
//    NSLog(@"Number #2: %@", message);
//    
//    [self sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding];
    
    
    // Start Timer
	self.keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:kKeepAliveInterval
                                                           target:self
                                                         selector:@selector(sendReverse)
                                                         userInfo:nil
                                                          repeats:YES];

}

- (void)sendImage:(NSImage *)image
{
    self.playing = NO;
    
    [image lockFocus];
    
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, [image size].width, [image size].height)];
    
    [image unlockFocus];
    
    NSData *imageData = [bitmapRep representationUsingType:NSJPEGFileType properties:nil];
    
    NSUInteger length = [imageData length];
    
    NSString *message = [[NSString alloc] initWithFormat:
                         @"PUT /photo HTTP/1.1\r\n"
                         "Content-Length: %lu\r\n"
                         "User-Agent: MediaControl/1.0\r\n\r\n", (unsigned long)length];
    
    NSMutableData *messageData = [[NSMutableData alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    
    [messageData appendData:imageData];
    
    [self sendRawData:messageData];
}

- (void)sendStop
{
    self.playing = NO;
	NSString *message =
    @"POST /stop HTTP/1.1\r\n"
    "User-Agent: MediaControl/1.0\r\n\r\n";
    [self sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [self.keepAliveTimer invalidate];
}

- (void)sendPlayPause
{
    self.playing = !self.playing;
    
    NSString *postRequest = [NSString stringWithFormat:@"POST /rate?value=%d HTTP/1.1\r\n", self.playing];
	NSString *message = [postRequest stringByAppendingString:
    @"Upgrade: PTTH/1.0\r\n"
    "Connection: Upgrade\r\n"
    "Content-Length: 0\r\n"
    "X-Apple-Purpose: event\r\n"
    "User-Agent: MediaControl/1.0\r\n\r\n"];
    
    [self sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)sendReverse
{
    AKRequest *request = [[AKRequest alloc] init];
    [request setRequestType:AKRequestTypePOST];
    [request setPath:@"reverse"];
    [request addParameterKey:@"Upgrade" withValue:@"PTTH/1.0"];
    [request addParameterKey:@"Connection" withValue:@"Upgrade"];
    [request addParameterKey:@"X-Apple-Purpose" withValue:@"event"];
    [request addParameterKey:@"Content-Length" withValue:@"0"];
    
	[self sendRawData:[request requestData]];
    
    
    NSString *message =
    @"POST /reverse HTTP/1.1\r\n"
    "Upgrade: PTTH/1.0\r\n"
    "Connection: Upgrade\r\n"
    "X-Apple-Purpose: event\r\n"
    "Content-Length: 0\r\n"
    "User-Agent: MediaControl/1.0\r\n\r\n";
	
	[self sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark -
#pragma mark Socket Delegate

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"\r\nReading: %@", message);
}

@end