//
//  JetpackKnightGame.m
//  JetpackKnight
//
//  Created by Hossein Amin on 5/2/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import "JetpackKnightGame.h"

@implementation JetpackKnightGame

- (void)initialize {
    [super initialize];
    self.players = self.jGameData.players;
    // place players
    for(JetpackKnightPlayer *player in _players) {
        Character *character = player.character;
        character.renderOutline = YES;
        character.drawable = character.runningDrawable;
        ObjectGameInfo *oGameInfo = [[ObjectGameInfo alloc] init];
        character.objectGameInfo = oGameInfo;
        oGameInfo.body = [self.gameSimulator addObject:character];
    }
}

- (JetpackKnightGameData *)jGameData {
    return (id)self.gameData;
}

@end
