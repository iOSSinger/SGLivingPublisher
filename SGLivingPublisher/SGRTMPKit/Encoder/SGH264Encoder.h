//
//  SGH264Encoder.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/21.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SGVideoConfig.h"


@class SGH264Encoder;
@protocol SGH264EncoderDeleagte <NSObject>

- (void)h264Encoder:(SGH264Encoder *)encoder didGetSps:(NSData *)spsData pps:(NSData *)ppsData timestamp:(uint64_t)timestamp;

- (void)h264Encoder:(SGH264Encoder *)encoder didEncodeFrame:(NSData *)data timestamp:(uint64_t)timestamp isKeyFrame:(BOOL)isKeyFrame;

@end

@interface SGH264Encoder : NSObject
@property (nonatomic,strong) SGVideoConfig *config;

@property (nonatomic,weak) id<SGH264EncoderDeleagte> delegate;

- (void)stopEncoder;

- (void)encodeVideoData:(CVPixelBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;
@end
