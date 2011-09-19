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


#import "GameManager.h"
#import "cocos2d.h"
#import "LoadingScene.h"
#import "PlayerInfoScene.h"
#import "RunScene.h"
#import "ResultsScene.h"
#import "GB2ShapeCache.h"

static GameManager *_sharedGameManager = nil;

@implementation GameManager

@synthesize lastDistanceRan = _lastDistanceRan;

+(GameManager *)sharedGameManager
{
    if (_sharedGameManager == nil)
    {
        _sharedGameManager = [[GameManager alloc] init];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MainTextureAtlas-iPhone.plist"];
        [CCSpriteBatchNode batchNodeWithFile:@"MainTextureAtlas-iPhone.png"];
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"Physics-iPhone.plist"];
    }
    
    return _sharedGameManager;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
    }
    
    return self;
}

-(void)setHiScore:(float)hiScore
{
    [[NSUserDefaults standardUserDefaults] setFloat:hiScore forKey:@"HiScore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(float)hiScore
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"HiScore"];
}

-(void)clearCaches
{
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [CCAnimationCache purgeSharedAnimationCache];
}

#pragma mark - Scene management

-(void)runScene:(GameSceneId)sceneId
{
    CCLOG(@"Switch to scene %d", sceneId);
    
    CCScene *scene = nil;
    
    switch (sceneId) 
    {
        case GameSceneLoading:
            scene = [LoadingScene node];
            break;
            
        case GameScenePlayerInfo:
            scene = [PlayerInfoScene node];
            break;
            
        case GameSceneRun:
            scene = [RunScene node];
            break;
            
        case GameSceneResults:
            scene = [ResultsScene node];
            break;
            
        default:
            break;
    }
    
    if (scene)
    {
        if ([[CCDirector sharedDirector] runningScene] == nil) 
        {
            [[CCDirector sharedDirector] runWithScene:scene];
        }
        else
        {
            [[CCDirector sharedDirector] replaceScene:scene];
        }
    }
}


@end
