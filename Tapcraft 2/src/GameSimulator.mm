/*
 * Author: Hossein Amin, aminbros.com
 */

#import "GameSimulator.h"
#import "Bound.h"
#include <Box2D/Box2D.h>
#include "Box2DConv.h"

// defs

@interface SimBody()
@property b2Body *body;
+ (instancetype)bodyWithB2:(b2Body*)body;
@end
@implementation SimBody

+ (instancetype)bodyWithB2:(b2Body*)body {
    SimBody *i = [[self alloc] init];
    i.body = body;
    return i;
}

- (id)getUserData {
    return (__bridge id)_body->GetUserData();
}

- (CGPoint)getLinearVelocity
{
    CGPoint point;
    b2Vec2 vec2 = _body->GetLinearVelocity();
    write_b2Vec_to_CGPoint(vec2, point);
    return point;
}

- (void)applyForceToCenter:(CGPoint*)force
{
    b2Vec2 vec2;
    write_CGPoint_to_b2Vec2(*force, vec2);
    _body->ApplyForceToCenter(vec2, YES);
}
@end

@interface SimFixture()
@property b2Fixture *fixture;
+ (instancetype)fixtureWithB2:(b2Fixture*)fixture;
@end
@implementation SimFixture

+ (instancetype)fixtureWithB2:(b2Fixture*)fixture {
    SimFixture *i = [[self alloc] init];
    i.fixture = fixture;
    return i;
}

- (SimBody*)getBody {
    return [SimBody bodyWithB2:_fixture->GetBody()];
}

@end

@interface SimManifold()
@property b2Manifold *manifold;
+ (instancetype)manifoldWithB2:(b2Manifold*)manifold;
@end
@implementation SimManifold

+ (instancetype)manifoldWithB2:(b2Manifold*)manifold {
    SimManifold *i = [[self alloc] init];
    i.manifold = manifold;
    return i;
}

- (SimManifoldType)type {
    return (SimManifoldType)_manifold->type;
}

@end

@interface SimContact()
@property b2Contact *contact;
+ (instancetype)contactWithB2:(b2Contact*)contact;
@end
@implementation SimContact

+ (instancetype)contactWithB2:(b2Contact*)contact {
    SimContact *i = [[self alloc] init];
    i.contact = contact;
    return i;
}

- (SimManifold*)getManifold {
    return [SimManifold manifoldWithB2:_contact->GetManifold()];
}
- (BOOL)isTouching {
    return _contact->IsTouching();
}
- (void)setEnabled:(BOOL)enable {
    _contact->SetEnabled(enable);
}
- (BOOL)isEnabled {
    return _contact->IsEnabled();
}
- (SimFixture*)getFixtureA {
    return [SimFixture fixtureWithB2:_contact->GetFixtureA()];
}
- (NSInteger)getChildAtIndexA {
    return (NSInteger)_contact->GetChildIndexA();
}
- (SimFixture*)getFixtureB {
    return [SimFixture fixtureWithB2:_contact->GetFixtureB()];
}
- (NSInteger)getChildAtIndexB {
    return (NSInteger)_contact->GetChildIndexB();
}

@end

@interface SimContactImpulse()
@property b2ContactImpulse *contactImpulse;
+ (instancetype)contactImpulseWithB2:(b2ContactImpulse*)contactImpulse;
@end
@implementation SimContactImpulse

+ (instancetype)contactImpulseWithB2:(b2ContactImpulse*)contactImpulse {
    SimContactImpulse *i = [[self alloc] init];
    i.contactImpulse = contactImpulse;
    return i;
}

@end

// contact callback
class gsContactListener : public b2ContactListener
{
 public:
    id<SimContactDelegate> delegate;
    
    ~gsContactListener() {}

    /// Called when two fixtures begin to touch.
    void BeginContact(b2Contact* contact)
    {
        [delegate beginContact:[SimContact contactWithB2:contact]];
    }

    /// Called when two fixtures cease to touch.
    void EndContact(b2Contact* contact)
    {
        [delegate endContact:[SimContact contactWithB2:contact]];
    }

    /// This is called after a contact is updated. This allows you to inspect a
    /// contact before it goes to the solver. If you are careful, you can modify the
    /// contact manifold (e.g. disable contact).
    /// A copy of the old manifold is provided so that you can detect changes.
    /// Note: this is called only for awake bodies.
    /// Note: this is called even when the number of contact points is zero.
    /// Note: this is not called for sensors.
    /// Note: if you set the number of contact points to zero, you will not
    /// get an EndContact callback. However, you may get a BeginContact callback
    /// the next step.
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
    {
        [delegate preSolve:[SimContact contactWithB2:contact] oldManifold:[SimManifold manifoldWithB2:(b2Manifold*)oldManifold]];
    }

    /// This lets you inspect a contact after the solver is finished. This is useful
    /// for inspecting impulses.
    /// Note: the contact manifold does not include time of impact impulses, which can be
    /// arbitrarily large if the sub-step is small. Hence the impulse is provided explicitly
    /// in a separate data structure.
    /// Note: this is only called for contacts that are touching, solid, and awake.
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
    {
        [delegate postSolve:[SimContact contactWithB2:contact] impulse:[SimContactImpulse contactImpulseWithB2:(b2ContactImpulse*)impulse]];
    }
};                                                    

// queryAABB callback

class gsQueryCallback : public b2QueryCallback
{
public:
    void *block;
    ~gsQueryCallback() {}
    
    /// Called for each fixture found in the query AABB.
    /// @return false to terminate the query.
    bool ReportFixture(b2Fixture* fixture)
    {
        SimQueryCallback callback = (__bridge SimQueryCallback)block;
        return callback([SimFixture fixtureWithB2:fixture]);
    }
};

@implementation GameSimulatorConfig

- (id)copyWithZone:(NSZone *)zone
{
    GameSimulatorConfig *config = [[[self class] alloc] init];
    config.gravity = _gravity;
    config.timeStep = _timeStep;
    config.velocityIterations = _velocityIterations;
    config.positionIterations = _positionIterations;
    return config;
}

@end

@interface GameSimulator()

@property b2World *world;
@property gsContactListener *contactListener;

@end

@implementation GameSimulator

- (instancetype)initWithConfig:(GameSimulatorConfig*)config
{
    self = [super init];
    if(self != nil) {
        b2Vec2 vec2;
        write_CGPoint_to_b2Vec2(config.gravity, vec2);
        _world = new b2World(vec2);
        _simulationStep = 0;
        _timeStep = config.timeStep;
        _velocityIterations = config.velocityIterations;
        _positionIterations = config.positionIterations;
    }
    return self;
}

- (void)dealloc
{
    if(_contactListener != NULL)
        delete _contactListener;
    delete _world;
}

- (void)removeBody:(SimBody*)body
{
    _world->DestroyBody(body.body);
}

- (SimBody*)addObject:(Object*)object
{
    // body
    b2BodyDef bodyDef;
    b2FixtureDef fixtureDef;
    b2PolygonShape box;
    b2Body *body;
    bodyDef.userData = (__bridge void *)object;
    [self setObjectDynamicData:object bodyDef:&bodyDef fixtureDef:&fixtureDef polygonShape:&box];
    body = _world->CreateBody(&bodyDef);
    body->CreateFixture(&fixtureDef);
    return [SimBody bodyWithB2:body];
}

- (void)setObjectDynamicData:(Object*)object bodyDef:(b2BodyDef*)bodyDef fixtureDef:(b2FixtureDef*)fixtureDef polygonShape:(b2PolygonShape*)polygonShape
{
    bodyDef->fixedRotation = object.bodyFixedRotation;
    bodyDef->type = (b2BodyType)object.bodyType;
    bodyDef->bullet = false;
    bodyDef->active = object.physicsActive;
    write_CGPoint_to_b2Vec2(object.position, bodyDef->position);
    bodyDef->angle = (float32)object.angle;
    
    [self setShape:polygonShape object:object];

    fixtureDef->shape = polygonShape;
    fixtureDef->density = object.density;
    fixtureDef->friction = object.friction;
    fixtureDef->isSensor = object.isSensor;
}

- (void)setShape:(b2PolygonShape*)polygonShape object:(Object*)object
{
    // set box
    CGFloat hw = object.size.width / 2.0 * object.scale.x;
    CGFloat hh = object.size.height / 2.0 * object.scale.y;
    b2Vec2 vec2 = b2Vec2(hw - object.origin.x, hh - object.origin.y);
    polygonShape->SetAsBox(hw, hh, vec2, 0.0);
}

- (void)step
{
    _world->Step((float32)_timeStep, (int32)_velocityIterations, (int32)_positionIterations);
    _simulationStep++;
}

- (void)queryForBound:(Bound*)bound callback:(SimQueryCallback)callback {
    b2AABB aabb;
    write_Bound_to_b2AABB(*bound, aabb);
    gsQueryCallback queryCallback;
    queryCallback.block = (__bridge void*)callback;
    _world->QueryAABB(&queryCallback, aabb);
}

- (void)updateObject:(Object*)object withBody:(SimBody*)bdy
{
    b2Body *body = bdy.body;
    b2Vec2 vec2 = body->GetPosition();
    CGPoint point;
    write_b2Vec_to_CGPoint(vec2, point);
    object.position = point;
    object.angle = (CGFloat)body->GetAngle();
}

- (void)setContactDelegate:(id<SimContactDelegate>)contactDelegate
{
    _contactDelegate = contactDelegate;
    if(_contactDelegate == nil) {
        if(_contactListener != NULL) {
            delete _contactListener;
            _contactListener = NULL;
        }
        _world->SetContactListener(NULL);
    } else {
        _contactListener = new gsContactListener();
        _contactListener->delegate = _contactDelegate;
        _world->SetContactListener(_contactListener);
    }
}

@end
