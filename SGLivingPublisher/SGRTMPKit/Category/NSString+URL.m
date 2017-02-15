//
//  NSString+URL.m
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/17.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)
- (NSString *)scheme{
    return [self componentsSeparatedByString:@"://"].firstObject;
}
- (NSString *)host{
    NSURL *url = [NSURL URLWithString:self];
    return url.host;
}
- (NSString *)app{
    NSString *sep = [NSString stringWithFormat:@"%@/",self.host];
    NSString *res = [self componentsSeparatedByString:sep].lastObject;
    return [res componentsSeparatedByString:@"/"].firstObject;
}
- (NSString *)playPath{
    NSString *sep = [NSString stringWithFormat:@"%@/",self.host];
    NSString *res = [self componentsSeparatedByString:sep].lastObject;
    NSString *reu = [res componentsSeparatedByString:@"/"].lastObject;
    return [reu componentsSeparatedByString:@":"].firstObject;
}
- (UInt32)port{
    NSString *sep = [NSString stringWithFormat:@"%@/",self.host];
    NSString *res = [self componentsSeparatedByString:sep].lastObject;
    NSString *reu = [res componentsSeparatedByString:@"/"].lastObject;
    NSArray  *ret = [reu componentsSeparatedByString:@":"];
    if (ret.count < 2) {
        return 0;
    }
    return [ret.lastObject intValue];
}
@end
