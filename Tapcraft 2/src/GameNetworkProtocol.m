//
//  GameNetworkProtocol.m
//  JetpackKnight
//
//  Created by Hossein Amin on 5/6/16.
//  Copyright © 2016 Philips. All rights reserved.
//

#import "GameNetworkProtocol.h"

@implementation GNPacket

- (NSData*)dataForPacket {
    NSMutableData *mdata = [NSMutableData dataWithCapacity:sizeof(uint16_t) + self.data.length];
    uint16_t bmsg = CFSwapInt16HostToLittle(self.message);
    [mdata appendBytes:&bmsg length:sizeof(bmsg)];
    if(self.data != nil)
        [mdata appendData:self.data];
    return mdata;
}

+ (instancetype)instanceFromData:(NSData *)data {
    GNPacket *packet = [self new];
    uint16_t bmsg;
    [data getBytes:&bmsg range:NSMakeRange(0, sizeof(bmsg))];
    packet.message = CFSwapInt16LittleToHost(bmsg);
    if(data.length > sizeof(bmsg))
        packet.data = [data subdataWithRange:NSMakeRange(sizeof(bmsg), data.length - sizeof(bmsg))];
    else
        packet.data = nil;
    return packet;
}

@end

@implementation GNActionMsg

- (NSData*)dataForPacket {
    NSMutableData *mdata = [NSMutableData new];
    uint32_t bui32;
    uint16_t bui16;
    
    bui32 = CFSwapInt32HostToLittle(self.timeStep);
    [mdata appendBytes:&bui32 length:sizeof(bui32)];
    
    bui16 = CFSwapInt16HostToLittle(self.action);
    [mdata appendBytes:&bui16 length:sizeof(bui16)];
    
    
    return mdata;
}

+ (instancetype)instanceFromData:(NSData *)data {
    uint32_t bui32;
    uint16_t bui16;
    GNActionMsg *actionMsg = [self new];
    
    [data getBytes:&bui32 range:NSMakeRange(0, sizeof(bui32))];
    actionMsg.timeStep = CFSwapInt32LittleToHost(bui32);

    [data getBytes:&bui16 range:NSMakeRange(sizeof(bui32), sizeof(bui16))];
    actionMsg.action = CFSwapInt16LittleToHost(bui16);
    
    return actionMsg;
}

@end

@implementation GNCommitMsg

- (void)dealloc {
    if(self.actions != NULL)
        free(self.actions);
}

- (NSData*)dataForPacket {
    NSMutableData *mdata = [NSMutableData new];
    NSInteger offset;
    
    uint32_t lui32 = CFSwapInt32HostToLittle(self.timeStep);
    [mdata appendBytes:&lui32 length:sizeof(lui32)];
    offset = sizeof(lui32);
    
    [GameNetworkProtocol writeArrayUInt16:self.actions size:self.actionsSize toData:mdata];
    
    return mdata;
}

+ (instancetype)instanceFromData:(NSData *)data {
    GNCommitMsg *commitMsg = [self new];
    NSInteger offset;
    uint32_t lui32;
    [data getBytes:&lui32 range:NSMakeRange(0, sizeof(lui32))];
    commitMsg.timeStep = CFSwapInt32LittleToHost(lui32);
    offset = sizeof(lui32);
    
    // actions
    uint16_t size;
    commitMsg.actions = [GameNetworkProtocol readArrayUInt16FromData:data offset:offset endsAt:nil size:&size];
    commitMsg.actionsSize = size;
    
    return commitMsg;
}

+ (instancetype)commitTimeStep:(uint32_t)timeStep actions:(NSArray*)actionsArr {
    GNCommitMsg *commitMsg = [self new];
    commitMsg.timeStep = timeStep;
    uint16_t size = (uint16_t)actionsArr.count;
    uint16_t *actions = malloc(sizeof(*actions) * size);
    for(uint16_t i = 0; i < size; ++i) {
        actions[i] = (uint16_t)[[actionsArr objectAtIndex:i] integerValue];
    }
    commitMsg.actions = actions;
    commitMsg.actionsSize = size;
    return commitMsg;
}

@end

@implementation GNInitGameMsg

- (NSData *)dataForPacket {
    NSMutableData *mdata = [[NSMutableData alloc] init];
    uint32_t bui32 = CFSwapInt32HostToLittle(self.randomSeed);
    [mdata appendBytes:&bui32 length:sizeof(bui32)];
    
    uint8_t uint8 = (uint8_t)self.playersId.count;
    [mdata appendBytes:&uint8 length:sizeof(uint8)];
    
    for(NSString *userId in self.playersId) {
        [GameNetworkProtocol writeString:userId toData:mdata];
    }
    
    return mdata;
}

+ (instancetype)instanceFromData:(NSData *)data {
    NSInteger offset = 0;
    GNInitGameMsg *ret = [[GNInitGameMsg alloc] init];
    uint32_t bui32;
    [data getBytes:&bui32 range:NSMakeRange(offset, sizeof(bui32))];
    offset += sizeof(bui32);
    ret.randomSeed = CFSwapInt32LittleToHost(bui32);
    
    uint8_t size;
    [data getBytes:&size range:NSMakeRange(offset, sizeof(size))];
    offset += sizeof(size);
    
    NSMutableArray *mplayersId = [NSMutableArray new];
    for(uint8_t i = 0; i < size; ++i) {
        [mplayersId addObject:[GameNetworkProtocol readStringFromData:data offset:offset endsAt:&offset]];
    }
    
    ret.playersId = [mplayersId copy];
    
    return ret;
}

@end

@implementation GameNetworkProtocol

+ (NSData*)makePacketWithMessage:(GameNetworkMessage)message data:(NSData*)data {
    GNPacket *packet = [GNPacket new];
    packet.message = message;
    packet.data = data;
    return [packet dataForPacket];
}

+ (NSData*)makePacketWithMessage:(GameNetworkMessage)message uint32Data:(uint32_t)uint32 {
    uint32_t buint32 = CFSwapInt32HostToLittle(uint32);
    NSMutableData *mdata = [[NSMutableData alloc] initWithCapacity:sizeof(buint32)];
    [mdata appendBytes:&buint32 length:sizeof(buint32)];
    return [self makePacketWithMessage:message data:mdata];
}

+ (void)readPacket:(NSData*)packetData message:(GameNetworkMessage*)message uint32Data:(uint32_t*)uint32 {
    uint32_t buint32;
    GNPacket *packet = [GNPacket instanceFromData:packetData];
    [packet.data getBytes:&buint32 length:sizeof(buint32)];
    *message = packet.message;
    *uint32 = CFSwapInt32LittleToHost(buint32);
}

// user is responsible to free return value free
+ (uint16_t*)readArrayUInt16FromData:(NSData*)data offset:(NSInteger)offset endsAt:(NSInteger*)endsAt size:(uint16_t*)sizep {
    uint16_t size;
    [data getBytes:&size range:NSMakeRange(offset, sizeof(size))];
    size = CFSwapInt16LittleToHost(size);
    offset += sizeof(size);
    uint16_t *arr = malloc(size * sizeof(uint16_t));
    for(uint16_t i = 0; i < size; ++i) {
        uint16_t ui16;
        [data getBytes:&ui16 range:NSMakeRange(offset, sizeof(ui16))];
        offset += sizeof(ui16);
        arr[i] = CFSwapInt16LittleToHost(ui16);
    }
    if(endsAt != nil)
        *endsAt = offset;
    *sizep = size;
    return arr;
}

+ (void)writeArrayUInt16:(uint16_t*)ui16p size:(uint16_t)size toData:(NSMutableData*)mdata {
    uint16_t lsize = CFSwapInt16HostToLittle(size);
    [mdata appendBytes:&lsize length:sizeof(lsize)];
    for(uint16_t i = 0; i < size; ++i) {
        uint16_t ui16 = CFSwapInt16HostToLittle((uint16_t)ui16p[i]);
        [mdata appendBytes:&ui16 length:sizeof(ui16)];
    }
}

// user is responsible to free return value free
+ (uint32_t*)readArrayUInt32FromData:(NSData*)data offset:(NSInteger)offset endsAt:(NSInteger*)endsAt size:(uint16_t*)sizep {
    uint16_t size;
    [data getBytes:&size range:NSMakeRange(offset, sizeof(size))];
    size = CFSwapInt16LittleToHost(size);
    offset += sizeof(size);
    uint32_t *arr = malloc(size * sizeof(uint32_t));
    for(uint16_t i = 0; i < size; ++i) {
        uint32_t ui32;
        [data getBytes:&ui32 range:NSMakeRange(offset, sizeof(ui32))];
        offset += sizeof(ui32);
        arr[i] = CFSwapInt32LittleToHost(ui32);
    }
    if(endsAt != nil)
        *endsAt = offset;
    *sizep = size;
    return arr;
}

+ (void)writeArrayUInt32:(uint32_t*)ui32p size:(uint16_t)size toData:(NSMutableData*)mdata {
    uint16_t lsize = CFSwapInt16HostToLittle((uint16_t)size);
    [mdata appendBytes:&lsize length:sizeof(lsize)];
    for(uint16_t i = 0; i < size; ++i) {
        uint32_t ui32 = CFSwapInt32HostToLittle((uint32_t)ui32p[i]);
        [mdata appendBytes:&ui32 length:sizeof(ui32)];
    }
}

+ (uint32_t)readUInt32FromData:(NSData*)data offset:(NSInteger)offset endsAt:(NSInteger*)endsAt {
    uint32_t buint32;
    [data getBytes:&buint32 range:NSMakeRange(offset, sizeof(buint32))];
    if(endsAt != nil)
        *endsAt = offset + sizeof(buint32);
    return CFSwapInt32LittleToHost(buint32);
}

+ (NSString*)readStringFromData:(NSData*)data offset:(NSInteger)offset endsAt:(NSInteger*)endsAt {
    uint16_t buint16;
    [data getBytes:&buint16 range:NSMakeRange(offset, sizeof(buint16))];
    uint16_t size = CFSwapInt16LittleToHost(buint16);
    NSRange range = NSMakeRange(offset + sizeof(buint16), size);
    if(endsAt != nil)
        *endsAt = range.location + range.length;
    return [[NSString alloc] initWithData:[data subdataWithRange:range] encoding:NSUTF8StringEncoding];
}

+ (void)writeString:(NSString*)string toData:(NSMutableData*)mdata {
    uint16_t buint16 = CFSwapInt16HostToLittle((uint16_t)string.length);
    [mdata appendBytes:&buint16 length:sizeof(buint16)];
    [mdata appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
