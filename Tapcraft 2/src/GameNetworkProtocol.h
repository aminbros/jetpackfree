//
//  GameNetworkProtocol.h
//  JetpackKnight
//
//  Created by Hossein Amin on 5/6/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint16_t, GameNetworkMessage) {
    GN_PEERS_CONNECTED = 1,
    // GI is game initiator
    GN_RANDOM_SEED_FOR_PICK_GI, // data is little uint32_t
    GN_GI_INIT_GAME, // data is GNInitGameMsg
    GN_GI_START_GAME_COUNT_DOWN, // data is little uint32_t count down from
    GN_GI_START_GAME, // data is nil
    GN_READY_TO_START, // data is nil
    GN_ACTION, // data is GNActionMsg
    GN_COMMIT // data is little uint32_t as timeStep
};

typedef NS_ENUM(uint16_t, GNAction) {
    GNA_Jump,
    GNA_JetpackEngineOn,
    GNA_JetpackEngineOff,
    GNA_LeftShoot,
    GNA_RightShoot
};

@protocol GNPacketData <NSObject>
- (NSData*)dataForPacket;
+ (instancetype)instanceFromData:(NSData*)data;
@end

@interface GNPacket : NSObject<GNPacketData>

@property GameNetworkMessage message;
@property NSData *data;

@end

@interface GNActionMsg : NSObject<GNPacketData>

@property uint32_t timeStep;
@property GNAction action;

@end

@interface GNInitGameMsg : NSObject<GNPacketData>

@property uint32_t randomSeed;
@property NSArray<NSString*> *playersId;

@end

@interface GameNetworkProtocol : NSObject

+ (NSData*)makePacketWithMessage:(GameNetworkMessage)message data:(NSData*)data;
+ (NSData*)makePacketWithMessage:(GameNetworkMessage)message uint32Data:(uint32_t)uint32;
+ (void)readPacket:(NSData*)packetData message:(GameNetworkMessage*)message uint32Data:(uint32_t*)uint32;
+ (NSString*)readStringFromData:(NSData*)data offset:(NSInteger)offset endsAt:(NSInteger*)endsAt;
+ (void)writeString:(NSString*)string toData:(NSMutableData*)mdata;

+ (uint32_t)readUInt32FromData:(NSData*)data offset:(NSInteger)offset endsAt:(NSInteger*)endsAt;
@end
