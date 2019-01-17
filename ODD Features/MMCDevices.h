//
//  MMCDevices.h
//  ODD Features
//
//  Created by Yuxin Wang on 2018/8/7.
//  Copyright © 2018 Yuxin Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMCDevices : NSObject

+ (NSArray<NSDictionary*>*)devices;
+ (NSArray<NSData*>*)getConfiguration:(uint64_t)entryID;
+ (BOOL)openTray:(uint64_t)entryID;
+ (NSString*)getMediaBSDName:(uint64_t)entryID;

@end
