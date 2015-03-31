//
//  B311Data.h
//  blue311
//
//  Created by Thomas DiZoglio on 03/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPSDataInitialTimeout  60
#define kPSDataTimeoutIncrease 20
#define kPSDataMaxRetries      5

@interface B311Data : NSObject <NSURLConnectionDelegate>

+ (NSString *) kapi_domain;
+ (NSString *) kapi_protocol;
+ (NSString *) kAPIVersion;

+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url;
+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url methodName:(NSString *)method;
+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url stringParameters:(NSDictionary *)params;
+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url methodName:(NSString *)method stringParameters:(NSDictionary *)params;
+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url methodName:(NSString *)method stringParameters:(NSDictionary *)params usingUserAuth:(BOOL)bUserAuth;

+ (NSData *)dataWithContentsOfURL:(NSURL *)url methodName:(NSString *)method stringParameters:(NSDictionary *)params;
+ (NSData *)dataWithRequest:(NSURLRequest *)request methodName:(NSString *)method stringParameters:(NSDictionary *)params;

@end
