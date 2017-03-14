//
//  MFHTTPSessionManager.h
//  MFBaseProject
//
//  Created by shamic on 17/3/3.
//  Copyright © 2017年 shamic. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#define kErrorDomain     @"com.shamic.AFHTTPSessionManager"
#define kRequestTimeoutInterval 15.0f
#define kNetErrorCode 0xFF0C

#if !defined(PRODUCT) && !defined(STAGE) && !defined(QA) && !defined(AUTOTEST)
    #define ALLOW_INVALID_CERTIFICATES
#endif

#ifndef PRODUCT
    #define DETAILED_NETWORK_LOG
#endif

@protocol MFNetworkReachableDelegate, MFHTTPSessionManagerDelegate;

@interface MFHTTPSessionManager : AFHTTPSessionManager

@property (weak, nonatomic) id<MFNetworkReachableDelegate> networkReachableDelegate;
@property (weak, nonatomic) id<MFHTTPSessionManagerDelegate> delegate;

+ (instancetype)mobileInstance;
- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

@end

@protocol MFNetworkReachableDelegate <NSObject>
- (void)networkAccess:(AFHTTPSessionManager *)networkAccess toggledToReachable:(BOOL)reachable;
@end

@protocol MFHTTPSessionManagerDelegate <NSObject>

@optional
- (void)networkAccess:(MFHTTPSessionManager *)networkAccess unreachableForRequest:(NSURLRequest *)request;

@end
