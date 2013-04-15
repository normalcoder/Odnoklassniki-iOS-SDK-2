//
//  Created by igor on 17.08.12.
//	Odnoklassniki
//


#import "OKSession.h"
#import "OKUtils.h"
#import "OKTokenCache.h"

NSString* const kLoginURL = @"http://www.odnoklassniki.ru/oauth/authorize";
NSString* const kRedirectURL = @"odnoklassniki://";
NSString* const kAccessTokenURL = @"http://api.odnoklassniki.ru/oauth/token.do";
NSString* const kAPIBaseURL = @"http://api.odnoklassniki.ru/api/";

static NSString *const OKAuthURLScheme = @"okauth";
static NSString *const OKAuthURLPath = @"authorize";

static OKSession *_activeSession = nil;

@interface OKSession()
-(void)didNotLogin:(BOOL)canceled;
-(void)didNotExtendToken:(NSError *)error;
-(void)cacheTokenCahceWithPermissions:(NSDictionary *)tokenInfo;
@end

@implementation OKSession

@synthesize appId = _appId;
@synthesize permissions = _permissions;
@synthesize tokenRequest = _tokenRequest;
@synthesize accessToken = _accessToken;
@synthesize refreshToken = _refreshToken;
@synthesize delegate = _delegate;
@synthesize appSecret = _appSecret;
@synthesize appKey = _appKey;
@synthesize refreshTokenRequest = _refreshTokenRequest;


+ (OKSession *)activeSession {
	if (!_activeSession) {
		OKSession *session = [[OKSession alloc] init];
		[OKSession setActiveSession:session];
		[session release];
	}
	return [[_activeSession retain] autorelease];
}

+ (OKSession *)setActiveSession:(OKSession *)session {
	if (!_activeSession){
		_activeSession = [session retain];
	}else if (session != _activeSession) {
		OKSession *toRelease = _activeSession;
		[toRelease close];
		_activeSession = [session retain];

		if (toRelease) {
			[toRelease release];
		}
	}

	return session;
}

+ (BOOL)openActiveSessionWithPermissions:(NSArray *)permissions appId:(NSString *)appID appSecret:(NSString*)secret{
	BOOL result = NO;
	OKSession *session = [[[OKSession alloc] initWithAppID:appID permissions:permissions appSecret:secret] autorelease];
	if (session.accessToken != nil) {
		[self setActiveSession:session];
		result = YES;
	}
	return result;
}

- (void)contunueLoginWithCode:(NSString *)code {
    NSMutableDictionary *newParams = [NSMutableDictionary dictionary];
    [newParams setValue:code forKey:@"code"];
    [newParams setValue:[self.permissions componentsJoinedByString:@","] forKey:@"permissions"];
    [newParams setValue:self.getAppBaseUrl forKey:@"redirect_uri"];
    [newParams setValue:@"authorization_code" forKey:@"grant_type"];
    [newParams setValue:self.appId forKey:@"client_id"];
    [newParams setValue:self.appSecret forKey:@"client_secret"];
    
    self.tokenRequest = [[[OKRequest alloc] init] autorelease];
    _tokenRequest.url = [OKRequest serializeURL:kAccessTokenURL params:newParams httpMethod:@"POST"];
    _tokenRequest.delegate = self;
    _tokenRequest.params = newParams;
    _tokenRequest.httpMethod = @"POST";
    [self.tokenRequest load];
}

- (BOOL)handleOpenURL:(NSURL *)url {
	if (![[url absoluteString] hasPrefix:self.getAppBaseUrl]) {
		return NO;
	}

	NSString *query = [url query];
	NSDictionary *params = [OKUtils dictionaryByParsingURLQueryPart:query];
	if([params valueForKey:@"error"] != nil){
		if ([[params valueForKey:@"error"] isEqualToString:@"access_denied"]){
			[self didNotLogin:YES];
		}else if (_delegate && [_delegate respondsToSelector:@selector(okDidNotLoginWithError:)])
			[_delegate okDidNotLoginWithError:[NSError errorWithDomain:@"Odnoklassniki.ru" code:511 userInfo:params]];
		return YES;
	}

	NSString *code = [params objectForKey:@"code"];

    if ([_delegate respondsToSelector:@selector(okShouldContinueLoginWithCode:)]) {
        if ([_delegate okShouldContinueLoginWithCode:code]) {
            [self contunueLoginWithCode:code];
        } else {
            
        }
    } else {
        [self contunueLoginWithCode:code];
    }
    
    return YES;
}

- (void)close {
	[[OKTokenCache sharedCache] clearToken];
}

- (id)initWithAppID:(NSString *)appID permissions:(NSArray *)permissions appSecret:(NSString*)secret {
	self = [super init];
	if (self){
		self.appId = appID;
		self.permissions = permissions;
		self.appSecret = secret;

		//[[OKTokenCache sharedCache] clearToken];

		NSDictionary *cachedToken = [[OKTokenCache sharedCache] getTokenInformation];
		if(cachedToken){
			self.accessToken = [cachedToken valueForKey:[OKTokenCache kAccessTokenKey]];
			self.refreshToken = [NSString stringWithFormat:@"%@", [cachedToken valueForKey:kRefreshTokenKey]];
			NSArray *aPermissions = [cachedToken valueForKey:kPermissionsKey];

			if (_permissions == nil) self.permissions = aPermissions;

			if (![self.permissions isEqualToArray:aPermissions]){
				self.accessToken = nil;
				self.refreshToken = nil;
			}
		}
	}
    return self;
}

- (void)authorizeWithOKAppAuth:(BOOL)tryOKAppAuth
					safariAuth:(BOOL)trySafariAuth {

	if(_accessToken){
		if (_delegate && [_delegate respondsToSelector:@selector(okDidLogin)])
			[_delegate okDidLogin];
		return;
	}

	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			_appId, @"client_id",
			[self getAppBaseUrl], @"redirect_uri",
			@"code", @"response_type",
			nil];

	NSString *loginURL = kLoginURL;

	if (_permissions){
		NSString *scope = [_permissions componentsJoinedByString:@";"];
		[params setValue:scope forKey:@"scope"];
	}

	BOOL didAuthNWithOKApp = NO;

	if (tryOKAppAuth){
		NSString *urlPrefix = [NSString stringWithFormat:@"%@://%@", OKAuthURLScheme, OKAuthURLPath];
		NSString *okAppUrl = [OKRequest serializeURL:urlPrefix params:params];
		didAuthNWithOKApp = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:okAppUrl]];
	}
	if (trySafariAuth && !didAuthNWithOKApp) {
        [params setValue:@"m" forKey:@"layout"];
		NSString *okAppUrl = [OKRequest serializeURL:loginURL params:params];
		NSLog(@"OK app url = %@", okAppUrl);
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:okAppUrl]];
	}
}

- (NSString *)getAppBaseUrl {
	return [NSString stringWithFormat:@"ok%@%@://authorize",
									  _appId,
									  @""];
}

-(void)refreshAuthToken {
	NSMutableDictionary *newParams = [NSMutableDictionary dictionary];
	[newParams setValue:self.refreshToken forKey:@"refresh_token"];
	[newParams setValue:@"refresh_token" forKey:@"grant_type"];
	[newParams setValue:self.appId forKey:@"client_id"];
	[newParams setValue:self.appSecret forKey:@"client_secret"];

	self.refreshTokenRequest = [[[OKRequest alloc] init] autorelease];
	_refreshTokenRequest.url = [OKRequest serializeURL:kAccessTokenURL params:newParams httpMethod:@"POST"];
	_refreshTokenRequest.delegate = self;
	_refreshTokenRequest.params = newParams;
	_refreshTokenRequest.httpMethod = @"POST";
	[self.refreshTokenRequest load];
}

-(void)cacheTokenCahceWithPermissions:(NSDictionary *)tokenInfo {
	NSMutableDictionary *dct = [NSMutableDictionary dictionaryWithDictionary:tokenInfo];
	[dct setValue:self.permissions forKey:kPermissionsKey];
	[[OKTokenCache sharedCache] cacheTokenInformation:dct];
}

-(void)didNotLogin:(BOOL)canceled {
	if (_delegate && [_delegate respondsToSelector:@selector(okDidNotLogin:)])
		[_delegate okDidNotLogin:canceled];
}

-(void)didNotExtendToken:(NSError *)error {
	if(_delegate && [_delegate respondsToSelector:@selector(okDidNotExtendToken:)])
		[_delegate okDidNotExtendToken:error];
}

/*** OKAPIRequest delegate only for authorization ***/
-(void)request:(OKRequest *)request didLoad:(id)result {
	if (request == self.tokenRequest){
		if (request.hasError){
			[self didNotLogin:NO];
			return;
		}
		[self cacheTokenCahceWithPermissions:result];
		self.accessToken = [(NSDictionary *)result valueForKey:[OKTokenCache kAccessTokenKey]];
		self.refreshToken = [(NSDictionary *)result valueForKey:kRefreshTokenKey];

		if (_delegate && [_delegate respondsToSelector:@selector(okDidLogin)])
			[_delegate okDidLogin];

	}else if(request == self.refreshTokenRequest){
		if (self.refreshTokenRequest.hasError){
			[self didNotExtendToken:nil];
			return;
		}

		NSMutableDictionary *dct = [NSMutableDictionary dictionaryWithDictionary:[[OKTokenCache sharedCache] getTokenInformation]];
		self.accessToken = [(NSDictionary *)result valueForKey:[OKTokenCache kAccessTokenKey]];
		[dct setValue:self.accessToken forKey:[OKTokenCache kAccessTokenKey]];
		[self cacheTokenCahceWithPermissions:dct];
		if (_delegate && [_delegate respondsToSelector:@selector(okDidExtendToken:)])
			[_delegate okDidExtendToken:self.accessToken];
	}
}

-(void)request:(OKRequest *)request didFailWithError:(NSError *)error {
	if (request == self.tokenRequest){
		if (request.sessionExpired){
			[self refreshAuthToken];
		}else
			[self didNotLogin:NO];
	} else if(request == self.refreshTokenRequest){
		[self didNotExtendToken:error];
	}
}

- (void)dealloc {
	[_appId release];
	[_permissions release];
	_tokenRequest.delegate = nil;
	_refreshTokenRequest.delegate = nil;
	[_accessToken release];
	[_refreshToken release];
	[_appSecret release];
	[_appKey release];
	[_tokenRequest release];
	[_refreshTokenRequest release];
	[super dealloc];
}


@end