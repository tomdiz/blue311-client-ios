//
//  B311Data.m
//  blue311
//
//  Created by Thomas DiZoglio on 03/30/15.
//  Copyright (c) 2015 Thomas DiZoglio. All rights reserved.
//

#import "B311Data.h"
#include "TargetConditionals.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CommonCrypto/CommonDigest.h>

@implementation B311Data

// START CONSTANT METHODS

+ (NSString *) kapi_domain {
    
#if TARGET_IPHONE_SIMULATOR
    return @"localhost:8080";
    //return @"dev01-api.blue311.com";
#else
    return @"10.0.2.11:8080";
    //return @"dev01-api.blue311.com";
#endif
}

+ (NSString *) kapi_protocol {

#if TARGET_IPHONE_SIMULATOR
    return @"http";
#else
    return @"http";
    //return @"https";
#endif
}

+ (NSString *) kAPIVersion {
    
    return @"/v1/";
}

// END CONSTANT METHODS

// Networking code

+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url {

    return [self dictionaryWithContentsOfURL:url methodName:@"GET" stringParameters:nil];
}

+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url methodName:(NSString *)method {

    return [self dictionaryWithContentsOfURL:url methodName:method stringParameters:nil];
}

+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url stringParameters:(NSDictionary *)params {

    return [self dictionaryWithContentsOfURL:url methodName:@"GET" stringParameters:params];
}

+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url methodName:(NSString *)method stringParameters:(NSDictionary *)params {

    NSData *data = [self dataWithContentsOfURL:url methodName:method stringParameters:params];
  
    if (data) {
      
        NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"(1)String returned from server = %@",strData);

        NSError *error = nil;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
        if (error != nil) {
            
            NSLog(@"error parsing JSON = %@", error.description);
        }
        return results;
        //return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
    } else {

        return [NSDictionary dictionary];
    }
}

+ (NSDictionary *)dictionaryWithContentsOfURL:(NSURL *)url methodName:(NSString *)method stringParameters:(NSDictionary *)params usingUserAuth:(BOOL)bUserAuth {
    
    NSData *data = [self dataWithContentsOfURL:url methodName:method stringParameters:params usingUserAuth:bUserAuth];
    
    if (data) {
        
        NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"(2)String returned from server = %@",strData);
        
        NSError *error = nil;
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&error];
        if (error != nil) {
            
            NSLog(@"error parsing JSON = %@", error.description);
        }
        return results;
        //return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:nil];
    } else {
        
        return [NSDictionary dictionary];
    }
}

+ (NSData *)dataWithContentsOfURL:(NSURL *)url methodName:(NSString *)method stringParameters:(NSDictionary *)params {

    return [self dataWithRequest:[NSURLRequest requestWithURL:url]  methodName:method stringParameters:params];
}

+ (NSData *)dataWithContentsOfURL:(NSURL *)url methodName:(NSString *)method stringParameters:(NSDictionary *)params usingUserAuth:(BOOL)bUserAuth {
    
    return [self dataWithRequest:[NSURLRequest requestWithURL:url]  methodName:method stringParameters:params usingUserAuth:bUserAuth];
}

// Fetches data with a fall-off-based retry interval
+ (NSData *)dataWithRequest:(NSURLRequest *)request methodName:(NSString *)method stringParameters:(NSDictionary *)params {
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    int  retryAttempt = 0;
    NSTimeInterval timeout = kPSDataInitialTimeout;
    NSData *data = nil;

    [mutableRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [mutableRequest setHTTPMethod:method];
    [mutableRequest setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (params != nil) {
        
        //NSLog(@"Params: %@", params);

        NSString *bodyData;

        if ([method isEqual: @"GET"]) {

            for (NSString *param_key in params) {
                
                if (bodyData == nil) {
                    
                    bodyData = [NSString stringWithFormat:@"%@=%@", param_key, [params objectForKey:param_key]];
                } else {
                    
                    bodyData = [NSString stringWithFormat:@"%@&%@=%@", bodyData, param_key, [params objectForKey:param_key]];
                }
            }

            //If it's jsut a GET method, simply add the parameters to the end of the URL string.
            NSString *original_url = [[mutableRequest URL] absoluteString];
            NSString *url_string = [NSString stringWithFormat:@"%@?%@", original_url, bodyData];
            NSURL *url =  [NSURL URLWithString:[url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            NSLog(@"URL: %@", url_string);
            [mutableRequest setURL:url];
        } else {
            
            for (NSString *param_key in params) {
                
                if (bodyData == nil) {
                    
                    bodyData = [NSString stringWithFormat:@"{ \"%@\":\"%@\"", param_key, [params objectForKey:param_key]];
                } else {
                    
                    // If there is a dictionary ([params objectForKey:param_key]) -> I need to make a string like this
                    // If a NSString do what is here now.
                    
                    if ([[params objectForKey:param_key] isKindOfClass:[NSString class]] || [[params objectForKey:param_key] isKindOfClass:[NSNumber class]]) {
                        
                        bodyData = [NSString stringWithFormat:@"%@, \"%@\":\"%@\"", bodyData, param_key, [params objectForKey:param_key]];
                    }
                    else {
                        
                        bodyData = [NSString stringWithFormat:@"%@, \"%@\": { ", bodyData, param_key];

                        NSDictionary *subParams = [params objectForKey:param_key];
                        BOOL bFirstTime = YES;
                        for (NSString *param_key in subParams) {
                            
                            if (bFirstTime == YES) {
                                
                                bodyData = [NSString stringWithFormat:@"%@ \"%@\":\"%@\"", bodyData, param_key, [subParams objectForKey:param_key]];
                                bFirstTime = NO;
                            }
                            else {
                                
                                if ([[subParams objectForKey:param_key] isKindOfClass:[NSString class]] || [[subParams objectForKey:param_key] isKindOfClass:[NSNumber class]]) {
                                    
                                    bodyData = [NSString stringWithFormat:@"%@, \"%@\":\"%@\"", bodyData, param_key, [subParams objectForKey:param_key]];
                                }
                                else {
                                    
                                    bodyData = [NSString stringWithFormat:@"%@, \"%@\": { ", bodyData, param_key];
                                    
                                    NSDictionary *subParams2 = [subParams objectForKey:param_key];
                                    BOOL bFirstTime = YES;
                                    for (NSString *param_key in subParams2) {
                                        
                                        if (bFirstTime == YES) {
                                            
                                            bodyData = [NSString stringWithFormat:@"%@ \"%@\":\"%@\"", bodyData, param_key, [subParams2 objectForKey:param_key]];
                                            bFirstTime = NO;
                                        }
                                        else {
                                            
                                            bodyData = [NSString stringWithFormat:@"%@, \"%@\":\"%@\"", bodyData, param_key, [subParams2 objectForKey:param_key]];
                                        }
                                    }
                                    
                                    bodyData = [NSString stringWithFormat:@"%@ }", bodyData];
                                }
                            }
                        }

                        bodyData = [NSString stringWithFormat:@"%@ }", bodyData];
                    }
                }
            }
            bodyData = [NSString stringWithFormat:@"%@ }", bodyData];

            bodyData = [bodyData stringByReplacingOccurrencesOfString:@"\n" withString:@""];

            NSLog(@"bodyData = %@", bodyData);

            // Designate the request a POST request and specify its body data
            [mutableRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:[bodyData length]]];
        }
    }
  
  
    while (data == nil) {

        [mutableRequest setTimeoutInterval:timeout];
        NSLog(@":Mutable Request: %@", mutableRequest);
        
        NSError *error = nil;
        NSURLResponse *response;
        
        data = [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&response error:&error];

        if (error != nil) {
        
            NSLog(@"sync network error = %@", error.description);
        }
        
        NSHTTPURLResponse *httpResponse;

        httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]);

        if (!data) {
            
            retryAttempt++;
            timeout += kPSDataTimeoutIncrease;

            if (retryAttempt == kPSDataMaxRetries) {
                
                NSLog(@"Error processing request: %@", error);

                @throw [NSException exceptionWithName:@"PSDataTimeoutException"
                                   reason:[NSString stringWithFormat:@"Data could not be fetched from URL (%@) within %d attempts.", [request.URL absoluteString], kPSDataMaxRetries]
                                 userInfo:nil];
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:@"PSData/RetryAttempt" object:[NSNumber numberWithInt:retryAttempt]];
        }
    }
  
  return data;
}

// Fetches data with a fall-off-based retry interval
+ (NSData *)dataWithRequest:(NSURLRequest *)request methodName:(NSString *)method stringParameters:(NSDictionary *)params usingUserAuth:(BOOL)bUserAuth {
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    int  retryAttempt = 0;
    NSTimeInterval timeout = kPSDataInitialTimeout;
    NSData *data = nil;
    
    [mutableRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [mutableRequest setHTTPMethod:method];
    [mutableRequest setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    if (params != nil) {
        
        //NSLog(@"Params: %@", params);
        
        NSString *bodyData;
        
        if ([method isEqual: @"GET"]) {
            
            for (NSString *param_key in params) {
                
                if (bodyData == nil) {
                    
                    bodyData = [NSString stringWithFormat:@"%@=%@", param_key, [params objectForKey:param_key]];
                } else {
                    
                    bodyData = [NSString stringWithFormat:@"%@&%@=%@", bodyData, param_key, [params objectForKey:param_key]];
                }
            }
            
            //If it's jsut a GET method, simply add the parameters to the end of the URL string.
            NSString *original_url = [[mutableRequest URL] absoluteString];
            NSString *url_string = [NSString stringWithFormat:@"%@?%@", original_url, bodyData];
            NSURL *url =  [NSURL URLWithString:[url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            NSLog(@"URL: %@", url_string);
            [mutableRequest setURL:url];
        } else {
            
            for (NSString *param_key in params) {
                
                if (bodyData == nil) {
                    
                    bodyData = [NSString stringWithFormat:@"{ \"%@\":\"%@\"", param_key, [params objectForKey:param_key]];
                } else {
                    
                    bodyData = [NSString stringWithFormat:@"%@, \"%@\":\"%@\"", bodyData, param_key, [params objectForKey:param_key]];
                }
            }
            bodyData = [NSString stringWithFormat:@"%@ }", bodyData];
            
            NSLog(@"bodyData = %@", bodyData);
            
            // Designate the request a POST request and specify its body data
            [mutableRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:[bodyData length]]];
        }
    }
    
    
    while (data == nil) {
        
        [mutableRequest setTimeoutInterval:timeout];
        NSLog(@":Mutable Request: %@", mutableRequest);
        
        NSError *error = nil;
        NSURLResponse *response;
        
        data = [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&response error:&error];
        
        if (error != nil) {
            
            NSLog(@"sync network error = %@", error.description);
        }
        
        NSHTTPURLResponse *httpResponse;
        
        httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"HTTP Response Headers %@", [httpResponse allHeaderFields]);
        
        if (!data) {
            
            retryAttempt++;
            timeout += kPSDataTimeoutIncrease;
            
            if (retryAttempt == kPSDataMaxRetries) {
                
                NSLog(@"Error processing request: %@", error);
                
                @throw [NSException exceptionWithName:@"PSDataTimeoutException"
                                               reason:[NSString stringWithFormat:@"Data could not be fetched from URL (%@) within %d attempts.", [request.URL absoluteString], kPSDataMaxRetries]
                                             userInfo:nil];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PSData/RetryAttempt" object:[NSNumber numberWithInt:retryAttempt]];
        }
    }
    
    return data;
}

@end
