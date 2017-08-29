//
//  AppInitView.m
//  yesapp
//
//  Created by chenzs on 16/8/9.
//  Copyright © 2016年 BokeSoft. All rights reserved.
//

#import "AppInitView.h"
#import <YesAPI/YesAPI.h>

@interface AppInitView () <UITextFieldDelegate>
/** delegate */
@property (nonatomic, strong) DefaultAppDelegate* delegate;
@end

@implementation AppInitView
-(id)init
{
    if(self = [super init]){
        [self initView]; 
    }
    return self;
}

-(void)startApp:(UIButton *)btn
{
//    if (!address.text.length) return;
    [self.view endEditing:YES];
    NSString* url = [[[NSBundle mainBundle]infoDictionary]objectForKey:Key_ServiceURL];
    btn.enabled = NO;
    self.delegate = [[DefaultAppDelegate alloc]init];
    [self.delegate setShowAlert:false];//设置下载时不弹框显示
    self.delegate.refreshBlock = ^(BOOL isEnable) {
        
        btn.enabled = isEnable;
        NSLog(@"");
    };
    [self.delegate setPubilshUpdateInfo:^(float progressValue, NSString *info) {//设置接收下载信息的方法
//        if (!btn.isHidden) {
//            
//            btn.hidden = YES;
//        }
        [progress setProgress:progressValue];
        [progressInfo setText:info];
    }];
    [self.delegate initAppWithURL:url];
//    [self.delegate initAppWithURL:address.text];
//    [AppInfo AppendToHistoryWithKey:@"Address" Content:address.text];
}


-(void)initView{
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    float centerH = screenRect.size.height/2;
    
//    UIImage* bgImage = [ImageUtil loadResourceImageInBundle:@"LoginBack.png"];
    UIImage* bgImage = [UIImage imageNamed:@"login_bg.png"];
    UIImageView* backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    [backImageView setImage:bgImage];
    [self.view addSubview:backImageView];
    
    UIImage* logoImage = [ImageUtil loadResourceImageInBundle:@"Logo.png"];
    UIImageView* logoImageView = [[UIImageView alloc]initWithFrame:CGRectMake((screenRect.size.width-logoImage.size.width)/2, centerH-logoImage.size.height, logoImage.size.width, logoImage.size.height)];
    [logoImageView setImage:logoImage];
//    [self.view addSubview:logoImageView];
    
    progress = [[UIProgressView alloc]initWithFrame:CGRectMake(40, centerH+30, screenRect.size.width-80, 20)];
    [progress setTransform:CGAffineTransformMakeScale(1.0f, 3.0f)];
    [progress setContentMode:UIViewContentModeScaleAspectFill];
    progress.layer.cornerRadius = 2.0f;
    progress.layer.masksToBounds = true;
    [progress setProgressTintColor:[UIColor greenColor]];
    progressInfo = [[UILabel alloc]initWithFrame:CGRectMake(40, centerH+45, screenRect.size.width-80, 30)];
    [self.view addSubview:progress];
    [self.view addSubview:progressInfo];
    
    address = [[UITextField alloc]initWithFrame:CGRectMake(40, centerH-100, screenRect.size.width-160, 30)];
    [address setBackgroundColor:[UIColor whiteColor]];
    [address setPlaceholder:@"请输入连接地址"];
    [address setText:[AppInfo getHistoryValueByKey:@"Address"]];
    address.returnKeyType = UIReturnKeyDone;
    address.delegate = self;
    [address setHidden:true];
    
    UIButton *connect = [UIButton buttonWithType:UIButtonTypeSystem];
    [connect setFrame:CGRectMake(screenRect.size.width-120, centerH-100, 80,30)];
    [connect setTitle:@"连接" forState:UIControlStateNormal];
    [connect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [connect addTarget:self action:@selector(startApp:) forControlEvents:UIControlEventTouchDown];
    [connect setHidden:true];
    
    [self.view addSubview:address];
    [self.view addSubview:connect];
}
#pragma mark - delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startApp:nil];
}
@end
