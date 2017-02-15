//
//  SGAudioSource.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/14.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SGAudioConfig.h"

@class SGAudioSource;
@protocol SGAudioSourceDelegate <NSObject>

- (void)audioSource:(SGAudioSource *)source didOutputAudioBufferList:(AudioBufferList)bufferList;

@end


@interface SGAudioSource : NSObject
/**
 *  配置
 */
@property (nonatomic,strong) SGAudioConfig *config;

@property (nonatomic,weak) id<SGAudioSourceDelegate> delegate;

- (void)start;

- (void)stop;
@end
