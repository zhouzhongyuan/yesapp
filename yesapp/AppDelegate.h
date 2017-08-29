//
//  AppDelegate.h
//  yesapp
//
//  Created by wangyh on 2016/12/14.
//  Copyright © 2016年 wangyh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <YesAPI/YesAPI.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate,IAppDelegate>

@property (strong, nonatomic) UIWindow *window;
///接收分享文件后的上传文件回调
@property (nonatomic,copy) Block_Upload uploadAction;
//接收支付返回的结果
@property (nonatomic,copy) DealPayResult dealPayResult;
@end

