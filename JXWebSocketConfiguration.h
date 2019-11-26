//
//  JXWebSocketConfiguration.h
//  JXLogger
//
//  Created by laoluoro on 2019/8/21.
//

#import <Foundation/Foundation.h>

#import <JXReqEncryptDecrypt/JXReqEncryptDecrypt.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXWebSocketConfiguration : NSObject

@property (nonatomic, copy) NSDictionary *publicParameters;
@property (nonatomic, copy) NSString *socketUrl;

@property (nonatomic, assign) JXCryptAlgorithm encryptType;
@property (nonatomic, copy) NSString *encryptKey;
@property (nonatomic, copy) NSString *encryptIv;

@property (nonatomic, assign) JXCryptAlgorithm decryptType;
@property (nonatomic, copy) NSString *decryptKey;
@property (nonatomic, copy) NSString *decryptIv;

@property (nonatomic, copy) NSString *uid;

@end

NS_ASSUME_NONNULL_END

