//
//  CallDirectoryManager.h
//  CallKitDemo
//
//  Created by ST on 16/10/14.
//  Copyright © 2016年 ST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface CallDirectoryManager : NSObject

/** 1.来电识别的数组，数据类型为字典，例如 {@"8613234125312":@"买保险的"}  */
@property(nonatomic, strong)NSMutableArray<NSDictionary *> *arrayCall;

/** 1.更新数据 */
- (void)updateDataWithCompletion:(nullable void (^)(NSError *_Nullable error))completion;
/** 2.获取权限 */
- (void)getEnabledStatusWithCompletionHandler:(void (^)(CXCallDirectoryEnabledStatus enabledStatus, NSError *_Nullable error))completion;
/** 3.保存来电信息 */
- (void)saveDataWithCompletion:(void(^)(BOOL success))completion;
/** 4.读取来电信息 */
-(NSArray<NSDictionary *> *)readData;
@end

NS_ASSUME_NONNULL_END
