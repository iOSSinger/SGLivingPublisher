//
//  SGRtmpSessionConfigModel.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/21.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGRtmpConfig : NSObject

@property (nonatomic,copy  ) NSString *url;
@property (nonatomic,assign) int32_t  width;
@property (nonatomic,assign) int32_t  height;
@property (nonatomic,assign) double   frameDuration;
@property (nonatomic,assign) int32_t  videoBitrate;
@property (nonatomic,assign) double   audioSampleRate;
@property (nonatomic,assign) BOOL     stereo;//立体声

@end
