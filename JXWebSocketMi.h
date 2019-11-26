//
//  JXWebSocketMi.h
//  JXWebSocket
//
//  Created by laoluoro on 2018/10/8.
//  Edited by laoluoro on 2019/8/20.
//

#import <Foundation/Foundation.h>

#import "SocketRocket.h"
#import "JXWebSocketConfiguration.h"
#import "JXWebSocketClient.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  发送消息请求回调
 */
typedef void(^JXSendMessageHandler)(NSInteger sockErrCode, id _Nullable message);
/**
 *  断开原因
 */
typedef NS_ENUM(NSInteger, JXIMConnectCloseReason) {
    /**
     *  心跳包超时
     */
    JX_HeartBeat_TimeOut   = 408,
    /**
     *  手动关闭
     */
    JX_Self_Close    = 410,
    /*
     *其他原因
     */
    JX_Other = 409
};

@interface JXWebSocketMi : NSObject

/**
 *  socket断线原因
 */
@property (nonatomic, assign) JXIMConnectCloseReason closeReason;
/**
 *  socket对象
 */
@property (nonatomic, strong) SRWebSocket * _Nullable socketClient;
/**
 *  是否销毁
 */
@property (nonatomic, assign) BOOL isDestroy;
/**
 配置信息
 */
@property (nonatomic, strong) JXWebSocketConfiguration *configuration;


@property (nonatomic, weak) id<JXWebSocketClient> client;

/**
 *  发送请求
 */
- (void)send:(NSString *_Nullable)route content:(NSDictionary *)content completion:(nullable JXSendMessageHandler)completion;

/**
 *  ondisconnet
 */
- (void)ondisconnet;

/**
 *  socket connect
 */
- (void)openScoket;

@end

NS_ASSUME_NONNULL_END
