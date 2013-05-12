//
//  NSString+ImageName.m
//  Inspector
//
//  Created by Xinrong Guo on 13-5-12.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "NSString+ImageName.h"

@implementation NSString (ImageName)

+ (NSString *)highResImageNameFromNormalResImageName:(NSString *)imageName {
    NSArray *components = [imageName componentsSeparatedByString:@"."];
    if ([components count] > 1) {
        NSMutableArray *newComponents = [NSMutableArray arrayWithArray:components];
        NSString *fileName = [newComponents objectAtIndex:[newComponents count] - 2];
        NSString *highResFileName = [NSString stringWithFormat:@"%@@2x", fileName];
        [newComponents replaceObjectAtIndex:[newComponents count] - 2 withObject:highResFileName];
        NSString *fullResFileName = [newComponents componentsJoinedByString:@"."];
        return fullResFileName;
    }
    return nil;
}

@end
