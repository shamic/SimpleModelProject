//
//  MFHTTPSessionManager.m
//  MFBaseProject
//
//  Created by shamic on 17/3/3.
//  Copyright © 2017年 shamic. All rights reserved.
//

#import "MFHTTPSessionManager.h"
#import "MFConstants.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "MFKeyChain.h"

static AFHTTPRequestSerializer *_requestSerializer_ = nil;

@interface MFHTTPRequestSerializer : AFHTTPRequestSerializer
@end

@implementation MFHTTPRequestSerializer

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError * __autoreleasing *)error
{
    // modify request and parameters according to the actual needs
    return [super requestBySerializingRequest:request withParameters:parameters error:error];
}

@end

@implementation MFHTTPSessionManager

+ (AFHTTPRequestSerializer *)requestSerializer
{
    if (!_requestSerializer_) {
        _requestSerializer_ = [MFHTTPRequestSerializer serializer];
        _requestSerializer_.timeoutInterval = kRequestTimeoutInterval;
    }
    
    return _requestSerializer_;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        // set requestSerializer
        self.requestSerializer = [MFHTTPRequestSerializer serializer];
        
        // certificate operation
#ifdef ALLOW_INVALID_CERTIFICATES
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
#else
        // TODO: @[name of cer files] in bundle
#if defined(PRODUCT)
        NSArray *cerFiles = @[];
#elif defined(STAGE)
        NSArray *cerFiles = @[];
#else
        NSArray *cerFiles = @[];
#endif
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate cerFiles:cerFiles];
#endif
        // monitor network reachability status
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        __block AFNetworkReachabilityStatus statusPrevious = AFNetworkReachabilityStatusUnknown;
        __weak typeof(self) weakSelf = self;
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (status != statusPrevious) {
                statusPrevious = status;
                if ([strongSelf.networkReachableDelegate respondsToSelector:@selector(networkAccess:toggledToReachable:)]) {
                    // update network status
                    [strongSelf.networkReachableDelegate networkAccess:strongSelf toggledToReachable:[AFNetworkReachabilityManager sharedManager].reachable];
                }
            }
            
        }];
        [self.reachabilityManager startMonitoring];
    }
    
    return self;
}

+ (instancetype)mobileInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    return  instance = [self instanceWithOnceToken:&onceToken previousInstance:instance baseUrl:kMobileBaseUrl];
}

+ (instancetype)instanceWithOnceToken:(dispatch_once_t *)tokenRef previousInstance:(id)instance baseUrl:(NSString *)baseUrl
{
    __block MFHTTPSessionManager *sessionManager = instance;
    dispatch_once(tokenRef, ^{
        sessionManager = [[MFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        // TODO: text/html is added
        sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    });
    return sessionManager;
}

- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError * error))failure {
    [super GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}
- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    [super POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request uploadProgress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock completionHandler:(void (^)(NSURLResponse * _Nonnull, id _Nullable, NSError * _Nullable))completionHandler {
    
    // request log
#if defined(DETAILED_NETWORK_LOG)
    NSString *json = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    MFLog(@"Request:[%p], [%@]%@\nRequest Headers: %@\nRequest Body: %@", request, request.HTTPMethod, request.URL, request.allHTTPHeaderFields, [json stringByRemovingPercentEncoding]);
#elif defined(BRIEF_NETWORK_LOG)
    MFLog(@"request:[%p], [%@]%@", request, request.HTTPMethod, request.URL);
#endif
    
    // incrementActivityCount
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    
    // super dataTask...
    return [super dataTaskWithRequest:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:^(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) {
        
        // decrementActivityCount
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        if (!error) {
            // response
#if defined(DETAILED_NETWORK_LOG)
            MFLog(@"request:[%p], response: %@", request, responseObject);
#elif defined(BRIEF_NETWORK_LOG)
            MFLog(@"request:[%p], response:[%d]", request, operation.response.statusCode);
#endif
            // TODO: replace keys: error data msg
            NSInteger errorCode = [MFValidatedObject(responseObject[@"code"]) integerValue];
            id data = MFValidatedObject(responseObject[@"data"]);
            NSString *msg = MFValidatedString(responseObject[@"msg"]);
            if (errorCode == 0) {
                if (completionHandler) {
                    completionHandler(response, responseObject, error);
                }
            } else {
                if (completionHandler) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:MFValidatedString(msg)};
                    if (data != nil) {
                        userInfo = @{NSLocalizedDescriptionKey:MFValidatedString(msg), MFErrorDataKey:data};
                    }
                    NSError *error = [NSError errorWithDomain:MFUserProtocolErrorDomain code:errorCode userInfo:userInfo];
                    completionHandler(response, responseObject, error);
                }
            }
        } else {
            // error
#if defined(DETAILED_NETWORK_LOG)
            MFLog(@"request:[%p], error: %@", request, error);
#elif defined(BRIEF_NETWORK_LOG)
            MFLog(@"request:[%p], error description: %@", request, error.localizedDescription);
#endif
            if (completionHandler) {
                NSError *error = [NSError errorWithDomain:MFUserProtocolErrorDomain code:kNetErrorCode userInfo:nil];
                completionHandler(response, responseObject, error);
            }
            
            if ([self.delegate respondsToSelector:@selector(networkAccess:unreachableForRequest:)]) {
                [self.delegate networkAccess:self unreachableForRequest:request];
            }
            
            [self.operationQueue cancelAllOperations];
            
        }
    }];
}

@end

