//
//  PreloaderOperation.m
//  GlitchRun
//
//  Created by David Wilkinson on 04/10/2011.
//  Copyright 2011 Lumen Services Limited. All rights reserved.
//

#import "AnimationPreloaderOperation.h"
#import "GameManager.h"
#import "GlitchCentral.h"
#import "LoadingScene.h"

@interface AnimationPreloaderOperation ()

@property (assign, nonatomic) NSObject<LoaderDelegate> *delegate;

@end

@implementation AnimationPreloaderOperation

@synthesize delegate = _delegate;

- (id)initWithLoaderDelegate:(NSObject<LoaderDelegate> *)delegate
{
    self = [super init];
    if (self) 
    {
        self.delegate = delegate;
    }
    
    return self;
}

-(void)startGame
{
    [[GameManager sharedGameManager] runScene:GameScenePlayerInfo];    
}


-(void)animationName:(NSString *)name progress:(float)percentage
{
    if (![self isCancelled])
    {
        [self.delegate updateProgress];
    }
}

-(void)preloadAnimation:(NSString *)name
{
    NSLog(@"Preloading %@", name);
    GlitchAvatarData *data = [[GlitchCentral sharedInstance] avatarData];
    [data preloadAnimationForName:name withDelegate:self];
    
    if (![self isCancelled])
    {
        [self.delegate updateProgress];
    }
}

-(void)main
{
    NSArray *animationsToPreload = [NSArray arrayWithObjects:@"idle4", @"walk2x", @"jumpOver_lift", @"jumpOver_fall", @"jumpOver_land", @"hit1", nil];

    for (NSString *name in animationsToPreload)
    {
        if (![self isCancelled])
        {
            [self preloadAnimation:name];
        }
    }
    
    [self performSelectorOnMainThread:@selector(startGame) withObject:nil waitUntilDone:NO];
}

@end
