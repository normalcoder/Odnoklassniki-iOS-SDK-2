//
//  Created by igor on 14.08.12.
//	Odnoklassniki
//


#import <Foundation/Foundation.h>
#import "OKSession.h"

@interface Odnoklassniki : NSObject<OKSessionDelegate>{
	id<OKSessionDelegate>_delegate;

	NSString *_appId;
	NSString *_appSecret;
	NSString *_appKey;
	OKSession *_session;
}
@property(nonatomic, copy) NSString *appId;
@property(nonatomic, retain) OKSession *session;
@property(nonatomic, assign) id <OKSessionDelegate> delegate;
@property(nonatomic, copy) NSString *appSecret;
@property(nonatomic, copy) NSString *appKey;

- (id)initWithAppId:(NSString *)anAppId
	   andAppSecret:(NSString *)anAppSecret
		  andAppKey:(NSString *)anAppKey
		andDelegate:(id<OKSessionDelegate>)aDelegate;

- (void)authorize:(NSArray *)permissions;
- (void)refreshToken;
- (void)logout;
- (BOOL)isSessionValid;

+ (OKRequest*)requestWithMethodName:(NSString *)methodName
						  andParams:(NSMutableDictionary *)params
					  andHttpMethod:(NSString *)httpMethod
						andDelegate:(id <OKRequestDelegate>)delegate;

@end