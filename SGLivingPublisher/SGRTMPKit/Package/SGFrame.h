//
//  SGFrame.h
//  SGLivingPublisher
//
//  Created by iossinger on 16/7/4.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGFrame : NSObject
//数据
@property (nonatomic,strong) NSData *data;

//时间戳
@property (nonatomic,assign) int timestamp;

//长度
@property (nonatomic,assign) int msgLength;

//typeId
@property (nonatomic,assign) int msgTypeId;

//msgStreamId
@property (nonatomic,assign) int msgStreamId;

//关键帧
@property (nonatomic,assign) BOOL isKeyframe;

@end
