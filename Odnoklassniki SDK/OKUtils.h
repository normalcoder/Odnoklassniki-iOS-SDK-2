//
//  Created by igor on 20.08.12.
//	Odnoklassniki
//


#import <Foundation/Foundation.h>

NSString* md5(NSString* str);

@interface OKUtils : NSObject

+ (NSDictionary*)dictionaryByParsingURLQueryPart:(NSString *)encodedString;
+ (NSString*)stringByURLDecodingString:(NSString*)escapedString;
+ (NSString*)stringByURLEncodingString:(NSString*)unescapedString;

@end