//
//  MFKeyChain.h
//  MFBaseProject
//
//  Created by shamic on 17/3/3.
//  Copyright © 2017年 shamic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface MFKeyChain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)remove:(NSString *)service;

@end
