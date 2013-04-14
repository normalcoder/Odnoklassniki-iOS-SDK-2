//
//  Created by igor on 16.08.12.
//	Odnoklassniki
//


#import <Foundation/Foundation.h>

typedef enum{
	PARAM_SESSION_EXPIRED = 102
} ErrorCodes;

@protocol OKRequestDelegate;

@interface OKRequest : NSObject{
	id<OKRequestDelegate>	_delegate;
	NSString *				_url;
	NSString *				_httpMethod;
	NSMutableDictionary *	_params;
	NSError *				_error;
	BOOL 					_sessionExpired;
	BOOL					_hasError;
	NSURLConnection*      	_connection;
	NSMutableData*        	_responseText;
}

@property(nonatomic, assign) id<OKRequestDelegate> delegate;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *httpMethod;

@property(nonatomic, retain) NSMutableDictionary *params;
@property(nonatomic, retain) NSError *error;
@property(nonatomic, assign) BOOL sessionExpired;
@property(nonatomic) BOOL hasError;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSMutableData *responseText;


+ (NSString*)serializeURL:(NSString *)baseUrl
				   params:(NSDictionary *)params
			   httpMethod:(NSString *)httpMethod;

+ (NSString*)serializeURL:(NSString *)baseUrl
				   params:(NSDictionary *)params;

+ (OKRequest*)getRequestWithParams:(NSMutableDictionary *) params
						httpMethod:(NSString *) httpMethod
						  delegate:(id<OKRequestDelegate>)delegate
						apiMethod:(NSString *) apiMethod;

- (void)load;
- (NSInteger)checkResponseForErrorCodes:(id)data;

@end

@protocol OKRequestDelegate<NSObject>

@optional

-(void)request:(OKRequest *)request didLoad:(id)result;
-(void)request:(OKRequest *)request didFailWithError:(NSError *)error;

@end