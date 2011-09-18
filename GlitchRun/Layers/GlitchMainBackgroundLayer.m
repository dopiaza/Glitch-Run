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


#import "GlitchMainBackgroundLayer.h"


#define kCloudSpeed 5   // Pixels per second

@interface GlitchMainBackgroundLayer ()

@property (nonatomic, retain) CCSprite *clouds1;
@property (nonatomic, retain) CCSprite *clouds2;
@property (nonatomic, assign) CGSize cloudSize;

@end


@implementation GlitchMainBackgroundLayer

@synthesize clouds1 = _clouds1;
@synthesize clouds2 = _clouds2;
@synthesize cloudSize = _cloudSize;

- (id)init
{
    self = [super init];
    if (self) 
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];

        NSString *skyImage = @"";
        NSString *foregroundImage = @"";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            skyImage = @"GlitchSky-iPad.png";
            foregroundImage = @"GlitchMainScene-iPad.png";
        }
        else
        {
            skyImage = @"GlitchSky.png";
            foregroundImage = @"GlitchMainScene.png";
        }
        
        CCSprite *sky = [CCSprite spriteWithFile:skyImage];
        CCSprite *foreground = [CCSprite spriteWithFile:foregroundImage];
        self.clouds1 = [CCSprite spriteWithFile:@"clouds.png"];
        self.clouds2 = [CCSprite spriteWithFile:@"clouds.png"];

        self.cloudSize = self.clouds1.contentSize;
        
        [sky setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [foreground setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        [self.clouds1 setPosition:ccp(self.cloudSize.width/2, screenSize.height - self.cloudSize.height/2 - 10)];
        [self.clouds2 setPosition:ccp(self.cloudSize.width/2, screenSize.height - self.cloudSize.height/2 - 10)];
        
        [self addChild:sky z:0];
        [self addChild:self.clouds1 z:1];
        [self addChild:self.clouds2 z:2];
        [self addChild:foreground z:3];
        
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)dealloc
{
    [_clouds1 release];
    _clouds1 = nil;
    
    [_clouds2 release];
    _clouds2 = nil;
    
    [super dealloc];
}

-(void) update:(ccTime)deltaTime
{ 
    CGPoint clouds1Pos = self.clouds1.position;
    CGFloat newX = clouds1Pos.x + (deltaTime * kCloudSpeed);
    if (newX > 1.5 * self.cloudSize.width)
    {
        newX = self.cloudSize.width/2;
    }
    self.clouds1.position = ccp(newX, clouds1Pos.y);
    self.clouds2.position = ccp(newX - self.cloudSize.width, clouds1Pos.y);
}

@end
