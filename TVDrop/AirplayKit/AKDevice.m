//
//  AKDevice.m
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import <RXMLElement.h>

#import "AKDevice.h"
#import "AKRequest.h"
#import "AKResponse.h"

#define kSocketTimeout 30
#define kKeepAliveInterval 1.0
#define kScrubSpeed 30.0

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

- (void)sendRequest:(AKRequest *)request
{
    [self sendRawData:[request requestData]];
}

- (void)sendRawData:(NSData *)data
{
	self.socket.delegate = self;
	[self.socket writeData:data withTimeout:kSocketTimeout tag:1];
	[self.socket readDataWithTimeout:kSocketTimeout tag:1];
}

- (void)sendContentURL:(NSString *)url
{
    NSString *body = [[NSString alloc] initWithFormat: @"Content-Location: %@\r\n""Start-Position: 0\r\n\r\n", url];
    
    AKRequest *request = [[AKRequest alloc] init];
    [request setRequestType:AKRequestTypePOST];
    [request setPath:@"play"];
    [request setBody:body];
    
    [self sendRawData:[request requestData]];
    
    // Start Timer
	self.keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:kKeepAliveInterval
                                                           target:self
                                                         selector:@selector(sendPlaybackInfo)
                                                         userInfo:nil
                                                          repeats:YES];

}

- (void)sendImage:(NSImage *)image
{
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
    
    
    AKRequest *request = [AKRequest requestPath:@"photo" withType:AKRequestTypePUT];
    [request setBody:[[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding]];
    
    [self sendRawData:[request requestData]];
}

- (void)sendStop
{
    AKRequest *request =[AKRequest requestPath:@"stop" withType:AKRequestTypePOST];
    [self sendRequest:request];
    
    [self.keepAliveTimer invalidate];
}

- (void)sendPlayPause
{
    AKRequest *request = [AKRequest requestPath:[NSString stringWithFormat:@"rate?value=%d", !self.playing] withType:AKRequestTypePOST];
    [request addParameterKey:@"Upgrade" withValue:@"PTTH/1.0"];
    [request addParameterKey:@"Connection" withValue:@"Upgrade"];
    [request addParameterKey:@"Content-Length" withValue:@"0"];
    [request addParameterKey:@"X-Apple-Purpose" withValue:@"event"];

    [self sendRequest:request];
}

- (void)sendReverse
{
    AKRequest *request = [AKRequest requestPath:@"reverse" withType:AKRequestTypePOST];
    [request addParameterKey:@"Upgrade" withValue:@"PTTH/1.0"];
    [request addParameterKey:@"Connection" withValue:@"Upgrade"];
    [request addParameterKey:@"X-Apple-Purpose" withValue:@"event"];
    [request addParameterKey:@"Content-Length" withValue:@"0"];
    
	[self sendRequest:request];
}

- (void)sendServerInfo
{
    AKRequest *request = [AKRequest requestPath:@"server-info" withType:AKRequestTypeGET];
    [self sendRequest:request];
}

- (void)sendSeekForward
{
    float newPosition = MIN(self.duration.floatValue, self.position.floatValue + kScrubSpeed);
    self.position = @(newPosition);
    
    NSString *path = [NSString stringWithFormat:
                      @"scrub?position=%f",
                      newPosition];
    
    AKRequest *request = [AKRequest requestPath:path withType:AKRequestTypePOST];
    [self sendRequest:request];
}

- (void)sendSeekBackward
{
    float newPosition = MAX(0.0, self.position.floatValue - kScrubSpeed);
    self.position = @(newPosition);

    NSString *path = [NSString stringWithFormat:
                      @"scrub?position=%f",
                      newPosition];
    
    AKRequest *request = [AKRequest requestPath:path withType:AKRequestTypePOST];
    [self sendRequest:request];
}

- (void)sendPlaybackInfo
{
    AKRequest *request = [AKRequest requestPath:@"playback-info" withType:AKRequestTypeGET];
    [self sendRequest:request];
}

#pragma mark -
#pragma mark Socket Delegate

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    AKResponse *response = [AKResponse responseWithData:data];
    if ([response body]) {
        RXMLElement *xml = [RXMLElement elementFromXMLString:[response body] encoding:NSUTF8StringEncoding];
        // FIXME : MASSIVE HACK, FUCK PLISTS
        NSArray *values = [[xml child:@"dict"] children:@"real"];

        if(values.count > 0){
            self.duration = @([[[values objectAtIndex:0] text] floatValue]);
            self.position = @([[[values objectAtIndex:1] text] floatValue]);
            self.playing  = [[[values objectAtIndex:2] text] boolValue];
        }
    }
}

@end