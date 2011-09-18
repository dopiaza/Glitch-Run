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


#import "EndlessBackgroundLayer.h"

#define kBackgroundSpriteWidth 1024
#define kActiveBackgroundZIndex (-10)
#define kPaddingBackgroundZIndex (-20)

@interface EndlessBackgroundLayer ()

@property (retain, nonatomic) CCSprite *activeBackground;
@property (retain, nonatomic) CCSprite *paddingBackground;
@property (assign, nonatomic) CGFloat backgroundY;
@property (assign, nonatomic) CGSize screenSize;

@end


@implementation EndlessBackgroundLayer

@synthesize activeBackground = _activeBackground;
@synthesize paddingBackground = _paddingBackground;
@synthesize backgroundPosition = _backgroundPosition;
@synthesize backgroundY = _backgroundY;
@synthesize screenSize = _screenSize;
@synthesize offsetFromCentre = _offsetFromCentre;


/*
 * A background layer consists of two CCSprites that are used to give the appearance of an infinite (horizontal) world.
 * The activeBackground is the background that sits behind the current backgroundPosition.
 * The paddingBackground is used to fill in the gap as the edge of the activeBackground appears on the screen.
 */

-(id)init
{
    self = [super init];
    if (self) 
    {
        self.offsetFromCentre = 0;
        self.screenSize = [[CCDirector sharedDirector] winSize];
        self.backgroundY =  self.screenSize.height/2;
        self.backgroundPosition = 0.0;
    }
    
    return self;
}

-(void)dealloc
{
    [_activeBackground release];
    _activeBackground = nil;

    [_paddingBackground release];
    _paddingBackground = nil;

    [super dealloc];
}

-(void)setBackgroundAsImageNamed:(NSString *)imageName
{
    if (self.activeBackground)
    {
        [self.activeBackground removeFromParentAndCleanup:YES];
    }

    if (self.paddingBackground)
    {
        [self.paddingBackground removeFromParentAndCleanup:YES];
    }

    self.activeBackground = [CCSprite spriteWithFile:imageName rect:CGRectMake(0, 0, kBackgroundSpriteWidth, self.screenSize.height)];
    self.paddingBackground = [CCSprite spriteWithFile:imageName rect:CGRectMake(0, 0, kBackgroundSpriteWidth, self.screenSize.height)];
    //ccTexParams params = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
    //[self.activeBackground.texture setTexParameters:&params];  
    //[self.paddingBackground.texture setTexParameters:&params];  
    self.activeBackground.position = CGPointMake(self.screenSize.width/2 + kBackgroundSpriteWidth/2, self.backgroundY);
    [self addChild:self.activeBackground z:kActiveBackgroundZIndex];
    self.paddingBackground.position = CGPointMake(self.screenSize.width/2 + kBackgroundSpriteWidth/2 + kBackgroundSpriteWidth, self.backgroundY);
    [self addChild:self.paddingBackground z:kPaddingBackgroundZIndex];

    [self setBackgroundPosition:self.backgroundPosition];  // Force a recalculation of the background position on screen
}

-(void)moveBackgroundByOffset:(CGFloat)offset
{
    self.backgroundPosition = self.backgroundPosition + offset;
}

-(void)setBackgroundPosition:(CGFloat)newPosition
{
    int div = (int)(floor(newPosition/kBackgroundSpriteWidth));
    CGFloat offsetWithinBackgroundSprite = newPosition - (kBackgroundSpriteWidth * div);
    // position active bg on screen
    CGFloat x = self.screenSize.width/2 + kBackgroundSpriteWidth/2 - offsetWithinBackgroundSprite + self.offsetFromCentre;
    self.activeBackground.position = ccp(x, self.backgroundY);
    // and position the padding on either end depending on where the gap is
    if (x > self.screenSize.width/2)
    {
        // first half, padding goes before this one
        self.paddingBackground.position = ccp(x - kBackgroundSpriteWidth, self.backgroundY);
    }
    else
    {
        // second half, padding goes after this one
        self.paddingBackground.position = ccp(x + kBackgroundSpriteWidth, self.backgroundY);
    }
    _backgroundPosition = newPosition;
}

-(void)setOffsetFromCentre:(CGFloat)offsetFromCentre
{
    _offsetFromCentre = offsetFromCentre;
    [self setBackgroundPosition:self.backgroundPosition];  // Force a recalculation of the background position on screen
}

@end
