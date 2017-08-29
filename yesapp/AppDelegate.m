//
//  AppDelegate.m
//  yesapp
//
//  Created by wangyh on 2016/12/14.
//  Copyright © 2016年 wangyh. All rights reserved.
//

#import "AppDelegate.h"
#import "AppInitView.h"
#import <YesAPI/YesAPI.h>
#import "AppInitView.h"
#import "BAIDUMapInit.h"
#import <UserNotifications/UserNotifications.h>
#import "BPush.h"

#import <AlipaySDK/AlipaySDK.h>
@interface AppDelegate ()<UNUserNotificationCenterDelegate,ExServiceCenterDelegate>

@end

void UncaughtExceptionHandler(NSException *exception) {
    [MessageBox showWithException:exception];
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /**************** 百度地图 ********************/
    NSString* baiduKey = [AppInfo getBaiduMapApiKey];
    if(baiduKey == nil || baiduKey.length == 0){
//        [MessageBox showWithMessage:[StringTable getStringWithKey:BaiduMapApiKeyNull]];
        NSLog(@"%@",[StringTable getStringWithKey:BaiduMapApiKeyNull]);
    }else{
        [BAIDUMapInit initWithDelegate:self baiduKey:[AppInfo getBaiduMapApiKey]];
    }
    
    /**************** 百度推送 ********************/
    NSString* pushApiKey = [AppInfo getBaiduPushApiKey];
    if(pushApiKey == nil || pushApiKey.length == 0){
        //        [MessageBox showWithMessage:[StringTable getStringWithKey:BaiduPushApiKeyNull]];
        NSLog(@"%@",[StringTable getStringWithKey:BaiduPushApiKeyNull]);
    }else{
        // iOS10 下需要使用新的 API
        if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 10.0) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    [application registerForRemoteNotifications];
                }
            }];
        }
        
        // 在 App 启动时注册百度云推送服务，需要提供 Apikey
        [BPush registerChannel:launchOptions apiKey:[AppInfo getBaiduPushApiKey] pushMode:BPushModeProduction withFirstAction:@"打开" withSecondAction:@"关闭" withCategory:@"test" useBehaviorTextInput:YES isDebug:NO];
        
        // 禁用地理位置推送 需要再绑定接口前调用。
        [BPush disableLbs];
        //角标清0
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        [ExServiceCenter defaultCenter].delegate = self;
    }

    /**************** 平台启动界面 ********************/
    [AppInfo setAppResetBlock:^{
        
        
        self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
//        if([ViewUtil isFirstLauch]){//处理引导页面的添加
//            UserGuideViewController* guideController = [[UserGuideViewController alloc]initWithImages:@[@"G1.png",@"G2.png",@"G3.png",@"G4.png"]];
//            [self.window setRootViewController:guideController];
//            UIButton* enterButton = [guideController getEnterButton];
//            [enterButton setTitle:@"立即体验" forState:UIControlStateNormal];
//            [enterButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//            [enterButton setFrame:CGRectMake(enterButton.frame.origin.x, enterButton.frame.origin.y+40, enterButton.frame.size.width, enterButton.frame.size.height)];
//            enterButton.layer.borderColor = [ColorUtil colorWithHexString:@"#91b8f4"].CGColor;
//            enterButton.layer.masksToBounds = true;
//            enterButton.layer.cornerRadius = 3.0f;
//            [guideController setEnterCallback:^{
//                AppInitView  *appStarter=[[AppInitView alloc]init];
//                [self.window setRootViewController:appStarter];
//            }];
//        }else{
//        }
        AppInitView  *appStarter=[[AppInitView alloc]init];
        [self.window setRootViewController:appStarter];
        [self.window makeKeyAndVisible];
        [AppInfo setRootWindow:self.window];
        
    }];
    
    [AppInfo resetApp];
    
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    return YES;
}

//远程推送需要将deviceToken注册到APNS，并通过BPush绑定
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        // 需要在绑定成功后进行 settag listtag deletetag unbind 操作否则会失败
        // 网络错误
        if (error) {
            return ;
        }
        if (result) {
            // 确认绑定成功
            if ([result[@"error_code"]intValue]!=0) {
                return;
            }
            NSString *channel_id = [BPush getChannelId];
            [AppInfo setPushChannelID:channel_id];
        }
    }];
}
//获取deviceToken失败
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSString *errorString = [error localizedDescription];
    [MessageBox showWithMessage:[NSString stringWithFormat:@"DeviceToken 获取失败，原因:%@",errorString]];
}

#pragma mark - exservicedelegate

-(NSString *)getPushServiceName{
    return @"RegisteDeviceService";
}

-(void)setPushServiceAdditionParaWithDefault:(NSMutableDictionary *)defaultPara{
    [defaultPara setObject:@"driver" forKey:@"tagName"];
    [defaultPara setObject:@"4" forKey:@"deviceType"];
}

#pragma mark - notification center delegate
//App 处于前台接受到的通知
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
}

//App 通知的点击事件
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    
    completionHandler();
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    [[AppFileMd5CheckManager defaultManager]doCheckConfigFileMd5];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //App打开时将badge角标清零
    if (application.applicationIconBadgeNumber > 0) {
        [application setApplicationIconBadgeNumber:0];
    }
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

#pragma mark - 接受文件分享后的回调
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSString *sourceApplication = [options valueForKey:@"UIApplicationOpenURLOptionsSourceApplicationKey"];
    
    NSString *alipayPackageName = @"com.alipay.iphoneclient";
    NSString *wechatPackageName = @"com.tencent.xin";
    if( [sourceApplication isEqualToString:alipayPackageName] ) {
        NSLog(@"alipay callback");
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if(self.dealPayResult){
                self.dealPayResult(resultDic);
            }
        }];
        return YES;
    } else if( [sourceApplication isEqualToString:wechatPackageName] ) {
        NSLog(@"wechat callback");
        return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    } else {
        if (self.window) {
            if (url) {
                NSData *data = [NSData dataWithContentsOfURL:url];
                if (self.uploadAction) {
                    self.uploadAction(data);
                }
            }
        }
        return YES;
    }
    
}

-(void)setAppBlock:(Block_Upload)action{
    _uploadAction = action;
}
-(void)setPayCallback:(DealPayResult)callback
{
    _dealPayResult = callback;
}

@end
