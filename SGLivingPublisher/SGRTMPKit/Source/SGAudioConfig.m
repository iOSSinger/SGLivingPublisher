//
//  SGAudioConfigModel.m
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/15.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import "SGAudioConfig.h"

@implementation SGAudioConfig

+ (instancetype)defaultConfig{
    SGAudioConfig *config = [[self alloc] init];
    
    config.channels = 2;
    
    config.bitRate = SGAudioBitRate_Default;
    
    config.sampleRate = SGAudioSampleRate_Defalut;
    
    return config;
}

- (NSString *)description{
     NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"{\n"];
    [desc appendFormat:@"class: %@\n",NSStringFromClass([self class])];
    [desc appendFormat:@"channels:%zd\n",self.channels];
    [desc appendFormat:@"sampleRate:%zd\n",self.sampleRate];
    [desc appendFormat:@"bitRate:%zd\n}",self.bitRate];
    return desc;
}
@end
