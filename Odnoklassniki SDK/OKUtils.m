//
//  Created by igor on 20.08.12.
//	Odnoklassniki
//


#import "OKUtils.h"
#import <CommonCrypto/CommonDigest.h>

NSString* md5(NSString* str) {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];

	CC_MD5( cStr, strlen(cStr), result );

	return [[NSString
			stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
							 result[0],  result[1],
							 result[2],  result[3],
							 result[4],  result[5],
							 result[6],  result[7],
							 result[8],  result[9],
							 result[10], result[11],
							 result[12], result[13],
							 result[14], result[15]
	] lowercaseString];
}

@implementation OKUtils

+ (NSDictionary*)dictionaryByParsingURLQueryPart:(NSString *)encodedString {

	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	NSArray *parts = [encodedString componentsSeparatedByString:@"&"];

	for (NSString *part in parts) {
		if ([part length] == 0) {
			continue;
		}

		NSRange index = [part rangeOfString:@"="];
		NSString *key;
		NSString *value;

		if (index.location == NSNotFound) {
			key = part;
			value = @"";
		} else {
			key = [part substringToIndex:index.location];
			value = [part substringFromIndex:index.location + index.length];
		}

		if (key && value) {
			[result setObject:[OKUtils stringByURLDecodingString:value]
					forKey:[OKUtils stringByURLDecodingString:key]];
		}
	}
	return result;
}

// the reverse of url encoding
+ (NSString*)stringByURLDecodingString:(NSString*)escapedString {
	return [[escapedString stringByReplacingOccurrencesOfString:@"+" withString:@" "]
			stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*)stringByURLEncodingString:(NSString*)unescapedString {
	NSString* result = (NSString *)CFURLCreateStringByAddingPercentEscapes(
			kCFAllocatorDefault,
			(CFStringRef)unescapedString,
			NULL, // characters to leave unescaped
			(CFStringRef)@":!*();@/&?#[]+$,='%’\"",
			kCFStringEncodingUTF8);
	[result autorelease];
	return result;
}

@end