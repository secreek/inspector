//
//  NSDictionary+IZM_JSONSupport.m
//  izhuomi_ios
//
//  Created by Xinrong Guo on 13-4-10.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "NSDictionary+IZM_JSONSupport.h"
#import "INSPLogUtlils.h"

@implementation NSDictionary (IZM_JSONSupport)

+(NSDictionary *)izm_dictionaryWithContentsOfJSONFileURL:(NSURL *)url {
    NSDictionary *dict = nil;
    NSError *err;
    NSData *data = [NSData dataWithContentsOfURL:url options:kNilOptions error:&err];
    if (err) {
        INSPALog(@"%@", [err localizedDescription]);
    }
    else {
        dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        
        if (err) {
            dict = nil;
            INSPALog(@"%@", [err localizedDescription]);
        }
    }
    
    return dict;
}

+(NSDictionary *)izm_dictionaryWithContentsOfJSONFilePath:(NSString *)path {
    NSDictionary *dict = nil;
    NSError *err;
    NSData *data = [NSData dataWithContentsOfFile:path options:kNilOptions error:&err];
    if (err) {
        INSPALog(@"%@", [err localizedDescription]);
    }
    else {
        dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        
        if (err) {
            dict = nil;
            INSPALog(@"%@", [err localizedDescription]);
        }
    }
    
    return dict;
}

@end
