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


#import "cocos2d.h"
#import "GlitchCentral.h"
#import "GlitchAvatarData.h"
#import "GlitchPlayerInfo.h"
#import "AppDelegate.h"
#import "GameManager.h"
#import "NSDictionary(Glitch).h"

static GlitchCentral *_sharedGlitchCentralInstance;

@interface GlitchCentral ()


@property (nonatomic, retain) NSObject<GlitchDelegate> *delegate;
@property (nonatomic, retain) GCRequest *animationsRequest;
@property (nonatomic, retain) GCRequest *playerInfoRequest;
@property (nonatomic, retain) GlitchPlayerInfo *playerInfo;
@property (nonatomic, retain) GlitchAnimationSet *animationSet;
@property (nonatomic, retain) GlitchAvatarData *avatarData;
@property (nonatomic, assign) BOOL authenticating;

@end

@implementation GlitchCentral

@synthesize api = _api;
@synthesize animationsRequest = _animationsRequest;
@synthesize playerInfoRequest = _playerInfoRequest;
@synthesize playerInfo = _playerInfo;
@synthesize animationSet = _animationSet;
@synthesize delegate = _delegate;
@synthesize avatarData = _avatarData;
@synthesize authenticating = _authenticating;


+(GlitchCentral *)sharedInstance
{
    if (_sharedGlitchCentralInstance == nil)
    {
        _sharedGlitchCentralInstance = [[GlitchCentral alloc] init];
    }
    
    return _sharedGlitchCentralInstance;
}

-(id)init
{
    self = [super init];
    if (self) 
    {
        _api = [[Glitch alloc] initWithDelegate:self];
    }
    
    return self;
}

-(void)dealloc
{
    [_api release];
    _api = nil;

    [_delegate release];
    _delegate = nil;

    [_playerInfoRequest release];
    _playerInfoRequest = nil;
    
    [_animationsRequest release];
    _animationsRequest = nil;
    
    [_playerInfo release];
    _playerInfo = nil;
    
    [_animationSet release];
    _animationSet = nil;
    
    [_avatarData release];
    _avatarData = nil;
    
    [super dealloc];
}

-(void)setPlayerTsid:(NSString *)playerTsid
{
    [[NSUserDefaults standardUserDefaults] setValue:playerTsid forKey:@"player_tsid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)playerTsid
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"player_tsid"];
}

-(void)authenticate
{
    self.authenticating = YES;
    [self.api authorizeWithScope:@"identity"];

}

-(void)sendPlayerDataProgress:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(playerDataProgress:)])
    {
        [self.delegate playerDataProgress:message];
    }
}

-(void)sendPlayerDataFailed:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(playerDataUpdateFailedWithError:)])
    {
        [self.delegate playerDataUpdateFailedWithError:error];
    }
}

-(void)sendPlayerDataUpdated
{
    if ([self.delegate respondsToSelector:@selector(playerDataUpdated)])
    {
        [self.delegate playerDataUpdated];
    }
}

-(void)updatePlayerDataWithDelegate:(NSObject<GlitchDelegate> *)delegate
{
    self.delegate = delegate;
    self.playerInfoRequest = [self.api requestWithMethod:@"players.info" delegate:self];
    [self.playerInfoRequest connect];
}

-(void)logout
{
    [self.api logout];
    
    // Remove all traces of the previous user and cached sprites
    self.playerInfo = nil;
    self.animationSet = nil;
    self.avatarData = nil;
    [[GameManager sharedGameManager] clearCaches];
}

-(BOOL)isAuthenticated
{
    return [self.api isAuthenticated];
}

#pragma mark - Glitch SDK delegate methods

-(void)handleOpenURL:(NSURL *)url
{
    self.authenticating = NO;
    [self.api handleOpenURL:url];
}

- (void)glitchLoginSuccess
{
    if (self.authenticating)
    {
        // We're still authenticating, which means we didn't get here via the app delegate
        // Must have been a stored token, so we'd better tell the app delegate
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate authenticationComplete];
    }
}

- (void)requestFinished:(GCRequest *)request withResult:(id)result
{
    BOOL ok = NO;
    
    if (request == self.playerInfoRequest)
    {
        if ([result glitchResultCode] != 0)
        {
            self.playerInfo = [[[GlitchPlayerInfo alloc] initWithDictionary:result] autorelease];
            self.playerTsid = self.playerInfo.playerTsid;
            [self sendPlayerDataProgress:@"Player info loaded"];
            NSDictionary *params = [NSDictionary dictionaryWithObject:self.playerTsid forKey:@"player_tsid"];
            self.animationsRequest = [self.api requestWithMethod:@"players.getAnimations" delegate:self params:params];
            [self.animationsRequest connect];
            ok = YES;
        }        
    }
    else if (request == self.animationsRequest)
    {
        if ([result glitchResultCode] != 0)
        {
            self.animationSet = [[[GlitchAnimationSet alloc] initWithDictionary:result] autorelease];
            [self sendPlayerDataProgress:@"Animation definitions loaded"];
            self.avatarData = [[GlitchAvatarData alloc] init];
            [self sendPlayerDataProgress:@"Loading spritesheets"];
            [self.avatarData loadFromAnimationSet:self.animationSet withDelegate:self];
            ok = YES;
        }
    }
    
    if (!ok)
    {
        [self sendPlayerDataFailed:nil]; // TODO send meaningful error
        self.delegate = nil;
    }

}

- (void)requestFailed:(GCRequest *)request withError:(NSError*)error
{
    NSLog(@"API Error: %@", error.description);
    [self sendPlayerDataFailed:error]; 
    self.delegate = nil;    
}


-(void)glitchAvatarDataLoaded:(GlitchAvatarData *)avatarData
{
    [self sendPlayerDataProgress:@"Spritesheets loaded"];
    [self sendPlayerDataUpdated];
}

-(void)glitchAvatarData:(GlitchAvatarData *)avatarData failedWithError:(NSError *)error
{
    [[GameManager sharedGameManager] runScene:GameSceneError];
}




@end
