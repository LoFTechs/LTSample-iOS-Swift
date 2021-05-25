//
//  NSString+Support.m
//  juiker
//
//  Created by Huang Tsung-Jen on 13/7/16.
//  Copyright (c) 2013年 李承翰. All rights reserved.
//

#import "NSString+Support.h"
#import <CommonCrypto/CommonDigest.h>


static inline NSString *NSStringCCHashFunction(unsigned char *(function)(const void *data, CC_LONG len, unsigned char *md), CC_LONG digestLength, NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[digestLength];
    
    function(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:digestLength * 2];
    
    for (int i = 0; i < digestLength; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@implementation NSString (Hashes)

- (NSString *)md5
{
    return NSStringCCHashFunction(CC_MD5, CC_MD5_DIGEST_LENGTH, self);
}

- (NSString *)sha1
{
    return NSStringCCHashFunction(CC_SHA1, CC_SHA1_DIGEST_LENGTH, self);
}

- (NSString *)sha224
{
    return NSStringCCHashFunction(CC_SHA224, CC_SHA224_DIGEST_LENGTH, self);
}

- (NSString *)sha256
{
    return NSStringCCHashFunction(CC_SHA256, CC_SHA256_DIGEST_LENGTH, self);
}

- (NSString *)sha384
{
    return NSStringCCHashFunction(CC_SHA384, CC_SHA384_DIGEST_LENGTH, self);
}
- (NSString *)sha512
{
    return NSStringCCHashFunction(CC_SHA512, CC_SHA512_DIGEST_LENGTH, self);
}

@end

@implementation NSString (Support)

// "psuedo-numeric" comparison
//   -- if both strings begin with digits, numeric comparison on the digits
//   -- if numbers equal (or non-numeric), caseInsensitiveCompare on the remainder
- (NSString*) SHA256
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, (CC_LONG)strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19],
                   result[20], result[21], result[22], result[23], result[24],
                   result[25], result[26], result[27],
                   result[28], result[29], result[30], result[31]
                   ];
    return [s lowercaseString];
}

- (NSComparisonResult) psuedoNumericCompare:(NSString *)otherString {
    
    NSString *left  = self;
    NSString *right = otherString;
    NSInteger leftNumber, rightNumber;
    
    
    NSScanner *leftScanner = [NSScanner scannerWithString:left];
    NSScanner *rightScanner = [NSScanner scannerWithString:right];
    
    // if both begin with numbers, numeric comparison takes precedence
    if ([leftScanner scanInteger:&leftNumber] && [rightScanner scanInteger:&rightNumber]) {
        if (leftNumber < rightNumber)
            return NSOrderedAscending;
        if (leftNumber > rightNumber)
            return NSOrderedDescending;
        
        // if numeric values tied, compare the rest
        left = [left substringFromIndex:[leftScanner scanLocation]];
        right = [right substringFromIndex:[rightScanner scanLocation]];
    }
    
    return [left caseInsensitiveCompare:right];
}


static NSComparisonResult compareStringByPassingLocaleName(NSString *a, NSString *b, const char *localeName)
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:[NSString stringWithUTF8String:localeName]];
    NSComparisonResult result = [a compare:b options:0 range:NSMakeRange(0, [a length]) locale:locale];
    return result;
}
#define COMPARE(x) ((NSComparisonResult)compareStringByPassingLocaleName(self, anotherString, x))
- (NSComparisonResult)compareChineseByStrokeOrder:(NSString *)anotherString
{
    return COMPARE("zh@collation=stroke");
}
- (NSComparisonResult)compareChineseByPinyinOrder:(NSString *)anotherString
{
    return COMPARE("zh@collation=pinyin");
}
- (NSComparisonResult)compareChineseByBIG5Order:(NSString *)anotherString
{
    return COMPARE("zh@collation=big5han");
}
- (NSComparisonResult)compareChineseByGB2312Order:(NSString *)anotherString
{
    return COMPARE("zh@collation=gb2312");
}
- (NSComparisonResult)compareChineseByRadicalOrder:(NSString *)anotherString
{
    return COMPARE("zh@collation=unihan");
}

@end
