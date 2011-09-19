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


#define kTinyAmount 0.001
#define kModestAmount 0.2

#import "GlitchAvatarSprite.h"
#import "Constants.h"

@interface GlitchAvatarSprite ()

@property (retain, nonatomic) GlitchAvatarData *avatarData;
@property (retain, nonatomic) CCAction *currentAction;

@end

@implementation GlitchAvatarSprite

@synthesize avatarData = _avatarData;
@synthesize currentAnimationType = _currentAnimationType;
@synthesize currentAction = _currentAction;
@synthesize avatarState = _avatarState;

+(id)spriteWithAvatarData:(GlitchAvatarData *)data
{
    return [[GlitchAvatarSprite alloc] initWithAvatarData:data];
}

-(id)initWithAvatarData:(GlitchAvatarData *)data
{
    self = [super initWithTexture:[data defaultTexture]];
    if (self) 
    {
        self.avatarData = data;
    }
    
    return self;
}

-(void)dealloc
{
    [_avatarData release];
    _avatarData = nil;
    
    [_currentAction release];
    _currentAction = nil;
    
    [super dealloc];
}

-(void)setBody:(b2Body *)body
{
    [super setBody:body];
    
    // Add a sensor
    b2PolygonShape sensor;
    sensor.SetAsBox(self.contentSize.width/2/PTM_RATIO,
                   self.contentSize.height/2/PTM_RATIO);
    sensor.m_centroid = b2Vec2(sensor.m_centroid.x, sensor.m_centroid.y - (self.contentSize.height/2/PTM_RATIO/20));

	b2FixtureDef sensorDef;
    sensorDef.shape = &sensor;
    sensorDef.isSensor = true;
    body->CreateFixture(&sensorDef);
}

-(NSString *)animationNameForType:(GlitchAvatarAnimationType)animationType
{
    NSString *animationName = @"";
    switch (animationType) 
    {
        case GlitchAvatarAnimationTypeIdle:
            animationName = @"idle4";
            break;
            
        case GlitchAvatarAnimationTypeIdle0:
            animationName = @"idle0";
            break;
            
        case GlitchAvatarAnimationTypeIdle1:
            animationName = @"idle1";
            break;
            
        case GlitchAvatarAnimationTypeIdle2:
            animationName = @"idle2";
            break;
            
        case GlitchAvatarAnimationTypeIdle3:
            animationName = @"idle3";
            break;
            
        case GlitchAvatarAnimationTypeIdle4:
            animationName = @"idle4";
            break;
            
        case GlitchAvatarAnimationTypeIdleSleepyStart:
            animationName = @"idleSleepyStart";
            break;
            
        case GlitchAvatarAnimationTypeIdleSleepyLoop:
            animationName = @"idleSleepyLoop";
            break;
            
        case GlitchAvatarAnimationTypeIdleSleepyEnd:
            animationName = @"idleSleepyEnd";
            break;
            
        case GlitchAvatarAnimationTypeWalk1x:
            animationName = @"walk1x";
            break;
            
        case GlitchAvatarAnimationTypeWalk2x:
            animationName = @"walk2x";
            break;
            
        case GlitchAvatarAnimationTypeWalk3x:
            animationName = @"walk3x";
            break;
            
        case GlitchAvatarAnimationTypeJumpOverLift:
            animationName = @"jumpOver_lift";
            break;
            
        case GlitchAvatarAnimationTypeJumpOverFall:
            animationName = @"jumpOver_fall";
            break;
            
        case GlitchAvatarAnimationTypeJumpOverLand:
            animationName = @"jumpOver_land";
            break;
            
        case GlitchAvatarAnimationTypeHit1:
            animationName = @"hit1";
            break;
            
        case GlitchAvatarAnimationTypeHit2:
            animationName = @"hit2";
            break;
            
        case GlitchAvatarAnimationTypeClimb:
            animationName = @"climb";
            break;
            
        case GlitchAvatarAnimationTypeAngry:
            animationName = @"angry";
            break;
            
        case GlitchAvatarAnimationTypeHappy:
            animationName = @"happy";
            break;
            
        case GlitchAvatarAnimationTypeSurprise:
            animationName = @"surprise";
            break;
            
        default:
            // If we were passed something we don't know about, we'll just laze about...
            animationName = @"idle4";
            break;
    }
    
    return animationName;
}

-(void)stopCurrentAction
{
    if (self.currentAction) 
    {
        [self stopAction:self.currentAction];
        self.currentAction = nil;
    }
}

-(CCAnimate *)animateActionForAnimationType:(GlitchAvatarAnimationType)animationType
{
    NSString *animationName = [self animationNameForType:animationType];
    CCAnimation *animation = [self.avatarData animationForName:animationName];
    ccTime duration = [animation.frames count] * (1.0/30);  // 30 FPS
    return [CCAnimate actionWithDuration:duration animation:animation restoreOriginalFrame:NO];
}

-(void)showAnimation:(GlitchAvatarAnimationType)animationType
{
    [self showAnimation:animationType withRepeat:NO];
}

-(void)showAnimation:(GlitchAvatarAnimationType)animationType withRepeat:(BOOL)repeat
{
    [self stopCurrentAction];
    CCAnimate *animateAction = [self animateActionForAnimationType:animationType];
    CCAction *action = (repeat ? [CCRepeatForever actionWithAction:animateAction] : animateAction);
    [self runAction:action];
    self.currentAction = action;
    _currentAnimationType = animationType;    
}

-(void)showAnimation:(GlitchAvatarAnimationType)animationType withCompletionBlock:(void(^)(void))animationComplete
{
    [self stopCurrentAction];
    CCAnimate *animateAction = [self animateActionForAnimationType:animationType];
    CCAction *blockAction = [CCCallBlock actionWithBlock:animationComplete];
    CCAction *sequence = [CCSequence actions:animateAction, blockAction, nil];
    
    [self runAction:sequence];
    self.currentAction = sequence;
    _currentAnimationType = animationType;    
}

-(void)switchToState:(GlitchAvatarState)state
{
    if (self.avatarState != state)
    {
        switch (state) 
        {
            case GlitchAvatarStateIdle:
                NSLog(@"Show animation: Idle");
                [self showAnimation:GlitchAvatarAnimationTypeIdle withRepeat:YES];
                break;

            case GlitchAvatarStateRunning:
                NSLog(@"Show animation: Running, Old animation: %i",self.avatarState);
                [self showAnimation:GlitchAvatarAnimationTypeWalk2x withRepeat:YES];
                break;
                
            case GlitchAvatarStateJumpingUp:
                NSLog(@"Show animation: JumpOverLift");
                [self showAnimation:GlitchAvatarAnimationTypeJumpOverLift withRepeat:NO];
                break;
                
            case GlitchAvatarStateJumpingDown:
                NSLog(@"Show animation: JumpOverFall");
                [self showAnimation:GlitchAvatarAnimationTypeJumpOverFall withRepeat:NO];
                break;
                
            case GlitchAvatarStateLanding:
                NSLog(@"Show animation: Landing");
                [self showAnimation:GlitchAvatarAnimationTypeJumpOverLand withRepeat:NO];
                break;
                
            case GlitchAvatarStateCrashed:
                NSLog(@"Show animation: Crashed");
                [self showAnimation:GlitchAvatarAnimationTypeHit1 withRepeat:YES];
                break;
                
            default:
                NSLog(@"Show animation: Idle");
                [self showAnimation:GlitchAvatarAnimationTypeIdle withRepeat:YES];
                break;
        }
        _avatarState = state;
    }
}

// Various action methods
-(void)idle
{
    if (self.avatarState != GlitchAvatarStateIdle)
    {
        GlitchAvatarAnimationType animationType = GlitchAvatarAnimationTypeIdle4;
        if (self.avatarState == GlitchAvatarStateManual)
        {
            // Choose randomly
            int n = arc4random() % 16;
            switch (n) 
            {
                case 1:
                case 2:
                    animationType = GlitchAvatarAnimationTypeIdle1;
                    break;
                    
                case 3:
                case 4:
                    animationType = GlitchAvatarAnimationTypeIdle2;
                    break;
                    
                case 5:
                    animationType = GlitchAvatarAnimationTypeIdle3;
                    break;
                    
                default:
                    animationType = GlitchAvatarAnimationTypeIdle4;
                    break;
            }
        }
        
        _avatarState = GlitchAvatarStateIdle;
        [self stopCurrentAction];
        [self showAnimation:animationType withCompletionBlock:^(void) 
        {
            _avatarState = GlitchAvatarStateManual;
            [self idle];
        }];
    }
}

-(void)jumpUp
{
    [self switchToState:GlitchAvatarStateJumpingUp];
}

-(void)jumpUpAndWhenComplete:(void(^)(void))jumpComplete
{
    _avatarState = GlitchAvatarStateManual;
    [self showAnimation:GlitchAvatarAnimationTypeJumpOverLift withCompletionBlock:jumpComplete];
}

-(void)jumpDown
{
    [self switchToState:GlitchAvatarStateJumpingDown];
}

-(void)jumpDownAndWhenComplete:(void(^)(void))jumpComplete
{
    _avatarState = GlitchAvatarStateManual;
    [self showAnimation:GlitchAvatarAnimationTypeJumpOverFall withCompletionBlock:jumpComplete];
}

-(void)land
{
    [self switchToState:GlitchAvatarStateLanding];
}

-(void)landAndWhenComplete:(void(^)(void))landComplete
{
    _avatarState = GlitchAvatarStateManual;
    [self showAnimation:GlitchAvatarAnimationTypeWalk2x withCompletionBlock:landComplete];
}

-(void)run
{
    [self switchToState:GlitchAvatarStateRunning];
}

-(void)crash
{
    [self switchToState:GlitchAvatarStateCrashed];
}

-(void)animateBasedOnVelocity
{
    b2Vec2 v = self.body->GetLinearVelocity();

    if (onGround && fabs(v.x) < kTinyAmount && fabs(v.y) < kTinyAmount)
    {
        [self idle];
    }   
    else if (onGround && fabs(v.x) > kTinyAmount)
    {
        [self run];
    }
    else if (v.y > kModestAmount)
    {
        [self jumpUp];
    }
    else if (v.y < kModestAmount)
    {
        [self landAndWhenComplete:^(void) 
        {
            [self run];
        }];
    }    
    else
    {
        // Keep doing whatever we were doing until something changes. 
    }
}

-(void)decideJumperAnimation
{
    b2Vec2 v = self.body->GetLinearVelocity();
    
    switch (self.avatarState)
    {
        case GlitchAvatarStateIdle:
        case GlitchAvatarStateRunning:
            [self animateBasedOnVelocity];
            break;
            
        case GlitchAvatarStateJumpingUp:
            if (onGround)
            {
                // We must have landed somewhere
                // [self run];
            }
            else
            {
                if (v.y < -kModestAmount)
                {
                    // We've started falling
                    [self jumpDown];
                }
                // otherwise leave as is
            }
            break;
            
        case GlitchAvatarStateJumpingDown:
            if (onGround)
            {
                NSLog(@"Landed");
                // We've landed
                [self landAndWhenComplete:^(void) 
                {
                    NSLog(@"Run");
                    [self run];
                }];
            }
            break;
            
        case GlitchAvatarStateLanding:
        case GlitchAvatarStateCrashed:
        default:
            // Nothing until told otherwise
            break;
    }
}

-(BOOL)canJump
{
    return onGround;
}

-(void)beginContact:(b2Contact *)contact
{
    b2Body *me = self.body;
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();

    if ((bodyA == me || bodyB == me))
    {
        if (contact->IsTouching())
        {
            b2WorldManifold worldManifold;
            contact->GetWorldManifold(&worldManifold);
            
            b2Vec2 normal = worldManifold.normal;
            
            if (bodyA == me)
            {
                normal = b2Vec2(-normal.x, -normal.y);
            }
            
            // Simplistic approach
            if (normal.y > normal.x)
            {
                onGround = YES;
            }
        }
    }
}

-(void)endContact:(b2Contact *)contact
{
    onGround = NO;
}

-(void)preSolve:(b2Contact *)contact manifold:(b2Manifold *)oldManifold
{
    
}

-(void)postSolve:(b2Contact *)contact impulse:(b2ContactImpulse *)impulse
{
    
}

@end
