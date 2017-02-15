//
//  SGH264Packager.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/22.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGFrame.h"


@class SGH264Packager;
@protocol SGH264PackagerDelegate <NSObject>

- (void)h264Packager:(SGH264Packager *)packager didPacketFrame:(SGFrame *)frame;

@end

@interface SGH264Packager : NSObject

@property (nonatomic,weak) id<SGH264PackagerDelegate> delegate;

- (void)reset;

- (void)packageKeyFrameSps:(NSData *)spsData pps:(NSData *)ppsData timestamp:(uint64_t)timestamp;

- (void)packageFrame:(NSData *)data timestamp:(uint64_t)timestamp isKeyFrame:(BOOL)isKeyFrame;
@end
