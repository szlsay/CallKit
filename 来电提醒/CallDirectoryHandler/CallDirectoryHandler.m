//
//  CallDirectoryHandler.m
//  CallDirectoryHandler
//
//  Created by ST on 16/10/14.
//  Copyright © 2016年 ST. All rights reserved.
//

//拦截号码或者号码标识的情况下,号码必须要加国标区号!!!!!!!!
#import "CallDirectoryHandler.h"

@interface CallDirectoryHandler () <CXCallDirectoryExtensionContextDelegate>
@end

@implementation CallDirectoryHandler

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

    
    NSString *filePathIdentification = [self readPathIdentification];
    NSDictionary *dicIdentification = [[NSDictionary alloc] initWithContentsOfFile:filePathIdentification];
    NSArray *arrIdentificationPhones = [dicIdentification allKeys];
    NSUInteger count = [arrIdentificationPhones count];
    NSArray *sortedPhones = [self ArraySort:arrIdentificationPhones ASC:YES];
    
    for (NSUInteger i = 0; i < count; i += 1) {
        NSString *phone = [sortedPhones objectAtIndex:i];
        NSString *label = dicIdentification[phone];
        if (phone == nil || label == nil) {
            break;
        }
        CXCallDirectoryPhoneNumber phoneNumber = [phone longLongValue];
        [context addIdentificationEntryWithNextSequentialPhoneNumber:phoneNumber label:label];
    }
    
    return YES;
    
}

#pragma mark - CXCallDirectoryExtensionContextDelegate

- (void)requestFailedForExtensionContext:(CXCallDirectoryExtensionContext *)extensionContext withError:(NSError *)error {
}


- (NSString *)time{
    NSDate *date = [NSDate date];
    NSTimeInterval timeIntervalSince1970 = [date timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f",timeIntervalSince1970 * 1000];
}

- (NSString *)readPathIdentification{
    NSURL *fileUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.st.cn.CallTest"];
    NSString *filePath = [fileUrl.absoluteString substringFromIndex:(@"file://".length)];
    NSString *filePathIdentification = [filePath stringByAppendingString:@"CallDirectoryHandler.plist"];
    return filePathIdentification;
}

//数字数字从小到大排序
- (NSArray *)ArraySort:(NSArray *)array ASC:(BOOL)ASC
{
    if (array == nil || [array count] == 0) {
        return nil;
    }
    return [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if(ASC){
            if([obj1 integerValue] > [obj2 integerValue]) {
                return(NSComparisonResult)NSOrderedDescending;
            }
            if([obj1 integerValue] < [obj2 integerValue]) {
                return(NSComparisonResult)NSOrderedAscending;
            }
        }else{
            if([obj1 integerValue] < [obj2 integerValue]) {
                return(NSComparisonResult)NSOrderedDescending;
            }
            if([obj1 integerValue] > [obj2 integerValue]) {
                return(NSComparisonResult)NSOrderedAscending;
            }
        }
        return(NSComparisonResult)NSOrderedSame;
    }];
}
@end
