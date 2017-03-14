
#import <Foundation/Foundation.h>

#define DEV

typedef NS_ENUM(NSUInteger, MFTabIndex)
{
    MFTabHome,
    MFTabAccount
};

#define kTimeZoneGMT8 [NSTimeZone timeZoneWithName:@"Asia/Shanghai"]

#define kScreenWidth    ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight   ([UIScreen mainScreen].bounds.size.height)
#define kIphone5ScreenWidth    320
#define kIphone6PlusScreenWidth    414

#define Color(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

extern NSString * const kMobileBaseUrl;

extern NSString * const MFErrorDataKey;
extern NSString * const MFUserProtocolErrorDomain;

extern void MFLog(NSString *format, ...);

extern id MFValidatedObject(id Object);
extern NSString *MFValidatedString(NSString *string);
extern NSArray *MFValidatedArray(NSArray *array);
extern NSArray *MFValidatedArrayNotNil(NSArray *array);
extern NSDictionary *MFValidatedDictionaryNotNil(NSDictionary *dictionary);
extern NSDictionary *MFValidatedDictionary(NSDictionary *dictionary);


