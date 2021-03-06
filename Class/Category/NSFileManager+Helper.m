//
//  NSFileManager+Helper.m
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/13.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import "NSFileManager+Helper.h"

@implementation NSFileManager (Helper)
+ (BOOL)fileExist:(NSString *)path
{
    if(path == nil)
    {
        return NO;
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)dirExist:(NSString *)path
{
    BOOL isDirecotry = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path
                                              isDirectory:&isDirecotry]
        || !isDirecotry)
    {
        isDirecotry = NO;
    }
    
    return isDirecotry;
}

+ (BOOL)mkDir:(NSString *)path
{
    BOOL isSecc = YES;
    NSError *erro = nil;
    if (![NSFileManager dirExist:path])
    {
        if(![[NSFileManager defaultManager] createDirectoryAtPath:path
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&erro]
           || erro != nil)
        {
            NSAssert(0, @"文件夹创建失败！");
            isSecc = NO;
        }
    }
    
    return isSecc;
}


+ (BOOL)copy:(NSString *)from to:(NSString *)to
{
    NSError *error = nil;
    BOOL bRet = [[NSFileManager defaultManager] copyItemAtPath:from toPath:to error:&error];
    if (error)
        NSLog(@"%@",error);
    return bRet;
}

+ (BOOL)move:(NSString *)from to:(NSString *)to
{
    NSError *error = nil;
    BOOL bRet = [[NSFileManager defaultManager] moveItemAtPath:from toPath:to error:&error];
    if (error)
        NSLog(@"%@",error);
    return bRet;
}

+ (BOOL)deleteFile:(NSString*)path
{
    NSError *error = nil;
    BOOL bRet = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    return bRet;
}
+ (BOOL)hjw_saveData:(NSData *)data filePath:(NSString *)filePath{
    
    if (![NSFileManager mkDir:[filePath stringByDeletingLastPathComponent]]) {
        
        NSAssert(0, @"路径不存在");
        return NO;
    }
    
    return [data writeToFile:filePath atomically:YES];
}

+ (UIImage *)hjw_getImageFileName:(NSString *)filePath{
    
    if (![NSFileManager fileExist:filePath]) {
        
        NSAssert(0, @"路径不存在");
        return nil;
    }
    return [UIImage imageWithContentsOfFile:filePath];
}
@end
