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


#import "StandardMenuLayer.h"
#import "GameManager.h"
#import "GlitchCentral.h"

@implementation StandardMenuLayer

- (id)init
{
    self = [super init];
    if (self) 
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        if ([[GlitchCentral sharedInstance] isAuthenticated])
        {
            CCSprite *playButton = [CCSprite spriteWithSpriteFrameName:@"PlayButton"];
            CCSprite *playButtonActive = [CCSprite spriteWithSpriteFrameName:@"PlayButtonActive"];
            
            CCMenuItem *playMenuItem = [CCMenuItemSprite itemFromNormalSprite:playButton selectedSprite:playButtonActive target:self selector:@selector(playButtonPressed:)];
            
            playMenuItem.position = CGPointMake(screenSize.width - 125, 130);
            
            CCSprite *unauthButton = [CCSprite spriteWithSpriteFrameName:@"SignOutButton"];
            CCSprite *unauthButtonActive = [CCSprite spriteWithSpriteFrameName:@"SignOutButtonActive"];
            
            CCMenuItem *unauthMenuItem = [CCMenuItemSprite itemFromNormalSprite:unauthButton selectedSprite:unauthButtonActive target:self selector:@selector(unauthButtonPressed:)];
            
            unauthMenuItem.position = CGPointMake(35, 16);
            
            CCMenu *mainMenu = [CCMenu menuWithItems:playMenuItem, unauthMenuItem, nil];
            mainMenu.position = CGPointZero;
            [self addChild:mainMenu];        
        }
        else
        {
            CCSprite *authButton = [CCSprite spriteWithSpriteFrameName:@"SignInButton"];
            CCSprite *authButtonActive = [CCSprite spriteWithSpriteFrameName:@"SignInButtonActive"];
            
            CCMenuItem *authMenuItem = [CCMenuItemSprite itemFromNormalSprite:authButton selectedSprite:authButtonActive target:self selector:@selector(authButtonPressed:)];
            
            authMenuItem.position = CGPointMake(screenSize.width/2, screenSize.height/2);
            
            CCMenu *mainMenu = [CCMenu menuWithItems:authMenuItem, nil];
            mainMenu.position = CGPointZero;
            [self addChild:mainMenu];

        }
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

-(void)authButtonPressed:(id)sender
{
    [[GlitchCentral sharedInstance] authenticate];
}

@end
