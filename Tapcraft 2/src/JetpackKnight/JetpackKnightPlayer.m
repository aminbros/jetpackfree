//
//  JetpackKnightPlayer.m
//  JetpackKnight
//
//  Created by Hossein Amin on 5/2/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import "JetpackKnightPlayer.h"

@implementation JetpackKnightPlayer

- (instancetype)init {
    self = [super init];
    if(self != nil) {
        _touchedGrounds = [NSMutableArray new];
    }
    return self;
}

@end
