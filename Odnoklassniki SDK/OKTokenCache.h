//
//  Created by igor on 21.08.12.
//	Odnoklassniki
//


#import <Foundation/Foundation.h>

extern NSString *const kRefreshTokenKey;
extern NSString *const kPermissionsKey;

@interface OKTokenCache : NSObject

+(OKTokenCache *)sharedCache;

+(NSString *)kAccessTokenKey;

-(void)cacheTokenInformation:(NSDictionary *)tokenInfo;
-(NSDictionary*)getTokenInformation;
-(void)clearToken;

@end