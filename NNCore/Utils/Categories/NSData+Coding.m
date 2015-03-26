//
//  NSData+Coding.m
//  Weiyun
//
//  Created by Rico 12-5-16.
//  Copyright (c) 2012年 Rcio Wang. All rights reserved.
//
#import <zlib.h>
#import <CommonCrypto/CommonDigest.h>

#import "NSData+Coding.h"

#define kMemoryChunkSize                1024
#define kFileChunkSize                  (128 * 1024) //128Kb
@implementation NSData (Coding)

- (NSString*)md5Hash {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], (int)[self length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)sha1Hash {
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([self bytes], (int)[self length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
            result[16], result[17], result[18], result[19]
            ];
}

- (NSString*)hexString
{
    static char tbl[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
	NSMutableString* result = [[NSMutableString alloc] init];
    
    char* buf = (char*) self.bytes;
	for(int i = 0; i < self.length; ++i){
        [result appendString:[NSString stringWithFormat:@"%c%c",
                              tbl[(buf[i] & 0xf0) >> 4],
                              tbl[buf[i] & 0x0f] ] ];
	}
         
	return result;
}

#pragma mark - GZip
- (NSData*) compressGZip
{
    NSUInteger      length = [self length];
    int             windowBits = 15 + 16;   //Default + gzip header instead of zlib header
    int             memLevel = 8;           //Default
    int             retCode;
    NSMutableData*  result;
    z_stream        stream;
    unsigned char   output[kMemoryChunkSize];
    uInt            gotBack;
    
    if((length == 0) || (length > UINT_MAX)) //FIXME: Support 64 bit inputs
        return nil;
    
    bzero(&stream, sizeof(z_stream));
    stream.avail_in = (uInt)length;
    stream.next_in = (unsigned char*)[self bytes];
    
    retCode = deflateInit2(&stream, Z_BEST_COMPRESSION, Z_DEFLATED, windowBits, memLevel, Z_DEFAULT_STRATEGY);
    if(retCode != Z_OK) {
        NSLog(@"%s: deflateInit2() failed with error %i", __FUNCTION__, retCode);
        return nil;
    }
    
    result = [NSMutableData dataWithCapacity:(length / 4)];
    do {
        stream.avail_out = kMemoryChunkSize;
        stream.next_out = output;
        retCode = deflate(&stream, Z_FINISH);
        if((retCode != Z_OK) && (retCode != Z_STREAM_END)) {
            NSLog(@"%s: deflate() failed with error %i", __FUNCTION__, retCode);
            deflateEnd(&stream);
            return nil;
        }
        gotBack = kMemoryChunkSize - stream.avail_out;
        if(gotBack > 0)
            [result appendBytes:output length:gotBack];
    } while(retCode == Z_OK);
    deflateEnd(&stream);
    
    return (retCode == Z_STREAM_END ? result : nil);
}

- (NSData*) decompressGZip
{
    NSUInteger      length = [self length];
    int             windowBits = 15 + 16; //Default + gzip header instead of zlib header
    int             retCode;
    unsigned char   output[kMemoryChunkSize];
    uInt            gotBack;
    NSMutableData*  result;
    z_stream        stream;
    uLong           size;
    
    if((length == 0) || (length > UINT_MAX)) //FIXME: Support 64 bit inputs
        return nil;
    
    //FIXME: Remove support for original implementation of -compressGZip which wasn't generating real gzip data 
    if((length >= sizeof(unsigned int)) && ((*((unsigned char*)[self bytes]) != 0x1F) || (*((unsigned char*)[self bytes] + 1) != 0x8B))) {
        size = NSSwapBigIntToHost(*((unsigned int*)[self bytes]));
        result = (size < 0x40000000 ? [NSMutableData dataWithLength:size] : nil); //HACK: Prevent allocating more than 1 Gb
        if(result && (uncompress([result mutableBytes], &size, (unsigned char*)[self bytes] + sizeof(unsigned int), [self length] - sizeof(unsigned int)) != Z_OK))
            result = nil;
        return result;
    }
    
    bzero(&stream, sizeof(z_stream));
    stream.avail_in = (uInt)length;
    stream.next_in = (unsigned char*)[self bytes];
    
    retCode = inflateInit2(&stream, windowBits);
    if(retCode != Z_OK) {
        NSLog(@"%s: inflateInit2() failed with error %i", __FUNCTION__, retCode);
        return nil;
    }
    
    result = [NSMutableData dataWithCapacity:(length * 4)];
    do {
        @autoreleasepool {
            stream.avail_out = kMemoryChunkSize;
            stream.next_out = output;
            retCode = inflate(&stream, Z_NO_FLUSH);
            if ((retCode != Z_OK) && (retCode != Z_STREAM_END)) {
                NSLog(@"%s: inflate() failed with error %i", __FUNCTION__, retCode);
                inflateEnd(&stream);
                return nil;
            }
            gotBack = kMemoryChunkSize - stream.avail_out;
            if(gotBack > 0)
                [result appendBytes:output length:gotBack];
        }
        
    } while(retCode == Z_OK);
    inflateEnd(&stream);
    
    return (retCode == Z_STREAM_END ? result : nil);
}

- (id) initWithGZipFile:(NSString*)path
{
    const char*             string = [path UTF8String];
    BOOL                    success = NO;
    gzFile                  file;
    int                             result;
    size_t                  length;
    char*                   buffer;
    
    file = gzopen(string, "r");
    if(file != NULL) {
        length = kFileChunkSize;
        buffer = malloc(length);
        while(1) {
            result = gzread(file, buffer + length - kFileChunkSize, kFileChunkSize);
            if(result < 0)
                break;
            if(result < kFileChunkSize) {
                length -= kFileChunkSize - result;
                buffer = realloc(buffer, length);
                break;
            }
            length += kFileChunkSize;
            buffer = realloc(buffer, length);
        }
        
        if(result >= 0) {
            if((self = [self initWithBytesNoCopy:buffer length:length freeWhenDone:YES]))
                success = YES;
            else
                free(buffer);
        }
        else
            free(buffer);
        
        gzclose(file);
    }
    
    if(success == NO) {
        return nil;
    }
    
    return self;
}

- (BOOL) writeToGZipFile:(NSString*)path
{
    const char*             string = [path UTF8String];
    BOOL                    success = NO;
    gzFile                  file;
    
    file = gzopen(string, "w9f"); //Stategy is f, h or R - 9 is Z_BEST_COMPRESSION
    if(file == NULL)
        return NO;
    
    if(gzwrite(file, [self bytes], (unsigned)[self length]) == [self length])
        success = YES;
    
    gzclose(file);
    
    if(success == NO)
        unlink(string);
    
    return success;
}
@end
