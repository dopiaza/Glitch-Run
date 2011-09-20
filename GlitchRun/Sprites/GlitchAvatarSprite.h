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


#import "Box2DSprite.h"
#import "GlitchAvatarData.h"
#import "Box2DContactListener.h"

typedef enum
{
    GlitchAvatarAnimationTypeIdle = 1,
    GlitchAvatarAnimationTypeIdle0,
    GlitchAvatarAnimationTypeIdle1,
    GlitchAvatarAnimationTypeIdle2,
    GlitchAvatarAnimationTypeIdle3,
    GlitchAvatarAnimationTypeIdle4,
    GlitchAvatarAnimationTypeIdleSleepyStart,
    GlitchAvatarAnimationTypeIdleSleepyLoop,
    GlitchAvatarAnimationTypeIdleSleepyEnd,
    GlitchAvatarAnimationTypeWalk1x,
    GlitchAvatarAnimationTypeWalk2x,
    GlitchAvatarAnimationTypeWalk3x,
    GlitchAvatarAnimationTypeJumpOverLift,
    GlitchAvatarAnimationTypeJumpOverFall,
    GlitchAvatarAnimationTypeJumpOverLand,
    GlitchAvatarAnimationTypeHit1,
    GlitchAvatarAnimationTypeHit2,
    GlitchAvatarAnimationTypeClimb,
    GlitchAvatarAnimationTypeAngry,
    GlitchAvatarAnimationTypeHappy,
    GlitchAvatarAnimationTypeSurprise    
} GlitchAvatarAnimationType;


typedef enum
{
    GlitchAvatarStateIdle = 1,
    GlitchAvatarStateManual, // 2
    GlitchAvatarStateRunning, // 3
    GlitchAvatarStateJumpingUp, // 4
    GlitchAvatarStateJumpingDown, // 5
    GlitchAvatarStateLanding, // 6
    GlitchAvatarStateCrashed // 7
    
} GlitchAvatarState;


@interface GlitchAvatarSprite : Box2DSprite
<Box2DContactDelegate>
{
    BOOL onGround;
}

+(id)spriteWithAvatarData:(GlitchAvatarData *)data;

-(id)initWithAvatarData:(GlitchAvatarData *)data;

-(GlitchAvatarData *)avatarData;

-(void)showAnimation:(GlitchAvatarAnimationType)animationType;
-(void)showAnimation:(GlitchAvatarAnimationType)animationType withRepeat:(BOOL)repeat;

-(void)idle;
-(void)jumpUp;
-(void)jumpDown;
-(void)land;
-(void)run;
-(void)crash;

-(void)decideJumperAnimation;
-(BOOL)canJump;


@property (readonly, nonatomic) GlitchAvatarAnimationType currentAnimationType;
@property (readonly, nonatomic) GlitchAvatarState avatarState;
@property (assign, nonatomic) BOOL isRetina;

// TODO Inconsistencies in behaviour when setting position of avatar sprite
// Use this flag to work around it for now. 
@property (assign, nonatomic) BOOL needsPositionAdjust;

@end
