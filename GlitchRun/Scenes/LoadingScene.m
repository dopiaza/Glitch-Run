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
#import "AnimationPreloaderOperation.h"


@interface LoadingScene ()

-(void)loadData;

@property (retain, nonatomic) LoadingLayer *loadingLayer;
@property (retain, nonatomic) NSMutableArray *animationsToPreload;
@property (retain, nonatomic) NSOperationQueue *queue;

@end



@implementation LoadingScene

@synthesize loadingLayer = _loadingLayer;
@synthesize animationsToPreload = _animationsToPreload;
@synthesize queue = _queue;


- (id)init
{
    self = [super init];
    if (self) 
    {
        GlitchMainBackgroundLayer *backgroundLayer = [GlitchMainBackgroundLayer node];
        [self addChild:backgroundLayer z:0];
        
        self.queue = [[[NSOperationQueue alloc] init] autorelease];
        [self.queue setMaxConcurrentOperationCount:1];

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

    [_animationsToPreload release];
    _animationsToPreload = nil;
    
    [_queue release];
    _queue = nil;

    [super dealloc];
}

-(void)updateProgress
{
    [self.loadingLayer updateProgress];
    [self draw];
}

-(void)loadData
{
    [[GlitchCentral sharedInstance] updatePlayerDataWithDelegate:self];
}


-(void)playerDataProgress:(NSString *)progressMessage
{
    [self updateProgress];
}

-(void)startGame
{
    [[GameManager sharedGameManager] runScene:GameScenePlayerInfo];    
}

-(void)preloadAnimation:(NSString *)name
{
    GlitchAvatarData *data = [[GlitchCentral sharedInstance] avatarData];
    [data animationForName:name];
}

-(void)preloadAnimations
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    GlitchAvatarData *data = [[GlitchCentral sharedInstance] avatarData];
    // Preload some animations
    for (NSString *name in self.animationsToPreload)
    {
        NSString *name = [self.animationsToPreload objectAtIndex:0];
        [data animationForName:name];
        [self performSelectorOnMainThread:@selector(preloadAnimation:) withObject:name waitUntilDone:YES];
    }
    //[self performSelectorOnMainThread:@selector(startGame) withObject:nil waitUntilDone:NO];

    [pool release];
}

-(void)playerDataUpdated
{
    CCLOG(@"Player data updated");
    // We want to preload some animations. This takes a few moments, and we don't want to completely block the main thread during this. 
    // We could do this preloading on another thread, but we then have to deal with a whole bunch of threading issues.
    // All we want here is for the 'Loading...' indicator to keep moving, so we'll just preload one at a time and give the screen updates a
    // chance to run between each one.
    //self.animationsToPreload = [NSMutableArray arrayWithObjects:@"idle4", @"walk2x", @"jumpOver_lift", @"jumpOver_fall", @"jumpOver_land", @"hit1", nil];
    //[self preloadAnimations];
    //[self startGame];

    AnimationPreloaderOperation *op = [[AnimationPreloaderOperation alloc] initWithLoaderDelegate:self];
    [self.queue addOperation:op];
    [op release];
}


-(void)playerDataUpdateFailedWithError:(NSError *)error
{
    [self.queue cancelAllOperations];
    CCLOG(@"Error updating player data: %@", error.description);  
    [[GameManager sharedGameManager] runScene:GameSceneError];
}

@end
