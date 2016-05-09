//
//  RandomGenerator.h
//  JetpackKnight
//
//  Created by Hossein Amin on 5/7/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomGenerator : NSObject

+ (NSInteger)intRandomWithOffset:(NSInteger)offset limit:(NSInteger)limit;
+ (CGFloat)floatRandomWithMax:(CGFloat)max;
+ (void)setSeed:(NSInteger)seed;

@end
