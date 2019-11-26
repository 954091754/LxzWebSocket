//
//  JXWebSocketCore.h
//  JXWebSocket
//
//  Created by laoluoro on 2018/10/8.
//  Edited by laoluoro on 2019/8/20.
//

#import <Foundation/Foundation.h>

#import "JXWebSocketConfiguration.h"
#import "JXWebSocketClient.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WebSocketError) {
    WebSocketError_NoError                      = 0,    ///< 成功
    WebSocketError_NeedLogin                    = 10002, ///< 需要登录
    WebSocketError_SystemError                  = 10003, ///< 系统错误
    WebSocketError_TokenExpire                  = 10004, ///< Token过期
    WebSocketError_GetUserInfoError             = 100101, ///< 获取用户信息失败
    WebSocketError_RoomNotFound                 = 10021, ///< 进入房间失败 找不到房间信息or房间关闭
    WebSocketError_CashFailure                  = 10027, ///< 远程扣费接口调用失败
    WebSocketError_RoomClosed                   = 10029, ///< 房间已经关闭
    WebSocketError_BekickOff                    = 10037, ///< 被挤掉线 默认通知内容
    WebSocketError_NotAuthorized                = 10039, ///< 不能操作 不是对应的userid
    WebSocketError_RoomNotExit                  = 16104, ///< 直播间不存在
    WebSocketError_RoomBeClosed                 = 16106, ///< 直播间已关闭
    WebSocketError_RoomOwnerError               = 16108, ///< 主播id与直播场次的主播id不合
    WebSocketError_CloseRoomError               = 16110, ///< 关闭直播场次,数据表操作出错
    WebSocketError_CantCloseRoom                = 16122, ///< 主播立即关闭私密直播间, 不满足关闭条件
};

@interface JXWebSocketCore: NSObject

@property (nonatomic, strong) JXWebSocketConfiguration *configuration;
@property (nonatomic, weak) id<JXWebSocketClient> client;

+ (instancetype)sharedInstance;

- (void)connect;

- (void)disConnect;

/**
 *  发送请求
 */
- (void)send:(NSString *_Nullable)route
     content:(NSDictionary *_Nonnull)content
     success:(void(^_Nullable)(id _Nullable data))success
     failure:(void(^_Nullable)(NSInteger code, NSString * _Nullable errmsg))failure;

@end

NS_ASSUME_NONNULL_END

