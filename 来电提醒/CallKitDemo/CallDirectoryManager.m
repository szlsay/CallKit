//
//  CallDirectoryManager.m
//  CallKitDemo
//
//  Created by ST on 16/10/14.
//  Copyright © 2016年 ST. All rights reserved.
//

#import "CallDirectoryManager.h"

static NSString *IdentifierExtension = @"com.st.cn.CallTest.CallExtension";

@implementation CallDirectoryManager

#pragma mark - --- 1.init 生命周期 ---

#pragma mark - --- 2.delegate 视图委托 ---

#pragma mark - --- 3.event response 事件相应 ---
/** 1.更新数据 */
- (void)updateDataWithCompletion:(nullable void (^)(NSError *_Nullable error))completion{
    CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
    [manager reloadExtensionWithIdentifier:IdentifierExtension completionHandler:^(NSError * _Nullable error) {
        completion(error);
    }];
}

/** 2.获取权限 */
- (void)getEnabledStatusWithCompletionHandler:(void (^)(CXCallDirectoryEnabledStatus enabledStatus, NSError *_Nullable error))completion{
    CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
    [manager getEnabledStatusForExtensionWithIdentifier:IdentifierExtension completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error) {
        completion(enabledStatus, error);
    }];
}

/** 3.保存来电信息 */
- (void)saveDataWithCompletion:(void(^)(BOOL success))completion{
    NSString *filePathIdentification = [self readPathIdentification];
    [[NSFileManager defaultManager] removeItemAtPath:filePathIdentification error:nil];
    if (self.arrayCall.count > 0) {
        BOOL success = [self.arrayCall writeToFile:filePathIdentification atomically:YES];
        
        if (success) {
            [self updateDataWithCompletion:^(NSError * _Nullable error) {
                if (error == nil) {
                    completion(YES);
                }else {
                    completion(NO);
                }
            }];
        }else {
            completion(NO);
        }
    }else{
        completion(YES);
    }
}

/** 4.读取来电信息 */
-(NSArray<NSDictionary *> *)readData
{
    NSString *filePathIdentification = [self readPathIdentification];
    return [self arraySort:[NSArray arrayWithContentsOfFile:filePathIdentification] ASC:YES];
}

#pragma mark - --- 4.private methods 私有方法 ---
/** 1.获取扩展文件位置 */
- (NSString *)readPathIdentification{
    NSURL *fileUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.st.cn.CallTest"];
    NSString *filePath = [fileUrl.absoluteString substringFromIndex:(@"file://".length)];
    NSString *filePathIdentification = [filePath stringByAppendingString:@"CallDirectoryHandler.plist"];
    return filePathIdentification;
}

/** 2.数组排序 */
- (NSArray<NSDictionary *> *)arraySort:(NSArray<NSDictionary *> *)array ASC:(BOOL)ASC
{
    
    
    if (array == nil || [array count] == 0) {
        return nil;
    }
    
    return [array sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        if(ASC){
            if([obj1.allKeys[0] integerValue] > [obj2.allKeys[0] integerValue]) {
                return(NSComparisonResult)NSOrderedDescending;
            }
            if([obj1.allKeys[0] integerValue] < [obj2.allKeys[0] integerValue]) {
                return(NSComparisonResult)NSOrderedAscending;
            }
        }else{
            if([obj1.allKeys[0] integerValue] < [obj2.allKeys[0] integerValue]) {
                return(NSComparisonResult)NSOrderedDescending;
            }
            if([obj1.allKeys[0] integerValue] > [obj2.allKeys[0] integerValue]) {
                return(NSComparisonResult)NSOrderedAscending;
            }
        }
        return(NSComparisonResult)NSOrderedSame;
    }];
}
#pragma mark - --- 5.setters 属性 ---

#pragma mark - --- 6.getters 属性 —--

- (NSMutableArray<NSDictionary *> *)arrayCall
{
    if (!_arrayCall) {
        if ([self readData].count > 0) {
            _arrayCall = [self readData].mutableCopy;
        }else {
            _arrayCall = @[].mutableCopy;
        }
    }
    return _arrayCall;
}

@end
