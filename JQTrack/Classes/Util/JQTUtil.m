//
//  JQTUtil.m
//  JQTrack
//
//  Created by jqoo on 2018/11/16.
//

#import "JQTUtil.h"
#import <zlib.h>

@implementation JQTUtil

+ (NSData *)zipData:(NSData *)data {
    const NSUInteger kChunkSize = 16*1024;
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)data.length;
    stream.next_in = (Bytef *)(void *)data.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    NSMutableData *output = nil;
    int compression = Z_DEFAULT_COMPRESSION;
    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
        output = [NSMutableData dataWithLength:kChunkSize];
        while (stream.avail_out == 0) {
            if (stream.total_out >= output.length) {
                output.length += kChunkSize;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }
        deflateEnd(&stream);
        output.length = stream.total_out;
    }
    return output;
}

// Based on hints from http://stackoverflow.com/questions/1850824/parsing-a-rfc-822-date-with-nsdateformatter
+ (NSDate *)dateFromRFC1123String:(NSString *)string
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *loc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:loc];
    // Does the string include a week day?
    NSString *day = @"";
    if ([string rangeOfString:@","].location != NSNotFound) {
        day = @"EEE, ";
    }
    // Does the string include seconds?
    NSString *seconds = @"";
    if ([[string componentsSeparatedByString:@":"] count] == 3) {
        seconds = @":ss";
    }
    [formatter setDateFormat:[NSString stringWithFormat:@"%@dd MMM yyyy HH:mm%@ z",day,seconds]];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+ (SEL)selectorForOrigin:(SEL)originSelector withPrefix:(NSString *)prefix {
    return NSSelectorFromString([NSString stringWithFormat:@"%@_%@", prefix, NSStringFromSelector(originSelector)]);
}

@end

BOOL JQTLogEnable;

void (^JQTLogger)(NSString *fmt, ...) = ^(NSString *fmt, ...){
    va_list args;
    va_start(args, fmt);
    NSLogv(fmt, args);
    va_end(args);
};
