//
//  ViewController.m
//  CallKitDemo
//
//  Created by ST on 16/10/14.
//  Copyright © 2016年 ST. All rights reserved.
//

#import "ViewController.h"
#import <CallKit/CallKit.h>

@interface ViewController ()<UITextFieldDelegate>

/** 1.手机号 */
@property(nonatomic, strong)UITextField *textPhoto;
/** 2.姓名 */
@property(nonatomic, strong)UITextField *textName;
/** 3.保存信息 */
@property(nonatomic, strong)UIButton *buttonSave;
/** 4.检查权限 */
@property(nonatomic, strong)UIButton *buttonCheck;
/** 5.读取信息 */
@property(nonatomic, strong)UIButton *buttonRead;

/** 6.保存的数据 */
@property(nonatomic, strong)NSMutableDictionary *dicMuIdentification;
@end

@implementation ViewController

#pragma mark - --- 1.init 生命周期 ---
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textPhoto];
    [self.view addSubview:self.textName];
    [self.view addSubview:self.buttonSave];
    [self.view addSubview:self.buttonCheck];
    [self.view addSubview:self.buttonRead];
}
#pragma mark - --- 2.delegate 视图委托 ---

#pragma mark - --- 3.event response 事件相应 ---

-(void)readSavedInfo
{
    [self.view endEditing:YES];
    [self changeIdentificationCompletion:^(BOOL success) {
        
        NSString *filePathIdentification = [self readPathIdentification];
        NSDictionary *dicIdentification = [[NSDictionary alloc] initWithContentsOfFile:filePathIdentification];
        NSArray *arrIdentificationPhones = [dicIdentification allKeys];
        NSLog(@"%s %@", __FUNCTION__, arrIdentificationPhones);
        
        NSMutableString *message = @"".mutableCopy;
        for (NSString *string in [dicIdentification allKeys]) {
            message = [message stringByAppendingString:string].mutableCopy;
        }
        
        if (!success) {
            message = @"没有来电提醒信息".mutableCopy;
        }
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
}

-(void)checkPermissions
{
    [self.view endEditing:YES];
    CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
    // 获取权限状态
    [manager getEnabledStatusForExtensionWithIdentifier:@"com.st.cn.CallTest.CallExtension" completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error) {
        if (!error) {
            NSString *title = nil;
            if (enabledStatus == CXCallDirectoryEnabledStatusDisabled) {
                /*
                 CXCallDirectoryEnabledStatusUnknown = 0,
                 CXCallDirectoryEnabledStatusDisabled = 1,
                 CXCallDirectoryEnabledStatusEnabled = 2,
                 */
                title = @"未授权，请在设置->电话授权相关权限";
            }else if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
                title = @"授权";
            }else if (enabledStatus == CXCallDirectoryEnabledStatusUnknown) {
                title = @"不知道";
            }
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:title
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:@"有错误"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

-(void)saveData
{
    [self.view endEditing:YES];
    [self changeIdentificationCompletion:^(BOOL success) {
        if (success) {
            [self updateData];
        }else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:@"填写数据"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

-(void)updateData
{
    CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
    
    [manager reloadExtensionWithIdentifier:@"com.st.cn.CallTest.CallExtension" completionHandler:^(NSError * _Nullable error) {
        
        NSLog(@"%s %@", __FUNCTION__, error);
        
        if (error == nil) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:@"更新成功"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:@"更新失败"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}


- (NSString *)readPathIdentification{
    NSURL *fileUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.st.cn.CallTest"];
    NSString *filePath = [fileUrl.absoluteString substringFromIndex:(@"file://".length)];
    NSString *filePathIdentification = [filePath stringByAppendingString:@"CallDirectoryHandler.plist"];
    return filePathIdentification;
}

- (void)changeIdentificationCompletion:(void(^)(BOOL success))completion{
    
    if (self.textPhoto.text.length < 6) {
        completion(NO);
    }else {
        NSString *photo = [self fixPhone:self.textPhoto.text];
        [self.dicMuIdentification setValue:self.textName.text forKey:photo];
        
        NSString *filePathIdentification = [self readPathIdentification];
        [[NSFileManager defaultManager] removeItemAtPath:filePathIdentification error:nil];
        if (self.dicMuIdentification != nil && [self.dicMuIdentification count]) {
            BOOL success = [self.dicMuIdentification writeToFile:filePathIdentification atomically:YES];
            completion(success);
        }else{
            completion(YES);
        }
    }
}

#pragma mark - --- 4.private methods 私有方法 ---
- (NSString *)fixPhone:(NSString *)phone{
    NSString *stringPhone = [phone stringByReplacingOccurrencesOfString:@"+" withString:@""];
    stringPhone = [stringPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
    stringPhone = [stringPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    stringPhone = [stringPhone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    stringPhone = [stringPhone stringByReplacingOccurrencesOfString:@")" withString:@""];
    if (stringPhone != nil && stringPhone.length > 0) {
        NSInteger phonenumebr = [stringPhone longLongValue];
        NSString *stringFinal = [NSString stringWithFormat:@"%@%ld",([stringPhone hasPrefix:@"86"]?@"":@"86"),phonenumebr];
        return stringFinal;
    }
    return stringPhone;
}
#pragma mark - --- 5.setters 属性 ---

#pragma mark - --- 6.getters 属性 —--

- (UITextField *)textPhoto
{
    if (!_textPhoto) {
        CGFloat viewX = 20;
        CGFloat viewY = 100;
        CGFloat viewW = self.view.bounds.size.width - 2*viewX;
        CGFloat viewH = 44;
        _textPhoto = [[UITextField alloc]initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        [_textPhoto setKeyboardType:UIKeyboardTypePhonePad];
        [_textPhoto setPlaceholder:@"请输入手机号"];
        [_textPhoto setBorderStyle:UITextBorderStyleRoundedRect];
    }
    return _textPhoto;
}


- (UITextField *)textName
{
    if (!_textName) {
        CGFloat viewX = 20;
        CGFloat viewY = CGRectGetMaxY(self.textPhoto.frame) + 10;
        CGFloat viewW = self.view.bounds.size.width - 2*viewX;
        CGFloat viewH = 44;
        _textName = [[UITextField alloc]initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        [_textName setPlaceholder:@"请输入来电提醒内容"];
        [_textName setBorderStyle:UITextBorderStyleRoundedRect];
    }
    return _textName;
}

- (UIButton *)buttonSave
{
    if (!_buttonSave) {
        CGFloat viewX = 44;
        CGFloat viewY = CGRectGetMaxY(self.textName.frame) + 10;
        CGFloat viewW = self.view.bounds.size.width - 2*viewX;
        CGFloat viewH = 44;
        _buttonSave = [[UIButton alloc]initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        [_buttonSave setTitle:@"保存来电提醒" forState:UIControlStateNormal];
        [_buttonSave setBackgroundColor:[UIColor magentaColor]];
        [_buttonSave addTarget:self action:@selector(saveData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonSave;
}

- (UIButton *)buttonCheck
{
    if (!_buttonCheck) {
        CGFloat viewX = 44;
        CGFloat viewY = CGRectGetMaxY(self.buttonSave.frame) + 10;
        CGFloat viewW = self.view.bounds.size.width - 2*viewX;
        CGFloat viewH = 44;
        _buttonCheck = [[UIButton alloc]initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        [_buttonCheck setTitle:@"检查来电使用权限" forState:UIControlStateNormal];
        [_buttonCheck setBackgroundColor:[UIColor magentaColor]];
        [_buttonCheck addTarget:self action:@selector(checkPermissions) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonCheck;
}

- (UIButton *)buttonRead
{
    if (!_buttonRead) {
        CGFloat viewX = 44;
        CGFloat viewY = CGRectGetMaxY(self.buttonCheck.frame) + 10;
        CGFloat viewW = self.view.bounds.size.width - 2*viewX;
        CGFloat viewH = 44;
        _buttonRead = [[UIButton alloc]initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        [_buttonRead setTitle:@"读取来电提醒信息" forState:UIControlStateNormal];
        [_buttonRead setBackgroundColor:[UIColor magentaColor]];
        [_buttonRead addTarget:self action:@selector(readSavedInfo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonRead;
}

- (NSMutableDictionary *)dicMuIdentification
{
    if (!_dicMuIdentification) {
        _dicMuIdentification = @{}.mutableCopy;
    }
    return _dicMuIdentification;
}



@end

