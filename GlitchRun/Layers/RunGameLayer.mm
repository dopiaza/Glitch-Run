//
// Glitch Run
//
// Copyright 2011 Tiny Speck, Inc.
// Created by David Wilkinson.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License. 
//
// See more about Glitch at http://www.glitch.com
// http://www.tinyspeck.com
//


#import "GlitchCentral.h"
#import "GameManager.h"
#import "RunGameLayer.h"
#import "Constants.h"
#import "GlitchAvatarSprite.h"
#import "GB2ShapeCache.h"
#import "CCSprite(Glitch).h"

typedef enum
{
    GameStateNotStarted = 1,
    GameStateRunning,
    GameStateCrashed,
    GameStateGameOver
    
} GameState;


@interface RunGameLayer ()

-(void)createBodyAtLocation:(b2Vec2)location 
                       type:(b2BodyType)type
                  forSprite:(Box2DSprite *)sprite 
              fromShapeName:(NSString *)shapeName;

-(void)createBodyAtLocation:(b2Vec2)location 
                       type:(b2BodyType)type
                  forSprite:(Box2DSprite *)sprite 
                   friction:(float32)friction 
                restitution:(float32)restitution 
                    density:(float32)density 
                      isBox:(BOOL)isBox;

-(void)updateObstacles;
-(CGPoint)convertWorldToScreen:(b2Vec2)worldPos;
-(void)setStatusLabelText:(NSString *)text;
-(void)idle;
-(void)jumpUp;
-(void)jumpDown;
-(void)land;
-(void)run;
-(void)crash;


@property (retain, nonatomic) GlitchAvatarSprite *jumper;
@property (assign, nonatomic) float32 jumperOffset;
@property (assign, nonatomic) b2Body *ground;
@property (assign, nonatomic) ccTime jumpRequest;
@property (retain, nonatomic) NSMutableArray *obstacles;
@property (assign, nonatomic) float32 minDistanceToNextObstacle;
@property (assign, nonatomic) float32 variantDistanceToNextObstacle;
@property (assign, nonatomic) float32 maxLinearVelocity;
@property (assign, nonatomic) float32 lastObstacleLocation;
@property (retain, nonatomic) CCLabelBMFont *statusLabel;
@property (assign, nonatomic) GameState gameState;
@property (retain, nonatomic) CCParticleSystem *dazed;

@end


@implementation RunGameLayer

@synthesize jumper = _jumper;
@synthesize jumperOffset = _jumperOffset;
@synthesize ground = _ground;
@synthesize jumpRequest = _jumpRequest;
@synthesize obstacles = _obstacles;
@synthesize minDistanceToNextObstacle = _minDistanceToNextObstacle;
@synthesize variantDistanceToNextObstacle = _variantDistanceToNextObstacle;
@synthesize maxLinearVelocity = _maxLinearVelocity;
@synthesize lastObstacleLocation = _lastObstacleLocation;
@synthesize statusLabel = _statusLabel;
@synthesize gameState = _gameState;
@synthesize dazed = _dazed;

-(id)init
{
    self = [super init];
    if (self) 
    {
        self.gameState = GameStateNotStarted;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        self.obstacles = [NSMutableArray arrayWithCapacity:20];
        
        self.jumperOffset = screenSize.width/4;
        
        // Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		bool doSleep = true;
        world = new b2World(gravity, doSleep);
        world->SetContinuousPhysics(true);
        
        // Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
        groundBodyDef.type = b2_staticBody;
		
		self.ground = world->CreateBody(&groundBodyDef);
		
		// Define the ground box shape.
		b2PolygonShape groundBox;		
		
		// Define the ground as being a few screen widths wide, and we'll move it to follow us
        // That way, we'll never run out of space
        CGFloat w = screenSize.width * 5/PTM_RATIO;
		groundBox.SetAsEdge(b2Vec2(-w/2, 0.5), b2Vec2(w/2, 0.5));
		self.ground->CreateFixture(&groundBox, 0);
        
        self.jumper = [GlitchAvatarSprite spriteWithAvatarData:[[GlitchCentral sharedInstance] avatarData]];
        
        BOOL isRetina = [[GameManager sharedGameManager] retina];
        
        CGSize spriteSize = self.jumper.scaledContentSize; 
        float32 density = isRetina ? 40 : 10; // Retina is 4 x size of non-retina
        b2Vec2 jumperPos = b2Vec2(0, 0.6); 
        
        [self createBodyAtLocation:jumperPos
                              type:b2_dynamicBody
                         forSprite:self.jumper 
                          friction:0.02 
                       restitution:0.1 
                           density:density 
                             isBox:NO];
        
        b2Body *jumperBody = self.jumper.body;
        jumperBody->SetFixedRotation(YES);
        
        CGPoint screenPos = [self convertWorldToScreen:jumperPos];
        self.jumper.position = ccp(screenPos.x + spriteSize.width/2, screenPos.y + spriteSize.height/2);
        [self addChild:self.jumper z:20];
        [self idle];
        
        self.isTouchEnabled = YES;
        self.minDistanceToNextObstacle = 6.0;
        self.variantDistanceToNextObstacle = 10.0;
        self.maxLinearVelocity = 4.0;
        
        self.statusLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"GlitchRunStatus.fnt"];
        [self addChild:self.statusLabel z:100];
        [self setStatusLabelText:@"Touch screen to start"];
        
        contactListener = new Box2DContactListener(self);
        world->SetContactListener(contactListener);
    }
    
    return self;
}

-(void)dealloc
{
    [_jumper release];
    _jumper = nil;
    
    [_obstacles release];
    _obstacles = nil;
    
    [_statusLabel release];
    _statusLabel = nil;
    
    [_dazed release];
    _dazed = nil;
    
    if (contactListener)
    {
        world->SetContactListener(NULL);
        delete contactListener;
    }
    
    if (world)
    {
        delete world;
        world = NULL;   
    }
    
    [super dealloc];
}


-(CGFloat)jumperDistance
{
    b2Body *jumperBody = self.jumper.body;
    b2Vec2 position = jumperBody->GetPosition();
    return position.x;
}

-(void)setStatusLabelText:(NSString *)text
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [self.statusLabel setString:text];
    self.statusLabel.position = ccp(screenSize.width - self.statusLabel.contentSize.width/2 - 10,  screenSize.height - 20); 
}

- (void)createBodyAtLocation:(b2Vec2)location 
                        type:(b2BodyType)type
                   forSprite:(Box2DSprite *)sprite 
                    friction:(float32)friction 
                 restitution:(float32)restitution 
                     density:(float32)density 
                       isBox:(BOOL)isBox
{
    b2BodyDef bodyDef;
    bodyDef.type = type;
    bodyDef.position = location;
    bodyDef.allowSleep = false;
    
    b2Body *body = world->CreateBody(&bodyDef); 
    body->SetUserData(sprite);
    sprite.body = body;
    
    b2FixtureDef fixtureDef;
    if (isBox) 
    {
        b2PolygonShape shape;
        shape.SetAsBox(sprite.contentSize.width/2/PTM_RATIO,
                       sprite.contentSize.height/2/PTM_RATIO);
        fixtureDef.shape = &shape;
    } 
    else 
    {
        b2CircleShape shape;
        shape.m_radius = sprite.contentSize.width/2/PTM_RATIO;
        fixtureDef.shape = &shape;
    }
    
    fixtureDef.density = density;
    fixtureDef.friction = friction;
    fixtureDef.restitution = restitution;
    body->CreateFixture(&fixtureDef);
}

- (void)createBodyAtLocation:(b2Vec2)location 
                        type:(b2BodyType)type
                   forSprite:(Box2DSprite *)sprite 
               fromShapeName:(NSString *)shapeName 
{
    b2BodyDef bodyDef;
    bodyDef.type = type;
    bodyDef.position = location;
    bodyDef.allowSleep = false;
    
    b2Body *body = world->CreateBody(&bodyDef); 
    body->SetUserData(sprite);
    sprite.body = body;
    
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:shapeName];
    [sprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:shapeName]];
}

-(void) update:(ccTime)deltaTime
{ 
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    GameState state = self.gameState;
    
    b2Body *jumperBody = self.jumper.body;
    b2Vec2 jumperPosition = jumperBody->GetPosition();
    CGFloat jumperX = jumperPosition.x;
    
    int32 velocityIterations = 8;
    int32 positionIterations = 2;
    
    // Pending jump?
    if (state == GameStateRunning && self.jumpRequest > 0)
    {
        // There is a pending jump. Decrement the timer.
        self.jumpRequest = self.jumpRequest - deltaTime;
        if ([self.jumper canJump])
        {
            [self performSelectorOnMainThread:@selector(jumpUp) withObject:nil waitUntilDone:NO];
            self.jumpRequest = -1;
        }
    }
    
    if (state == GameStateNotStarted)
    {
        [self idle];
    }
    
    if (state != GameStateGameOver)
    {
        world->Step(deltaTime, velocityIterations, positionIterations);
        world->ClearForces();
        
        for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
        {
            if (b->GetUserData() != NULL) 
            {
                CCSprite *ccs = (CCSprite*)b->GetUserData();
                // We're moving our frame of reference to keep the jumper in the same position on screen
                float yAdjust =  (b == jumperBody) ? 8.0 : 0.0;
                b2Vec2 bPos = b->GetPosition();
                ccs.position = CGPointMake( (bPos.x - jumperX) * PTM_RATIO + screenSize.width/2 - self.jumperOffset, bPos.y * PTM_RATIO + yAdjust);
                ccs.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }	
        }
        // Adjust the ground to stay beneath our feet
        b2Vec2 pos = b2Vec2(jumperX - (screenSize.width/2 - self.jumperOffset)/PTM_RATIO, 0);
        self.ground->SetTransform(pos, self.ground->GetAngle());
    }
    
    // Keep on movin'
    if (self.gameState == GameStateRunning)
    {
        b2Vec2 v = jumperBody->GetLinearVelocity();
        BOOL canJump = [self.jumper canJump];
        
        if (v.x < self.maxLinearVelocity && canJump)
        {
            b2Vec2 impulse = b2Vec2(0.6, 0);
            b2Vec2 bodyCenter = jumperBody->GetWorldCenter();
            jumperBody->ApplyLinearImpulse(impulse, bodyCenter);  
            v = jumperBody->GetLinearVelocity();
        }
        
        [self updateObstacles];
        
        if (v.x <= 0.0 && self.jumperDistance > 0.01)
        {
            // We've stopped or are going backwards
            [self crash];
        }
        else
        {
            [self.jumper decideJumperAnimation];
        }
    }
    
    if (self.gameState != GameStateNotStarted)
    {
        [self setStatusLabelText:[NSString stringWithFormat:@"Distance: %.2fm", self.jumperDistance]];
    }
}


-(void)idle
{
    [self.jumper idle];
}
 
-(void)jumpUp
{
    CCLOG(@"Jump!");
    b2Body *jumperBody = self.jumper.body;
    
    b2Vec2 impulse = b2Vec2(0.8, 30.0);
    b2Vec2 bodyCenter = jumperBody->GetWorldCenter();
    jumperBody->ApplyLinearImpulse(impulse, bodyCenter); 
    [self.jumper jumpUp];
}
 
-(void)jumpDown
{
    [self.jumper jumpDown];
}
         
-(void)land
{
    [self.jumper land];
}
         
-(void)run
{
    [self.jumper run];
}

-(void)crash
{
    CCLOG(@"CRASH!");
    self.gameState = GameStateCrashed;
    [self performSelector:@selector(gameOver) withObject:nil afterDelay:2.0];
    [self.jumper crash];
    self.dazed = [CCParticleSystemQuad particleWithFile:@"Stars.plist"];
    CGPoint dazedPos = ccpAdd(self.jumper.position, ccp(0, self.jumper.scaledContentSize.height/2));
    self.dazed.position = dazedPos;
    [self addChild:self.dazed z:30];
}

 
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    switch (self.gameState)
    {
        case GameStateNotStarted:
            self.gameState = GameStateRunning;
            break;
            
        case GameStateRunning:
            if ([self.jumper canJump])
            {
                [self jumpUp];
            }
            else
            {
                // If we're not quite on the ground when the user taps the screen, we buffer the jump request
                // and jump when we land - this makes the game feel more responsive
                self.jumpRequest = kJumpBufferTime;
            }
            break;
            
        case GameStateCrashed:
            // Do nothing
            break;
            
        case GameStateGameOver:
            [[GameManager sharedGameManager] runScene:GameSceneResults];
            break;
    }
    
	return YES;
}

-(void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

// TODO break obstacles out into separate class         
/*
 * Dispose of old obstacles and determine whether to add a new one.
 */
-(void)updateObstacles
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    b2Body *jumperBody = self.jumper.body;
    b2Vec2 jumperPosition = jumperBody->GetPosition();
    float32 jumperX = jumperPosition.x;
    BOOL obstacleDestroyed = NO;
    
    while ([self.obstacles count] > 0)
    {
        Box2DSprite *sprite = [self.obstacles objectAtIndex:0];
        b2Vec2 pos = sprite.body->GetPosition();
        if (jumperX - pos.x > 2 * screenSize.width / PTM_RATIO)  // More than a couple of screen widths away, we can dispose of it
        {
            world->DestroyBody(sprite.body);
            [self removeChild:sprite cleanup:YES];
            [self.obstacles removeObject:sprite];
            obstacleDestroyed = YES;
        }
        else
        {
            // They're all closer from here on
            break;
        }
    }
    
    // And do we need a new one?
    if ([self.obstacles count] < 20) // Throttle the number of obstacles we have on the go at any one time
    {
        //Create a new obstacle
        NSString *obstacleName = @"Piggy";
        switch (arc4random() % 5)
        {
            case 0:
                obstacleName = @"Piggy";
                break;
                
            case 1: 
                obstacleName = @"Shrine";
                break;
                
            case 2: 
                obstacleName = @"Rock";
                break;
                
            case 3: 
                obstacleName = @"TreeTrunk";
                break;
                
            case 4: 
                obstacleName = @"Gravestone";
                break;
        }
        
        Box2DSprite *obstacle = [Box2DSprite spriteWithSpriteFrameName:obstacleName];
        CGSize spriteSize = obstacle.contentSize;
        
        float32 newX = self.lastObstacleLocation + self.minDistanceToNextObstacle + ((float32)(arc4random() % (int)(self.variantDistanceToNextObstacle * 100)))/100;
        b2Vec2 pos = b2Vec2(newX, 0.5);
        CGPoint screenPos = [self convertWorldToScreen:pos];
        
        obstacle.position = ccp(screenPos.x + spriteSize.width/2, screenPos.y + spriteSize.height/2);
        [self addChild:obstacle z:10];
        [self.obstacles addObject:obstacle];
        
        [self createBodyAtLocation:pos
                              type:b2_staticBody
                         forSprite:obstacle 
                     fromShapeName:obstacleName];
        
        self.lastObstacleLocation = newX;
    }
    
    if (obstacleDestroyed)
    {
        // We've destroyed on obstacle
        // Update the parameters to make the game progressively harder with each obstacle
        if (self.variantDistanceToNextObstacle > 2)
        {
            self.variantDistanceToNextObstacle -= 0.5;
        }
        else
        {
            // We've reduced the variant part as much as we are prepared to go, so now reduce the minimum distance between obstacles
            if (self.minDistanceToNextObstacle > 2)
            {
                self.minDistanceToNextObstacle -= 0.2;                
            }
        }
        self.maxLinearVelocity += 0.05;
    }
}

-(void)gameOver
{
    CCLabelBMFont *gameOver = [CCLabelBMFont labelWithString:@"GAME OVER" fntFile:@"GlitchRunBig.fnt"];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    gameOver.position = ccp(screenSize.width/2,  screenSize.height - 100); 
    [self addChild:gameOver];
    self.gameState = GameStateGameOver;
    [GameManager sharedGameManager].lastDistanceRan = self.jumperDistance;
    [self.jumper idle];
    [self.dazed removeFromParentAndCleanup:YES];
    self.dazed = nil;
}

-(CGPoint)convertWorldToScreen:(b2Vec2)worldPos
{
    // Screen is drawn relative to the jumper
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    b2Body *jumperBody = self.jumper.body;
    b2Vec2 jumperPosition = jumperBody->GetPosition();
    float32 jumperX = jumperPosition.x;
    
    CGPoint screenPos = CGPointMake((worldPos.x - jumperX) * PTM_RATIO + screenSize.width/2 - self.jumperOffset, worldPos.y * PTM_RATIO);
    return screenPos;
}

-(void)beginContact:(b2Contact *)contact
{
    [self.jumper beginContact:contact];
}

-(void)endContact:(b2Contact *)contact
{
    [self.jumper endContact:contact];
}

-(void)preSolve:(b2Contact *)contact manifold:(b2Manifold *)oldManifold
{
    [self.jumper preSolve:contact manifold:oldManifold];
}

-(void)postSolve:(b2Contact *)contact impulse:(b2ContactImpulse *)impulse
{
    [self.jumper postSolve:contact impulse:impulse];
}


@end
