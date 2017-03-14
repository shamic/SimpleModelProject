

#import "MFConstants.h"

// TODO: modify base url
#if defined(DEV)
    NSString * const kMobileBaseUrl = @"http://ip.taobao.com/";
#elif defined(STAGE)
    NSString * const kMobileBaseUrl = @"http://xxx/xxx/";
#elif defined(PRODUCT)
    NSString * const kMobileBaseUrl = @"http://xxx/xxx/";
#endif


NSString * const MFErrorDataKey = @"com.xxx.xxx.NSError.datakey";
NSString * const MFUserProtocolErrorDomain = @"com.shamic.MFHTTPSessionManager.userprotocol";

void MFLog(NSString *format, ...) {
#if !defined(PRODUCT)
    va_list args;
    va_start(args, format);
    va_end(args);
    NSLogv(format, args);
#endif
}

id MFValidatedObject(id Object) {
    if ([Object isKindOfClass:[NSNull class]])
        return nil;
    
    return Object;
}

NSString *MFValidatedString(NSString *string) {
    if ([string isKindOfClass:[NSString class]])
        return string;
    else if ([string isKindOfClass:[NSNumber class]])
        return [(NSNumber *)string stringValue];
    else
        return @"";
}

NSArray *MFValidatedArray(NSArray *array) {
    if ([array isKindOfClass:[NSArray class]])
        return array;
    
    return nil;
}

NSArray *MFValidatedArrayNotNil(NSArray *array) {
    if ([array isKindOfClass:[NSArray class]])
        return array;
    
    return [[NSArray alloc] init];
}

NSDictionary *MFValidatedDictionary(NSDictionary *dictionary) {
    if ([dictionary isKindOfClass:[NSDictionary class]])
        return dictionary;
    
    return nil;
}

NSDictionary *MFValidatedDictionaryNotNil(NSDictionary *dictionary) {
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]])
        return dictionary;
    
    return [[NSDictionary alloc] init];
}

NSString *MFValidatedCellDetailTextNotZero(NSString *string) {
    if (string.length == 0 || !string) {
        return @" ";
    }
    return string;
}

