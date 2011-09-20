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


#import "ResultsLayer.h"
#import "GameManager.h"
#import "GlitchCentral.h"
#import "GlitchAvatarSprite.h"

@implementation ResultsLayer

- (id)init
{
    self = [super init];
    if (self) 
    {
        NSString *fntFile = @"GlitchMain.fnt";
        CGSize screenSize = [[CCDirector sharedDirector] winSize];

        float score = [GameManager sharedGameManager].lastDistanceRan;
        float hiscore = [GameManager sharedGameManager].hiScore;
        
        if (score > hiscore)
        {
            [GameManager sharedGameManager].hiScore = score;
            //CCLabelBMFont *newHighScoreLabel = [CCLabelBMFont labelWithString:@"New high score!"  fntFile:fntFile];
            //newHighScoreLabel.position = ccp(20 + newHighScoreLabel.contentSize.width/2,  screenSize.height - 40); 
            //[self addChild:newHighScoreLabel];
            hiscore = score;
            
        }
        
        CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"You ran: %.2fm", score]  fntFile:fntFile];
        scoreLabel.anchorPoint=ccp(0, 0);
        scoreLabel.position = ccp(screenSize.width/2 + 15,  185); 
        [self addChild:scoreLabel];
        
        CCLabelBMFont *hiScoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"High score: %.2fm", hiscore] fntFile:fntFile];
        hiScoreLabel.anchorPoint=ccp(0, 0);
        hiScoreLabel.position = ccp(screenSize.width/2 + 15,  155); 
        [self addChild:hiScoreLabel];
        
        GlitchAvatarSprite *avatar = [GlitchAvatarSprite spriteWithAvatarData:[[GlitchCentral sharedInstance] avatarData]];
        
        CGPoint pos = ccp(63, 70);
        [self addChild:avatar];
        avatar.position = pos;
        
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
