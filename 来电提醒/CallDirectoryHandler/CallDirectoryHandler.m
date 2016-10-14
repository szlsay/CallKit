//
//  CallDirectoryHandler.m
//  CallDirectoryHandler
//
//  Created by ST on 16/10/14.
//  Copyright © 2016年 ST. All rights reserved.
//

//拦截号码或者号码标识的情况下,号码必须要加国标区号!
#import "CallDirectoryHandler.h"

@interface CallDirectoryHandler () <CXCallDirectoryExtensionContextDelegate>

@end

@implementation CallDirectoryHandler

#pragma mark - --- 1.init 生命周期 ---

#pragma mark - --- 2.delegate 视图委托 ---
//开始请求的方法，在打开设置-电话-来电阻止与身份识别开关时，系统自动调用
- (void)beginRequestWithExtensionContext:(CXCallDirectoryExtensionContext *)context {
    context.delegate = self;
    NSLog(@"%s %@", __FUNCTION__, context);
    if (![self addBlockingPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add blocking phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:1 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    if (![self addIdentificationPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add identification phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:2 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    [context completeRequestWithCompletionHandler:nil];
}

//添加黑名单：根据生产的模板，只需要修改CXCallDirectoryPhoneNumber数组，数组内号码要按升序排列
- (BOOL)addBlockingPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    CXCallDirectoryPhoneNumber phoneNumbers[] = {  8618665710271 };
    NSUInteger count = (sizeof(phoneNumbers) / sizeof(CXCallDirectoryPhoneNumber));
    
    for (NSUInteger index = 0; index < count; index += 1) {
        CXCallDirectoryPhoneNumber phoneNumber = phoneNumbers[index];
        [context addBlockingEntryWithNextSequentialPhoneNumber:phoneNumber];
    }
    
    return YES;
}

// 添加信息标识：需要修改CXCallDirectoryPhoneNumber数组和对应的标识数组；CXCallDirectoryPhoneNumber数组存放的号码和标识数组存放的标识要一一对应，CXCallDirectoryPhoneNumber数组内的号码要按升序排列
- (BOOL)addIdentificationPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    
    NSArray<NSDictionary *> * array = [self readData];
    for (NSDictionary *dic in array) {
        NSString *phone = dic.allKeys[0];
        NSString *label = dic[phone];
        if (phone == nil || label == nil) {
            break;
        }else {
            phone = [self fixPhone:phone];
        }
        CXCallDirectoryPhoneNumber phoneNumber = [phone longLongValue];
        [context addIdentificationEntryWithNextSequentialPhoneNumber:phoneNumber label:label];
    }
    return YES;
    
}

#pragma mark - CXCallDirectoryExtensionContextDelegate

- (void)requestFailedForExtensionContext:(CXCallDirectoryExtensionContext *)extensionContext withError:(NSError *)error {
}
#pragma mark - --- 3.event response 事件相应 ---

#pragma mark - --- 4.private methods 私有方法 ---
-(NSArray<NSDictionary *> *)readData
{
    NSString *filePathIdentification = [self readPathIdentification];
    return [self arraySort:[NSArray arrayWithContentsOfFile:filePathIdentification] ASC:YES];
}

- (NSString *)readPathIdentification{
    NSURL *fileUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.st.cn.CallTest"];
    NSString *filePath = [fileUrl.absoluteString substringFromIndex:(@"file://".length)];
    NSString *filePathIdentification = [filePath stringByAppendingString:@"CallDirectoryHandler.plist"];
    return filePathIdentification;
}

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



@end
