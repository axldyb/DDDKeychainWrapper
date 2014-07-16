//
//  DDDKeychainWrapper.h
//  Aksel Dybdal
//
//  Created by Aksel Dybdal on 02.04.14.
//  Copyright (c) 2014 Aksel Dybdal. All rights reserved.
//

/**
 A small wrapper for Keychain access.
 
 Inspired by:
 http://useyourloaf.com/blog/2010/03/29/simple-iphone-keychain-access.html
 */

#import <Foundation/Foundation.h>

@interface DDDKeychainWrapper : NSObject

+ (void)setString:(NSString *)string forKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;

+ (void)setDate:(NSDate *)date forKey:(NSString *)key;
+ (NSDate *)dateForKey:(NSString *)key;

+ (void)setData:(NSData *)data forKey:(NSString *)key;
+ (NSData *)dataForKey:(NSString *)key;

+ (void)setArray:(NSArray *)array forKey:(NSString *)key;
+ (NSArray *)arrayForKey:(NSString *)key;

+ (void)setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;
+ (NSDictionary *)dictionaryForKey:(NSString *)key;

+ (void)setNumber:(NSNumber *)number forKey:(NSString *)key;
+ (NSNumber *)numberForKey:(NSString *)key;

+ (void)setBoolean:(BOOL)boolean forKey:(NSString *)key;
+ (BOOL)booleanForKey:(NSString *)key;

+ (void)setObject:(id)object forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

+ (void)wipeKeychain;

@end