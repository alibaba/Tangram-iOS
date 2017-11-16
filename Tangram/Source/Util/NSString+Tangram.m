//
//  NSString+Tangram.m
//  Tangram
//
//  Created by HarrisonXi on 2017/11/16.
//

#import "NSString+Tangram.h"

@implementation NSString (Tangram)

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
