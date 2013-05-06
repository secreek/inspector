//
//  NSDictionary+IZM_JSONSupport.h
//  izhuomi_ios
//
//  Created by Xinrong Guo on 13-4-10.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (IZM_JSONSupport)

+(NSDictionary *)izm_dictionaryWithContentsOfJSONFileURL:(NSURL *)url;

+(NSDictionary *)izm_dictionaryWithContentsOfJSONFilePath:(NSString *)path;

@end
