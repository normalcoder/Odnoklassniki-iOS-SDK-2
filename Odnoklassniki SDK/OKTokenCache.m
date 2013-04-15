//
//  Created by igor on 21.08.12.
//	Odnoklassniki
//


#import "OKTokenCache.h"


static NSString *const OKTokenKey = @"ru.odnoklassniki.sdk:TokenKey";

static NSString *const kAccessTokenKey = @"access_token";
NSString *const kRefreshTokenKey = @"refresh_token";
NSString *const kPermissionsKey = @"permissions";

static OKTokenCache *sharedInstance;

@implementation OKTokenCache

+(OKTokenCache *)sharedCache {
	@synchronized(self)
	{
		if(sharedInstance == NULL) {
			sharedInstance = [[OKTokenCache alloc] init];
		}
	}
	return sharedInstance;
}

+(NSString *)kAccessTokenKey {
    return kAccessTokenKey;
}

-(void)cacheTokenInformation:(NSDictionary *)tokenInfo {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:tokenInfo forKey:OKTokenKey];
	[defaults synchronize];
}

-(NSDictionary *)getTokenInformation {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults objectForKey:OKTokenKey];
}

-(void)clearToken {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:OKTokenKey];
	[defaults synchronize];
}

@end