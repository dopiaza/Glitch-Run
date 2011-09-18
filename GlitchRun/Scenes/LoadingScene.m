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


#import "LoadingScene.h"
#import "LoadingLayer.h"
#import "GlitchMainBackgroundLayer.h"
#import "GameManager.h"
#import "GlitchCentral.h"


@interface LoadingScene ()

-(void)loadData;

@property (retain, nonatomic) LoadingLayer *loadingLayer;

@end



@implementation LoadingScene

@synthesize loadingLayer = _loadingLayer;

- (id)init
{
    self = [super init];
    if (self) 
    {
        GlitchMainBackgroundLayer *backgroundLayer = [GlitchMainBackgroundLayer node];
        [self addChild:backgroundLayer z:0];
        
        self.loadingLayer = [LoadingLayer node];
        [self addChild:self.loadingLayer z:1];
        [self loadData];
    }
    
    return self;
}

-(void)dealloc
{
    [_loadingLayer release];
    _loadingLayer = nil;
    
    [super dealloc];
}



-(void)loadData
{
    [[GlitchCentral sharedInstance] updatePlayerDataWithDelegate:self];
}


-(void)playerDataProgress:(NSString *)progressMessage
{
}

-(void)playerDataUpdated
{
    CCLOG(@"Player data updated");
    // Preload some animations
    GlitchAvatarData *data = [[GlitchCentral sharedInstance] avatarData];
    [data animationForName:@"idle4"];
    [data animationForName:@"walk2x"];
    [data animationForName:@"jumpOver_lift"];
    [data animationForName:@"jumpOver_fall"];
    [data animationForName:@"jumpOver_land"];
    [data animationForName:@"hit1"];
    [[GameManager sharedGameManager] runScene:GameScenePlayerInfo];
}


-(void)playerDataUpdateFailedWithError:(NSError *)error
{
    CCLOG(@"Error updating player data: %@", error.description);    
}

@end
