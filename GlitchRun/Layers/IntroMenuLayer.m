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


#import "IntroMenuLayer.h"
#import "GameManager.h"


@implementation IntroMenuLayer

- (id)init
{
    self = [super init];
    if (self) 
    {
        CCMenuItem *playButton = [CCMenuItemImage 
                                  itemFromNormalImage:@"PlayButton.png" selectedImage:@"PlayButtonActive.png" 
                                  target:self selector:@selector(playButtonPressed:)];
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        playButton.position = CGPointMake(screenSize.width/2, screenSize.height/2);
        
        CCMenu *mainMenu = [CCMenu menuWithItems:playButton, nil];
        mainMenu.position = CGPointZero;
        [self addChild:mainMenu];
    }
    
    return self;
}


-(void)playButtonPressed:(id)sender
{
    [[GameManager sharedGameManager] runScene:GameSceneRun];
}


@end
