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


#import "ErrorLayer.h"
#import "GameManager.h"
#import "GlitchCentral.h"


@implementation ErrorLayer

- (id)init
{
    self = [super init];
    if (self) 
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];

        NSString *fntFile = @"GlitchMain.fnt";
        
        CCLabelBMFont *loadingLabel1 = [CCLabelBMFont labelWithString:@"There was a problem contacting"  fntFile:fntFile];
        loadingLabel1.position = ccp(screenSize.width/2, screenSize.height/2 + 30);
        [self addChild:loadingLabel1];

        CCLabelBMFont *loadingLabel2 = [CCLabelBMFont labelWithString:@"the Glitch servers"  fntFile:fntFile];
        loadingLabel2.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:loadingLabel2];

        
        CCSprite *tryAgainButton = [CCSprite spriteWithSpriteFrameName:@"TryAgainButton"];
        CCSprite *tryAgainButtonActive = [CCSprite spriteWithSpriteFrameName:@"TryAgainButtonActive"];

        CCMenuItem *tryAgainMenuItem = [CCMenuItemSprite itemFromNormalSprite:tryAgainButton 
                                                               selectedSprite:tryAgainButtonActive 
                                                                       target:self 
                                                                     selector:@selector(tryAgainButtonPressed:)];
        
        tryAgainMenuItem.position = CGPointMake(screenSize.width/2, screenSize.height/2 - 30);
        
        CCMenu *mainMenu = [CCMenu menuWithItems:tryAgainMenuItem, nil];
        mainMenu.position = CGPointZero;
        [self addChild:mainMenu];
    }
    
    return self;
}


-(void)tryAgainButtonPressed:(id)sender
{
    GameSceneId sceneId = ([[GlitchCentral sharedInstance] isAuthenticated]) ? GameSceneLoading : GameScenePlayerInfo;    
	[[GameManager sharedGameManager] runScene:sceneId];
}


@end
