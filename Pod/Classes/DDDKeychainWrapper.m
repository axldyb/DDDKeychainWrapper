//
//  DDDKeychainWrapper.m
//  Aksel Dybdal
//
//  Created by Aksel Dybdal on 02.04.14.
//  Copyright (c) 2014 Aksel Dybdal. All rights reserved.
//

#import "DDDKeychainWrapper.h"
#import <Security/Security.h>

typedef NS_ENUM(NSUInteger, DDDKeychainWrapperErrorCode) {
    DDDKeychainWrapperErrorCreatingKeychainValue = 1,
    DDDKeychainWrapperErrorUpdatingKeychainValue,
    DDDKeychainWrapperErrorDeletingKeychainValue,
    DDDKeychainWrapperErrorSearchingKeychainValue
};

NSString *const kDDDKeychainWrapperServiceName = @"com.dddkeychainwrapper.keychainService";
NSString *const kDDDKeychainWrapperErrorDomain = @"DDDKeychainWrapperErrorDomain";

#ifdef DEBUG
#    warning "Including NSLog"
#    define DDDLOG(s, ...)  NSLog(s, ## __VA_ARGS__)
#else
#    define DDDLOG(s, ...)  while(0){}
#endif

@implementation DDDKeychainWrapper


#pragma mark - String

+ (void)setString:(NSString *)string forKey:(NSString *)key
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self setData:stringData forIdentifier:key];
}

+ (NSString *)stringForKey:(NSString *)key
{
    NSData *stringData = [self dataForIdentifier:key];
    return [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
}


#pragma mark - Date

+ (void)setDate:(NSDate *)date forKey:(NSString *)key
{
    NSData *dateData = [NSKeyedArchiver archivedDataWithRootObject:date];
    [self setData:dateData forIdentifier:key];
}

+ (NSDate *)dateForKey:(NSString *)key
{
    NSData *dateData = [self dataForIdentifier:key];
    return (NSDate *)[NSKeyedUnarchiver unarchiveObjectWithData:dateData];
}


#pragma mark - Data

+ (void)setData:(NSData *)data forKey:(NSString *)key
{
    [self setData:data forIdentifier:key];
}

+ (NSData *)dataForKey:(NSString *)key
{
    return [self dataForIdentifier:key];
}


#pragma mark - Array

+ (void)setArray:(NSArray *)array forKey:(NSString *)key
{
    for (id obj in array) {
        NSAssert([obj conformsToProtocol:@protocol(NSCoding)], @"Objects must confirm to NSCoding protocol in order to be stored in keychain");
    }
    
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:array];
    [self setData:arrayData forIdentifier:key];
}

+ (NSArray *)arrayForKey:(NSString *)key
{
    NSData *arrayData = [self dataForIdentifier:key];
    return (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
}


#pragma mark - Dictionary

+ (void)setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSAssert([key conformsToProtocol:@protocol(NSCoding)], @"Keys must confirm to NSCoding protocol in order to be stored in keychain");
        NSAssert([obj conformsToProtocol:@protocol(NSCoding)], @"Objects must confirm to NSCoding protocol in order to be stored in keychain");
    }];
    
    NSData *dictionaryData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [self setData:dictionaryData forIdentifier:key];
}

+ (NSDictionary *)dictionaryForKey:(NSString *)key
{
    NSData *dictionaryData = [self dataForIdentifier:key];
    return (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
}


#pragma mark - Number

+ (void)setNumber:(NSNumber *)number forKey:(NSString *)key
{
    NSData *numberData = [NSKeyedArchiver archivedDataWithRootObject:number];
    [self setData:numberData forIdentifier:key];
}

+ (NSNumber *)numberForKey:(NSString *)key
{
    NSData *numberData = [self dataForIdentifier:key];
    return (NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:numberData];
}


#pragma mark - BOOL

+ (void)setBoolean:(BOOL)boolean forKey:(NSString *)key
{
    NSNumber *boolNumber = [NSNumber numberWithBool:boolean];
    [self setNumber:boolNumber forKey:key];
}

+ (BOOL)booleanForKey:(NSString *)key
{
    NSNumber *boolNumber = [self numberForKey:key];
    return [boolNumber boolValue];
}


#pragma mark - Object

+ (void)setObject:(id)object forKey:(NSString *)key
{
    NSAssert([object conformsToProtocol:@protocol(NSCoding)], @"Object must confirm to NSCoding protocol in order to be stored in keychain");
    
    NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
    [self setData:objectData forIdentifier:key];
}

+ (id)objectForKey:(NSString *)key
{
    NSData *objectData = [self dataForIdentifier:key];
    return (id)[NSKeyedUnarchiver unarchiveObjectWithData:objectData];
}


#pragma mark - Clear Keychain

+ (void)wipeKeychain
{
    NSArray *secItemClasses = @[(__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecClassInternetPassword,
                                (__bridge id)kSecClassCertificate,
                                (__bridge id)kSecClassKey,
                                (__bridge id)kSecClassIdentity];
    
    for (id secItemClass in secItemClasses) {
        NSDictionary *spec = @{(__bridge id)kSecClass: (id)secItemClass};
        SecItemDelete((__bridge CFDictionaryRef)spec);
    }
}


#pragma mark - Private

+ (void)setData:(NSData *)data forIdentifier:(NSString *)identifier
{
    NSError *error = nil;
    
    // If no data provided we assume we want to delete the value
    if (nil == data || NO == [data bytes]) {
        [self deleteKeychainValueForIdentifier:identifier error:&error];
        if (error) {
            DDDLOG(@"Error deleting keychain value for key: \"%@\" Error: %@", identifier, [error localizedDescription]);
        }
        return;
    }
    
    // We first look up the key in order to see if we need to update or create the value
    if ([self searchKeychainCopyMatching:identifier error:&error]) {
        if (error) {
            DDDLOG(@"Error finding keychain value for key: \"%@\" Error: %@", identifier, [error localizedDescription]);
            return;
        }
        
        if (![self updateKeychainValue:data forIdentifier:identifier error:&error]) {
            DDDLOG(@"Error updating keychain value for key: \"%@\" Error: %@", identifier, [error localizedDescription]);
        }
    } else {
        if (![self createKeychainValue:data forIdentifier:identifier error:&error]) {
            DDDLOG(@"Error creating keychain value for key: \"%@\" Error: %@", identifier, [error localizedDescription]);
        }
    }
}

+ (NSData *)dataForIdentifier:(NSString *)identifier
{
    NSError *error = nil;
    NSData *stringData = [self searchKeychainCopyMatching:identifier error:&error];
    if (error) {
        DDDLOG(@"Error finding keychain value for key: \"%@\" Error: %@", identifier, [error localizedDescription]);
        return nil;
    }
    return stringData;
}

+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
    [searchDictionary setObject:kDDDKeychainWrapperServiceName forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier error:(NSError **)error
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFDataRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, (CFTypeRef *)&result);
    
    if (status != errSecSuccess) {
        [self keychainError:error forStatus:status domain:DDDKeychainWrapperErrorSearchingKeychainValue];
        return nil;
    }
    
    NSData *data = (__bridge NSData *)result;
    return data;
}

+ (BOOL)createKeychainValue:(NSData *)data forIdentifier:(NSString *)identifier error:(NSError **)error
{
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    [dictionary setObject:data forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if (status == errSecSuccess) {
        return YES;
    }
    
    [self keychainError:error forStatus:status domain:DDDKeychainWrapperErrorCreatingKeychainValue];
    return NO;
}

+ (BOOL)updateKeychainValue:(NSData *)data forIdentifier:(NSString *)identifier error:(NSError **)error
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
    
    if (status == errSecSuccess) {
        return YES;
    }
    
    [self keychainError:error forStatus:status domain:DDDKeychainWrapperErrorUpdatingKeychainValue];
    return NO;
}

+ (BOOL)deleteKeychainValueForIdentifier:(NSString *)identifier error:(NSError **)error
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
    
    if (status == errSecSuccess) {
        return YES;
    }
    
    [self keychainError:error forStatus:status domain:DDDKeychainWrapperErrorDeletingKeychainValue];
    return NO;
}

#pragma mark - Error

+ (void)keychainError:(NSError **)error forStatus:(OSStatus)status domain:(NSUInteger)domain
{
    NSString *errorString = @"";
    
    switch (status) {
        case errSecUnimplemented:
            errorString = @"Function or operation not implemented.";
            break;
            
        case errSecIO:
            errorString = @"I/O error (bummers)";
            break;
            
        case errSecOpWr:
            errorString = @"File already open with write permission";
            break;
            
        case errSecParam:
            errorString = @"One or more parameters passed to a function where not valid.";
            break;
            
        case errSecAllocate:
            errorString = @"Failed to allocate memory.";
            break;
            
        case errSecUserCanceled:
            errorString = @"User canceled the operation.";
            break;
            
        case errSecBadReq:
            errorString = @"Bad parameter or invalid state for operation.";
            break;
            
        case errSecInternalComponent:
            errorString = @"errSecInternalComponent";
            break;
            
        case errSecNotAvailable:
            errorString = @"No keychain is available. You may need to restart your computer.";
            break;
            
        case errSecDuplicateItem:
            errorString = @"The specified item already exists in the keychain.";
            break;
            
        case errSecItemNotFound:
            errorString = @"The specified item could not be found in the keychain.";
            break;
            
        case errSecInteractionNotAllowed:
            errorString = @"User interaction is not allowed.";
            break;
            
        case errSecDecode:
            errorString = @"Unable to decode the provided data.";
            break;
            
        case errSecAuthFailed:
            errorString = @"The user name or passphrase you entered is not correct.";
            break;
            
        default:
            errorString = @"Unknown error";
            break;
    }
    
    *error = [NSError errorWithDomain:kDDDKeychainWrapperErrorDomain
                               code:domain
                           userInfo:@{NSLocalizedDescriptionKey: errorString}];
}

@end
