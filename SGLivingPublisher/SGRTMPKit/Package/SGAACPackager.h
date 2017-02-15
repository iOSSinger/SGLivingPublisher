//
//  SGAACPackager.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/7/4.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGAudioConfig.h"
#import "SGFrame.h"

@class SGAACPackager;
@protocol SGAACPackagerDelegate <NSObject>

- (void)aacPackager:(SGAACPackager *)packager didPackageAudioFrame:(SGFrame *)frame;

@end
@interface SGAACPackager : NSObject

@property (nonatomic,strong) SGAudioConfig *config;

@property (nonatomic,weak) id<SGAACPackagerDelegate> delegate;

- (void)reset;
- (void)packageAudioData:(NSData *)data timestamp:(uint64_t)timestamp;
@end
