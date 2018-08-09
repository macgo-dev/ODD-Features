//
//  FeatureData.h
//  ODD Features
//
//  Created by Yuxin Wang on 2018/8/8.
//  Copyright © 2018 Yuxin Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeatureData : NSObject

+ (NSDictionary*)parseHeader:(NSData*)data;
+ (NSArray<NSDictionary*>*)parse:(NSData*)data;

@end
