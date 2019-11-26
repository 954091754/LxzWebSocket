//
//  JXWebSocketCore.m
//  JXWebSocket
//
//  Created by laoluoro on 2018/10/8.
//  Edited by laoluoro on 2019/8/20.
//

#import "JXWebSocketCore.h"

#import "JXWebSocketMi.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <YYModel/YYModel.h>
#import <JXLogger/JXLogger.h>

#ifndef JX_STR_AVOID_nil
#define JX_STR_AVOID_nil( _value_ ) (_value_) ? : @""
#endif

@interface JXWebSocketCore()

@property (nonatomic, strong) JXWebSocketMi * _Nullable webSocketMi;

@end

@implementation JXWebSocketCore

+ (instancetype)sharedInstance {
    static JXWebSocketCore *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JXWebSocketCore alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectWhenWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (JXWebSocketMi *)webSocketMi {
    if (!_webSocketMi) {
        _webSocketMi = [[JXWebSocketMi alloc] init];
        _webSocketMi.client = self.client;
        _webSocketMi.configuration = self.configuration;
    }
    return _webSocketMi;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)disConnect {
    self.webSocketMi.closeReason = JX_Self_Close;
    [self.webSocketMi.socketClient close];
    [JXLog logInfo:NSStringFromClass([self class]) withLevel:JXLOGLEVEL_CONSOLEANDFILE logStr:[NSString stringWithFormat:@"uid:%@ code:%ld reason:%@", JX_STR_AVOID_nil(self.configuration.uid), (long)self.webSocketMi.closeReason, JX_STR_AVOID_nil(nil)],nil];
}

//- (NSMutableArray *)noDeallocSocketList {
//    if (!_noDeallocSocketList) {
//        _noDeallocSocketList = [NSMutableArray array];
//    }
//    return _noDeallocSocketList;
//}

/**
 *  移除所有未clean的socket对象
 */
- (void)onConnectSuccess {
    [JXLog logInfo:NSStringFromClass([self class]) withLevel:JXLOGLEVEL_CONSOLEANDFILE logStr:JX_STR_AVOID_nil(@"WebSocketConnectSuccess"), [NSString stringWithFormat:@"uid:%@ code:%ld reason:%@", JX_STR_AVOID_nil(self.configuration.uid), (long)0, JX_STR_AVOID_nil(nil)],nil];
    //    [HDIMRequestManager autoLoginWithSuccess:^{
    //        NSLog(@"自动登录成功");
    //        NotifyCoreClient(HDWebSocketCoreClient, @selector(onSocLoginSuccess), onSocLoginSuccess);
    //    } failure:^(NSInteger code, NSString * _Nonnull errorMessage) {
    //        NSLog(@"自动登录失败");
    //        NotifyCoreClient(HDWebSocketCoreClient, @selector(onSocLoginFail), onSocLoginFail);
    //        NotifyCoreClient(HDImLoginCoreClient, @selector(onImLoginFailth), onImLoginFailth);
    //    }];
    
    //    if (self.noDeallocSocketList.count == 0) {return;}
    //    for (HDWebSocketMi *mi in self.noDeallocSocketList) {
    //        [mi ondisconnet];
    //    }
    //    [self.noDeallocSocketList removeAllObjects];
}

/**
 *  销毁websocketMi对象
 */
- (void)destroy {
    if (self.webSocketMi) {
        self.webSocketMi.isDestroy = true;
        [self.webSocketMi ondisconnet];
        self.webSocketMi = nil;
    }
}

/**
 *  是否在clean中
 */
//- (BOOL)isInNoCleanList:(HDWebSocketMi *)webSocketMi {
//    if ([self.noDeallocSocketList containsObject:webSocketMi]) {
//        return YES;
//    }
//        return false;
//}

- (void)reOpenSocket {
    return;
}

- (void)onDisconnect:(NSInteger)code reason:(NSString *)reason {
    [JXLog logInfo:NSStringFromClass([self class]) withLevel:JXLOGLEVEL_CONSOLEANDFILE logStr:JX_STR_AVOID_nil(@"WebSocketConnectFailure"), [NSString stringWithFormat:@"uid:%@ code:%ld reason:%@", JX_STR_AVOID_nil(self.configuration.uid), (long)code, JX_STR_AVOID_nil(reason)],nil];
    
    __weak typeof(self) weak_self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(self) self = weak_self;
        if (code == JX_HeartBeat_TimeOut) {
            [self connect];
        } else if (code == JX_Self_Close) {
        } else if (code == JX_Other) {
            [self connect];
        }
    });
}

- (void)connectWhenWillEnterForeground {
    if (self.webSocketMi.closeReason == JX_Self_Close) return;
//    if (!GetCore(HDAuthCore).isLoginSuccess) return;
    
    [self connect];
}

/**
 *  连接
 */
- (void)connect {
    [JXLog logInfo:NSStringFromClass([self class]) withLevel:JXLOGLEVEL_CONSOLEANDFILE logStr:JX_STR_AVOID_nil(@"WebSocketConnectBegin"), [NSString stringWithFormat:@"uid:%@ code:%ld reason:%@", JX_STR_AVOID_nil(self.configuration.uid), (long)0, JX_STR_AVOID_nil(nil)],nil];
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        if ([self.client respondsToSelector:@selector(onDisconnect:reason:)]) {
            [self.client onDisconnect:JX_Other reason:@"连接失败，网络不可用"];
        }
        return;
    }
    
    if (self.webSocketMi.socketClient.readyState == SR_OPEN) {return;}
    
    //    if (![self isInNoCleanList:self.webSocketMi]) {[self destroy];};
    [self destroy];
    [self.webSocketMi openScoket];
}


/**
 *  发送请求
 */
- (void)send:(NSString *_Nullable)route
     content:(NSDictionary *)content
     success:(void(^)(id data))success
     failure:(void(^)(NSInteger code, NSString *errmsg))failure {
    
    [self.webSocketMi send:route content:content completion:^(NSInteger sockErrCode, id  _Nullable message) {
        
        if (sockErrCode == 0) {
            
            NSDictionary *mesDic = nil;
            
            if ([message isKindOfClass:[NSDictionary class]]) {
                mesDic = message;
            }
            else if ([message isKindOfClass:[NSString class]]) {
                
                mesDic = [NSDictionary yy_modelWithJSON:message];
            }
            NSInteger errorCode = [mesDic[@"res_data"][@"errno"] integerValue];
            NSString *errorMessage = [mesDic[@"res_data"][@"errmsg"] description];
            
            switch (errorCode) {
                case WebSocketError_NoError: {
                    // 成功
                    id data = mesDic[@"res_data"][@"data"];
                    if (success) {
                        success(data);
                    }
                    break;
                }
                case WebSocketError_GetUserInfoError: {
                    // 获取用户信息失败
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                    
                case WebSocketError_NeedLogin: {
                    // 需要登录
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_SystemError: {
                    // 系统错误
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_TokenExpire: {
                    // Token过期
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_RoomNotFound: {
                    // 进入房间失败 找不到房间信息or房间关闭
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_CashFailure: {
                    // 远程扣费接口调用失败
                    if (failure) {
                        failure(errorCode,errorMessage);
                    };
                }
                case WebSocketError_RoomClosed: {
                    // 房间已经关闭
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_BekickOff: {
                    // 被挤掉线 默认通知内容
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_NotAuthorized: {
                    // 不能操作 不是对应的userid
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                    
                case WebSocketError_RoomNotExit: {
                    // 直播间不存在
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_RoomBeClosed: {
                    // 直播间已关闭
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_RoomOwnerError: {
                    // 主播id与直播场次的主播id不合
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_CloseRoomError: {
                    // 关闭直播场次,数据表操作出错
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                case WebSocketError_CantCloseRoom: {
                    // 主播立即关闭私密直播间, 不满足关闭条件
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                default:
                {
                    if (failure) {
                        failure(errorCode,errorMessage);
                    }
                    break;
                }
                    break;
            }
        }
        else {
            if (failure) {
                NSString *errorMessage = @"";
                switch (sockErrCode) {
                    case JX_HeartBeat_TimeOut:
                        errorMessage = @"连接超时";
                        break;
                    case JX_Self_Close:
                        errorMessage = @"关闭连接";
                        break;
                    case JX_Other:
                        errorMessage = @"其他原因";
                        break;
                }
                failure(sockErrCode, errorMessage);
            }
        }
    }];
}

@end
