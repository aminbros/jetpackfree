//
//  RandomGenerator.m
//  JetpackKnight
//
//  Created by Hossein Amin on 5/7/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import "RandomGenerator.h"

@implementation RandomGenerator

+ (NSInteger)intRandomWithOffset:(NSInteger)offset limit:(NSInteger)limit
{
    return offset + (NSInteger)floor(((CGFloat)((long)random()) / ((NSInteger)RAND_MAX + 1)) * (limit - offset));
}

+ (CGFloat)floatRandomWithMax:(CGFloat)max
{
    return ((CGFloat)random() / RAND_MAX) * max;
}

+ (void)setSeed:(NSInteger)seed {
    srandom((int)seed);
}

@end
