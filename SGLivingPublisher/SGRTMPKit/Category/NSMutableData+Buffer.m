//
//  NSMutableData+Buffer.m
//  SGLivingPublisher
//
//  Created by iossinger on 16/6/2.
//  Copyright © 2016年 iossinger. All rights reserved.
//

#import "NSMutableData+Buffer.h"

@implementation NSMutableData (Buffer)
+ (char *)be24:(int32_t)val{
    static char buf[3];//注意static
    buf[2] = val & 0xff;
    buf[1] = (val >> 8) & 0xff;
    buf[0] = (val >> 16) & 0xff;
    return buf;
}

/**拼接 数据*/
- (void)appendBuff:(const uint8_t *)src : (size_t)srcsize
{
    [self appendBytes:src length:srcsize];
}

/**拼接一个字节数据*/
- (void)appendByte:(uint8_t)val
{
    [self appendBytes:&val length:1];
}

/**拼接2字节,转换为大端*/
- (void)appendByte16:(short)val
{
    char buf[2];
    buf[1] = val & 0xff;
    buf[0] = (val >> 8) & 0xff;
    [self appendBuff:(const uint8_t*)buf :sizeof(uint16_t)];
}

/**获取前两个字节*/
+ (int)getByte16:(uint8_t *)val{
    return ((val[0]&0xff) << 8) | ((val[1]&0xff)) ;
}

/**追加三个字节*/
- (void)appendByte24:(int32_t)val
{
    char buf[3];
    buf[2] = val & 0xff;
    buf[1] = (val >> 8) & 0xff;
    buf[0] = (val >> 16) & 0xff;
    [self appendBuff:(const uint8_t*)buf :3];

}

/**获取前三个字节*/
+ (int)getByte24:(uint8_t *)val{
    int ret = ((val[2]&0xff)) | ((val[1]&0xff) << 8) | ((val[0]&0xff)<<16) ;
    return ret;
}

/**追加四个字节数据*/
- (void)appendByte32:(int32_t)val
{
    char buf[4];
    
    buf[3] = val & 0xff;
    buf[2] = (val >> 8) & 0xff;
    buf[1] = (val >> 16) & 0xff;
    buf[0] = (val >> 24) & 0xff;
    
    [self appendBuff:(const uint8_t*)buf :sizeof(int32_t)];
}
/**获取前四个字节*/
+ (int)getByte32:(uint8_t *)val{
    return ((val[0]&0xff)<<24) | ((val[1]&0xff)<<16) | ((val[2]&0xff) << 8) | ((val[3]&0xff)) ;
}

/**追加字符串*/
- (void)appendString:(NSString *)string{
    if(string.length < 0xFFFF) {
        [self appendByte:kAMFString];
        [self appendByte16:string.length];
    } else {
        [self appendByte:kAMFLongString];
        [self appendByte32:(int32_t)(string.length)];
    }
    
    [self appendBuff:(const uint8_t*)string.UTF8String :string.length];
}

/**获取字符串*/
+ (NSString *)getString:(uint8_t *)buf : (int *)bufsize{
    int len = 0;
    if(*buf++ == kAMFString) {
        len =[self  getByte16:buf];
        buf+=2;
        *bufsize = 2 + len;
    } else {
        len = [self getByte32:buf];
        buf+=4;
        *bufsize = 4 + len;
    }
    
    return [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
}

/**拼接double类型数据*/
- (void)appendDouble:(double)val{
    [self appendByte:kAMFNumber];
     CFSwappedFloat64 buf = CFConvertFloat64HostToSwapped(val);
    [self appendBuff:(uint8_t*)&buf :sizeof(CFSwappedFloat64)];
}

/**获取double数据*/
+ (double)getDouble:(uint8_t *)buf{
    CFSwappedFloat64 arg;
    memcpy(&arg, buf, sizeof(arg));
    return CFConvertDoubleSwappedToHost(arg);
}
 
/**拼接bool类型数据*/
- (void)appendBool:(bool)val{
    [self appendByte:kAMFBoolean];
    [self appendByte:val];
}

/**添加string*/
- (void)putKey:(NSString *)key{
    [self appendByte16:key.length];
    [self appendBuff:(uint8_t*)key.UTF8String :key.length];
}

/**添加stringValue*/
- (void)putStringValue:(NSString *)value{
    [self putKey:value];
}

/**添加string-double键值对*/
- (void)putKey:(NSString *)key doubleValue:(double)val{
    [self putKey:key];
    [self appendDouble:val];
}
 
/**添加string-string键值对*/
- (void)putKey:(NSString *)key stringValue:(NSString *)val{
    [self putKey:key];
    [self appendString:val];
}

/**添加string-bool键值对*/
- (void)putKey:(NSString *)key boolValue:(bool)val{
    [self putKey:key];
    [self appendBool:val];
}

@end
