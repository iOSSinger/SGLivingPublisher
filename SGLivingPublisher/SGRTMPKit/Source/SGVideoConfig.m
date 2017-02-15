//
//  SGVideoConfig.m
//  SGLivingPublisher
//
//  Created by iossinger on 16/7/3.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import "SGVideoConfig.h"

@implementation SGVideoConfig

+ (instancetype)defaultConfig{
    SGVideoConfig *config = [[self alloc] init];
    config.videoSize = CGSizeMake(480, 640);
    config.bitrate = 512 *1024;
    config.fps = 15;
    config.level = SGProfileLevel_H264_Baseline_AutoLevel;
    config.keyframeInterval = config.fps *2;
    return config;
}

- (NSString *)description{
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"{\n"];
    [desc appendFormat:@"class: %@\n",[self class]];
    [desc appendFormat:@"videoSize:%@\n",NSStringFromCGSize(self.videoSize)];
    [desc appendFormat:@"bitRate:%d\n",self.bitrate];
    [desc appendFormat:@"fps:%d\n}",self.fps];
    return desc;
}
@end
