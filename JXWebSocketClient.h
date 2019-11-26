//
//  JXWebSocketClient.h
//  JXWebSocket
//
//  Created by laoluoro on 2019/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JXWebSocketClient <NSObject>

@optional
/**
 *  断线及其原因
 */
- (void)onDisconnect:(NSInteger)code reason:(NSString *_Nullable)reason;

/**
 *  收到数据
 */
- (void)onReceiveMessage:(id)msg;

/**
 *  error
 */
- (void)onError:(NSString *)msg;

/**
 *  连接成功
 */
- (void)onConnectSuccess;

/**
 *  socket登录成功
 */
- (void)onSocLoginSuccess;

/**
 *  socket登录失败
 */
- (void)onSocLoginFail;

/**
 *  创建新的socket
 */
- (void)createNewConnectSocket;

@end

NS_ASSUME_NONNULL_END
