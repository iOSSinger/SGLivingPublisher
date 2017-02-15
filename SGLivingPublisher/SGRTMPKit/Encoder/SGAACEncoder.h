//
//  SGAACEncoder.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/22.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SGAudioConfig.h"

@class SGAACEncoder;
@protocol SGAACEncoderDeleagte <NSObject>

- (void)aacEncoder:(SGAACEncoder *)encoder didEncodeBuffer:(NSData *)data timestamp:(uint64_t)timestamp;

@end

@interface SGAACEncoder : NSObject

@property (nonatomic,strong) SGAudioConfig *audioConfig;

@property (nonatomic,weak) id<SGAACEncoderDeleagte> delegate;

- (void)encodeData:(AudioBufferList)inBufferList timestamp:(uint64_t)timestamp;

@end
