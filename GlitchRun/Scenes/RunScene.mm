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


#import "RunScene.h"
#import "EndlessBackgroundLayer.h"
#import "RunGameLayer.h"
#import "Constants.h"

@interface RunScene () 

@property (retain, nonatomic) EndlessBackgroundLayer *backgroundLayer;
@property (retain, nonatomic) RunGameLayer *gameLayer;
    
@end

@implementation RunScene

@synthesize backgroundLayer = _backgroundLayer;
@synthesize gameLayer = _gameLayer;

- (id)init
{
    self = [super init];
    if (self) 
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGFloat offset = -screenSize.width/4;
        
        NSString *bgName = @"";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            bgName = @"Run-background-iPad.png";
        }
        else
        {
            bgName = @"Run-background-iPhone.png";
        }
        
        self.backgroundLayer = [EndlessBackgroundLayer node];
        self.backgroundLayer.offsetFromCentre = offset;
        [self.backgroundLayer setBackgroundAsImageNamed:bgName];
        [self addChild:self.backgroundLayer z:0];    
        
        self.gameLayer = [RunGameLayer node];
        [self addChild:self.gameLayer z:10];    
        
        [self scheduleUpdate];
    }
    
    return self;
}


-(void)dealloc
{
    [_backgroundLayer release];
    _backgroundLayer = nil;
    
    [_gameLayer release];
    _gameLayer = nil;
    
    [super dealloc];
}

-(void) update:(ccTime)deltaTime
{ 
    [self.gameLayer update:deltaTime];
    self.backgroundLayer.backgroundPosition = [self.gameLayer jumperDistance] * PTM_RATIO;
}

@end
