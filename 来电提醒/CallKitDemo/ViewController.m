//
//  ViewController.m
//  CallKitDemo
//
//  Created by ST on 16/10/14.
//  Copyright © 2016年 ST. All rights reserved.
//

#import "ViewController.h"

#import "CallDirectoryManager.h"

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
@property(nonatomic, strong)NSMutableDictionary *dicIdentification;
/** 7.电话管理者 */
@property(nonatomic, strong)CallDirectoryManager *manager;
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
    
    NSArray<NSDictionary *> *array = [self.manager readData];
    NSString *message = @"";
    if (array.count > 0) {
        for (NSDictionary *dic in array) {
            message = [message stringByAppendingString:dic.allKeys[0]];
        }
    }else {
        message = @"没有数据";
    }
    
    [[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}

-(void)checkPermissions
{
    [self.view endEditing:YES];
    
    [self.manager getEnabledStatusWithCompletionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error) {
        NSString *message;
        if (!error) {
            switch (enabledStatus) {
                case CXCallDirectoryEnabledStatusUnknown:message = @"不知道";
                    break;
                case CXCallDirectoryEnabledStatusDisabled:message = @"未授权，请在设置->电话授权相关权限";
                    break;
                case CXCallDirectoryEnabledStatusEnabled:message = @"授权";
                    break;
            }
        }else {
            message = @"有错误";
        }
        
        [[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

-(void)saveData
{
    
    [self.view endEditing:YES];
    
    NSString *photo = self.textPhoto.text;
    NSString *name = self.textName.text;
    
    [self.manager.arrayCall addObject:@{photo:name}];
    
    [self.manager saveDataWithCompletion:^(BOOL success) {
        if (success) {
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
             NSLog(@"%s %@", __FUNCTION__, [self.manager readData]);
            
        }else {
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"保存失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

-(void)updateData
{
    [self.manager updateDataWithCompletion:^(NSError * _Nullable error) {
        if (error == nil) {
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"更新成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }else {
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"更新失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    }];
}


#pragma mark - --- 4.private methods 私有方法 ---

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

- (NSMutableDictionary *)dicIdentification
{
    if (!_dicIdentification) {
        _dicIdentification = @{}.mutableCopy;
    }
    return _dicIdentification;
}

- (CallDirectoryManager *)manager
{
    if (!_manager) {
        _manager = [[CallDirectoryManager alloc]init];
    }
    return _manager;
}

@end

