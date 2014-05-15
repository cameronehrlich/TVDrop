//
//  AKDevice.h
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import <CocoaAsyncSocket/AsyncSocket.h>

@class AKDevice;

@protocol AKDeviceDelegate <NSObject>

@optional
- (void)device:(AKDevice *)device didSendBackMessage:(NSString *)message;
@end

@interface AKDevice : NSObject <AsyncSocketDelegate>

@property (nonatomic, assign  ) id <AKDeviceDelegate> delegate;
@property (nonatomic, readonly) NSString         *displayName;
@property (nonatomic, strong  ) NSString         *hostname;
@property (nonatomic, assign  ) UInt16           port;
@property (nonatomic, strong  ) AsyncSocket      *socket;
@property (nonatomic, strong  ) NSNetService     *netService;
@property (nonatomic, strong  ) NSTimer          *keepAliveTimer;

@property (nonatomic, assign) BOOL              connected;
@property (nonatomic, assign) BOOL              playing;
@property (nonatomic, strong) NSNumber          *duration;
@property (nonatomic, strong) NSNumber          *position;

- (void)sendRawData:(NSData *)data;
- (void)sendContentURL:(NSString *)url;
- (void)sendImage:(NSImage *)image;

- (void)sendPlayPause;
- (void)sendStop;
- (void)sendReverse;
- (void)sendServerInfo;
- (void)sendSeekForward;
- (void)sendSeekBackward;
- (void)sendPlaybackInfo;

@end
