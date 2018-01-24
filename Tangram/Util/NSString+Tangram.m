//
//  NSString+Tangram.m
//  Tangram
//
//  Copyright (c) 2017-2018 Alibaba. All rights reserved.
//

#import "NSString+Tangram.h"

@implementation NSString (Tangram)

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
