//
//  SGRtmpSession.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/16.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGFrame.h"

typedef NS_ENUM(NSUInteger, SGRtmpSessionStatus) {
    SGRtmpSessionStatusNone              = 0,
    SGRtmpSessionStatusConnected         = 1,

    SGRtmpSessionStatusHandshake0        = 2,
    SGRtmpSessionStatusHandshake1        = 3,
    SGRtmpSessionStatusHandshake2        = 4,
    SGRtmpSessionStatusHandshakeComplete = 5,

    SGRtmpSessionStatusFCPublish         = 6,
    SGRtmpSessionStatusReady             = 7,
    SGRtmpSessionStatusSessionStarted    = 8,

    SGRtmpSessionStatusError             = 9,
    SGRtmpSessionStatusNotConnected      = 10
};

@class SGRtmpSession;
@protocol SGRtmpSessionDeleagte <NSObject>

- (void)rtmpSession:(SGRtmpSession *)rtmpSession didChangeStatus:(SGRtmpSessionStatus)rtmpStatus;

@end

@class SGRtmpConfig;
@interface SGRtmpSession : NSObject

@property (nonatomic,strong) SGRtmpConfig *config;

@property (nonatomic,weak) id<SGRtmpSessionDeleagte> delegate;

- (void)connect;

- (void)disConnect;

- (void)sendBuffer:(SGFrame *)frame;
@end
