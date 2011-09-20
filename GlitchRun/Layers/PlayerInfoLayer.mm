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


#import "PlayerInfoLayer.h"
#import "GlitchCentral.h"
#import "GameManager.h"
#import "GlitchAvatarSprite.h"
#import "CCSprite(Glitch).h"

@implementation PlayerInfoLayer

- (id)init
{
    self = [super init];
    if (self) 
    {
        GlitchAvatarSprite *avatar = [GlitchAvatarSprite spriteWithAvatarData:[[GlitchCentral sharedInstance] avatarData]];
        
        CGSize avatarSize = avatar.scaledContentSize; 
        CGPoint pos = ccp(120, 70 + avatarSize.height/2);
        CGPoint ap = avatar.anchorPoint;
        CCLOG(@"Anchor point: %.2f, %.2f", ap.x, ap.y);
        CGPoint app = avatar.anchorPointInPixels;
        CCLOG(@"Anchor point pixels: %.2f, %.2f", app.x, app.y);
        avatar.position = pos;
        [self addChild:avatar];
        [avatar idle];
    }
    
    return self;
}

-(void)playButtonPressed:(id)sender
{
    [[GameManager sharedGameManager] runScene:GameSceneRun];
}

-(void)unauthButtonPressed:(id)sender
{
    [[GlitchCentral sharedInstance] logout];
   [[GameManager sharedGameManager] runScene:GameScenePlayerInfo];
}

@end
