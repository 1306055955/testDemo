//
//  ViewController.m
//  Location
//
//  Created by mapbar on 2017/9/27.
//  Copyright © 2017年 mapbar. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>

#import <CoreLocation/CoreLocation.h>

#import "ViewController.h"

#import "LYLAlertView.h"
#import "SFHFKeychainUtils.h"

@interface ViewController ()<CLLocationManagerDelegate>
@property(strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    int i = [@"" intValue];
    
    for (int i = 0; i<3; i++)
    {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame  = CGRectMake(100, 100+80*i, 50, 50);
        btn.backgroundColor = [UIColor redColor];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    NSLog(@"---%@",self.view.layer.sublayers);
}

-(void)btnClick:(UIButton *)btn
{
//    [self authenticateUser];
//    [self authenticateButtonTapped];
//    [self authen];

    
    switch (btn.tag) {
        case 0://添加
            {
                /**
                 *  情况1:addSublayer
                 */
                [self.view.layer addSublayer:[self shadowAsInverse]];

                
                NSArray *arr = @[@"您有什么需要？",@"有什么需要帮忙的？",@"我来了",@"嗨",@"您好",@"哈喽",@"小新来了",@"到",@"小新为您服务",@"主人，您好",@"您需要什么服务？",@"小新在",@"嘿",@"需要帮忙吗？",@"有什么可以帮您？",@"我在呢",@"您好啊",@"主人您好，见到您真高兴",@"嘿，主人您好",@"嗨，主人你终于来看我了",@"主人您好，需要帮助吗？",@"主人你来啦，需要小新为您做什么",@"小新来了，有什么可以帮您",@"你好，我是聪明的小新"];
                NSInteger index = arc4random_uniform((uint32_t)arr.count);
                NSString * psw = arr[index];
                
                NSLog(@"添加：%@  %d",psw,[SFHFKeychainUtils storeUsername:@"qwer" andPassword:psw forServiceName:[[NSBundle mainBundle] bundleIdentifier] updateExisting:NO error:nil]);
            }
            break;
        case 1://删除
        {
            /**
             *  情况2:insertSublayer
             */
            [self.view.layer insertSublayer:[self shadowAsInverse] atIndex:0];
            
            NSLog(@"%@",self.view.layer.sublayers);
            NSLog(@"删除：%d",[SFHFKeychainUtils deleteItemForUsername:@"qwer" andServiceName:[[NSBundle mainBundle] bundleIdentifier] error:nil]);
        }
            break;
        case 2://查找
        {
            NSLog(@"查找：%@",[SFHFKeychainUtils getPasswordForUsername:@"qwer" andServiceName:[[NSBundle mainBundle] bundleIdentifier] error:nil]);
            
        }
            break;
        default:
            break;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

-(void)authen
{
    //新建LAContext实例
    LAContext  *authenticationContext= [[LAContext alloc]init];
    NSError *error;
    //1:检查Touch ID 是否可用
    if ([authenticationContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        NSLog(@"touchId 可用");
        //2:执行认证策略
        [authenticationContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"需要验证您的指纹来确认您的身份信息" reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"通过了Touch Id指纹验证");
            }else{
                NSLog(@"error===%@",error);
                NSLog(@"code====%d",error.code);
                NSLog(@"errorStr ======%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]);
                if (error.code == -2) {//点击了取消按钮
                    NSLog(@"点击了取消按钮");
                }else if (error.code == -3){//点输入密码按钮
                    NSLog(@"点输入密码按钮");
                }else if (error.code == -1){//连续三次指纹识别错误
                    NSLog(@"连续三次指纹识别错误");
                }else if (error.code == -4){//按下电源键
                    NSLog(@"按下电源键");
                }else if (error.code == -8){//Touch ID功能被锁定，下一次需要输入系统密码
                    NSLog(@"Touch ID功能被锁定，下一次需要输入系统密码");
                }
                NSLog(@"未通过Touch Id指纹验证");
            }
        }];
    }else{
        //todo goto 输入密码页面
        NSLog(@"error====%@",error);
        NSLog(@"抱歉，touchId 不可用,请开启touch id");
    }
}



- (void)authenticateUser
{
    //初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    //错误对象
    NSError* error = nil;
    NSString* result = @"Authentication is needed to access your notes.";
    
    //首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            if (success) {
                //验证成功，主线程处理UI
            }
            else
            {
                NSLog(@"%@",error.localizedDescription);
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        NSLog(@"Authentication was cancelled by the system");
                        //切换到其他APP，系统取消验证Touch ID
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        NSLog(@"Authentication was cancelled by the user");
                        //用户取消验证Touch ID
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        NSLog(@"User selected to enter custom password");
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择输入密码，切换主线程处理
                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //其他情况，切换主线程处理
                        }];
                        break;
                    }
                }
            }
        }];
    }
    else
    {
        //不支持指纹识别，LOG出错误详情
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled: //未设置指纹
            {
                NSLog(@"TouchID is not enrolled");
                break;
            }
            case LAErrorPasscodeNotSet:     //未设置密码
            {
                NSLog(@"A passcode has not been set");
                break;
            }
            default:
            {
                NSLog(@"TouchID not available");
                break;
            }
        }
        
        NSLog(@"%@",error.localizedDescription);
    }
}

- (void)authenticateButtonTapped{
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"输入密码";
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"您是这设备的所有者吗？"
                          reply:^(BOOL success, NSError *error) {
                              if (success) {
                                  dispatch_async (dispatch_get_main_queue(), ^{
                                      //在主线程更新 UI,不然会卡主
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                                      message:@"你是设备主人。"
                                                                                     delegate:self
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                  });
                                  
                              }else{
                                  
                                  /*
                                   // 用户未提供有效证书,(3次机会失败 --身份验证失败)。
                                   LAErrorAuthenticationFailed = kLAErrorAuthenticationFailed,
                                   
                                   // 认证被取消,(用户点击取消按钮)。
                                   LAErrorUserCancel           = kLAErrorUserCancel,
                                   
                                   // 认证被取消,用户点击回退按钮(输入密码)。
                                   LAErrorUserFallback         = kLAErrorUserFallback,
                                   
                                   // 身份验证被系统取消,(比如另一个应用程序去前台,切换到其他 APP)。
                                   LAErrorSystemCancel         = kLAErrorSystemCancel,
                                   
                                   // 身份验证无法启动,因为密码在设备上没有设置。
                                   LAErrorPasscodeNotSet       = kLAErrorPasscodeNotSet,
                                   
                                   // 身份验证无法启动,因为触摸ID在设备上不可用。
                                   LAErrorTouchIDNotAvailable  = kLAErrorTouchIDNotAvailable,
                                   
                                   // 身份验证无法启动,因为没有登记的手指触摸ID。 没有设置指纹密码时。
                                   LAErrorTouchIDNotEnrolled   = kLAErrorTouchIDNotEnrolled,
                                   **/
                                  switch (error.code) {
                                      case LAErrorAuthenticationFailed:
                                          NSLog(@"身份验证失败。");
                                          
                                          break;
                                          
                                      case LAErrorUserCancel:
                                          NSLog(@"用户点击取消按钮。");
                                          
                                          break;
                                          
                                      case LAErrorUserFallback:
                                      {
                                          NSLog(@"用户点击输入密码。");
                                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                              //用户选择输入密码，切换主线程处理
                                          }];
                                          break;
                                      }
                                      case LAErrorSystemCancel:
                                          NSLog(@"另一个应用程序去前台");
                                          
                                          break;
                                          
                                      case LAErrorPasscodeNotSet:
                                          NSLog(@"密码在设备上没有设置");
                                          
                                          break;
                                          
                                      case LAErrorTouchIDNotAvailable:
                                          NSLog(@"触摸ID在设备上不可用");
                                          
                                          break;
                                          
                                      case LAErrorTouchIDNotEnrolled:
                                          NSLog(@"没有登记的手指触摸ID。");
                                          
                                          break;
                                          
                                      default:
                                      {
                                          NSLog(@"Touch ID没配置");
                                          [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                              //其他情况，切换主线程处理
                                          }];
                                          break;
                                      }
                                  }
                              }
                          }];
        
    } else {
        dispatch_async (dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                            message:@"您的设备没有触摸ID."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
}













-(void)locationRequest
{
    //
    //    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)
    //    {
    //        if (@available(iOS 11.0, *)) {
    //
    //            [_locationManager requestAlwaysAuthorization];
    //            NSLog(@"111111111111111111");
    //        }
    //        else
    //        {
    //            [_locationManager requestAlwaysAuthorization];
    //            NSLog(@"222222222222222221");
    //        }
    //    }
    //
    //
    //    NSLog(@"%d;;;;;",[CLLocationManager authorizationStatus]);
    //    // 判断是否开启定位
    //    if ([CLLocationManager locationServicesEnabled]) {
    //
    //        NSLog(@"---------------");
    //    }
    //    else
    //    {
    //        NSLog(@"=====------------");
    //    }
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"locations---%@",locations.lastObject);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    NSLog(@"newHeading---%@",newHeading);
}
//didUpdateToLocation
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(nonnull CLLocation *)newLocation fromLocation:(nonnull CLLocation *)oldLocation{
    NSLog(@"didUpdateToLocation");
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            NSLog(@"用户还未决定授权");
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
            } else {
                NSLog(@"定位服务关闭，不可用");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"获得前后台授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"获得前台授权");
            break;
        }
        default:
            break;
    }
}


-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (CAGradientLayer *)shadowAsInverse;
{
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    CGRect newShadowFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    newShadow.frame = newShadowFrame;
    //添加渐变的颜色组合
    newShadow.colors = [NSArray arrayWithObjects:(id)[self colorWithHexString:@"333333"].CGColor,(id)[self colorWithHexString:@"8100E8"].CGColor,nil];
    return newShadow;
}

- (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSString *hexString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) {
        return nil;
    }
    return [self colorWithRGBHex:hexNum];
}

- (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}
@end
