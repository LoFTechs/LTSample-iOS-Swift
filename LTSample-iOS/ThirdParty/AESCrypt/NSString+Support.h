//
//  NSString+Support.h
//  juiker
//
//  Created by Huang Tsung-Jen on 13/7/16.
//  Copyright (c) 2013年 李承翰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hashes)

- (NSString *)md5;
- (NSString *)sha1;
- (NSString *)sha224;
- (NSString *)sha256;
- (NSString *)sha384;
- (NSString *)sha512;

@end

@interface NSString (Support)
- (NSString*) SHA256;
- (NSComparisonResult) psuedoNumericCompare:(NSString *)otherString;
- (NSComparisonResult)compareChineseByStrokeOrder:(NSString *)anotherString;
- (NSComparisonResult)compareChineseByPinyinOrder:(NSString *)anotherString;
- (NSComparisonResult)compareChineseByBIG5Order:(NSString *)anotherString;
- (NSComparisonResult)compareChineseByGB2312Order:(NSString *)anotherString;
- (NSComparisonResult)compareChineseByRadicalOrder:(NSString *)anotherString;
@end