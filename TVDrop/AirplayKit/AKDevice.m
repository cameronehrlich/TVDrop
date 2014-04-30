//
//  AKDevice.m
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import "AKDevice.h"

#define kSocketTimeout 20.00

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

- (void)sendRawMessage:(NSString *)message
{
	[self sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)sendContentURL:(NSString *)url
{
    self.playing = YES;
	NSString *body = [[NSString alloc] initWithFormat:
                      @"Content-Location: %@\r\n"
                      "Start-Position: 0\r\n\r\n", url];
    
	NSUInteger length = [body length];
	
	NSString *message = [[NSString alloc] initWithFormat:
                         @"POST /play HTTP/1.1\r\n"
                         "Content-Length: %lu\r\n"
                         "User-Agent: MediaControl/1.0\r\n\r\n%@", (unsigned long)length, body];
	
	
	[self sendRawMessage:message];
}

- (void)sendImage:(NSImage *)image
{
    self.playing = NO;
    
    [image lockFocus] ;
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, [image size].width, [image size].height)] ;
    [image unlockFocus] ;
    
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
	[self sendRawMessage:message];
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
	[self sendRawMessage:message];
}

- (void)sendReverse
{
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
	if([self.delegate respondsToSelector:@selector(device:didSendBackMessage:)])
	{
		NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[self.delegate device:self didSendBackMessage:message];
	}
}

@end