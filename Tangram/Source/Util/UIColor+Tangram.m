//
//  UIColor+Tangram.m
//  Tangram
//
//  Created by HarrisonXi on 2017/11/16.
//

#import "UIColor+Tangram.h"

@implementation UIColor (Tangram)

+ (UIColor *)colorWithHexValue:(NSUInteger)hexValue
{
    CGFloat r = ((hexValue & 0x00FF0000) >> 16) / 255.0;
    CGFloat g = ((hexValue & 0x0000FF00) >> 8) / 255.0;
    CGFloat b = (hexValue & 0x000000FF) / 255.0;
    return [self colorWithRed:r green:g blue:b alpha:1];
}

+ (UIColor *)colorWithString:(NSString *)string
{
    NSUInteger len = [string length];
    NSUInteger hexValue = 0;
    NSUInteger alpha = 1.f;
    if (len == 8 || (len == 9 && [string characterAtIndex:0] == (unichar)'#')) {
        hexValue = [UIColor hexValueOfString:[string lowercaseString]];
        alpha = (hexValue & 0xFF000000) >> 24;
        hexValue = hexValue & 0x00FFFFFF;
    }
    else if (len == 6 || (len == 7 && [string characterAtIndex:0] == (unichar)'#')) {
        hexValue = [UIColor hexValueOfString:[string lowercaseString]];
        alpha = 255.f;
    }
    else if (len == 3 || (len == 4 && [string characterAtIndex:0] == (unichar)'#')) {
        hexValue = [UIColor hexValueOfString:[string lowercaseString]];
        alpha = 255.f;
    }
    return [UIColor colorWithHexValue:hexValue];
}

+ (NSUInteger)hexValueOfString:(NSString *)string
{
    unsigned result = 0;
    NSString *newString = string;
    if([newString hasPrefix:@"#"])
    {
        newString = [string substringFromIndex:1];
    }
    else if([newString hasPrefix:@"0x"])
    {
        newString = [string substringFromIndex:2];
    }
    if(newString.length == 3)
    {
        unichar str[6] = {0};
        for(int i = 0; i < 3; i++)
        {
            unichar ch = [newString characterAtIndex:i];
            str[i*2] = ch;
            str[i*2+1] = ch;
        }
        newString = [NSString stringWithCharacters:str length:6];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:newString];
    [scanner scanHexInt:&result];
    return result;
}

@end
