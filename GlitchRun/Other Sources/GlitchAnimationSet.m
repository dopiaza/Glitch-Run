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


#import "GlitchAnimationSet.h"
#import "GlitchSpriteSheet.h"
#import "GlitchAnimation.h"
#import "NSDictionary(Glitch).h"

@implementation GlitchAnimationSet

@synthesize spritesheets = _spritesheets;
@synthesize animations = _animations;

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
    }
    
    return self;
}

-(id) initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        _spritesheets = [[NSMutableDictionary alloc] initWithCapacity:12];
        _animations = [[NSMutableDictionary alloc] initWithCapacity:12];

        NSObject *sheetsObject = [dict objectForKey:@"sheets"];
        if (sheetsObject)
        {
            NSMutableDictionary *sheetsList = (NSMutableDictionary *)[dict objectForKey:@"sheets"];
            
            for (NSString *name in [sheetsList allKeys]) 
            {
                NSDictionary *d = [sheetsList objectForKey:name];
                if ([d isKindOfClass:[NSDictionary class]])
                {
                    GlitchSpriteSheet *ss = [[GlitchSpriteSheet alloc] init];
                    ss.name = name;
                    ss.rows = [d intValueForKey:@"rows"];
                    ss.columns = [d intValueForKey:@"cols"];
                    ss.url = [d objectForKey:@"url"];
                    
                    NSArray *f = [d objectForKey:@"frames"];
                    if ([f isKindOfClass:[NSArray class]])
                    {
                        ss.frames = f;
                    }
                    [self.spritesheets setObject:ss forKey:name];
                    [ss release];
                }
            }
        }
        
        NSObject *animationsObject = [dict objectForKey:@"anims"];
        if (animationsObject)
        {
            NSMutableDictionary *animationsList = (NSMutableDictionary *)[dict objectForKey:@"anims"];
            
            for (NSString *name in [animationsList allKeys]) 
            {
                NSArray *a = [animationsList objectForKey:name];
                if ([a isKindOfClass:[NSArray class]])
                {
                    GlitchAnimation *anim = [[GlitchAnimation alloc] init];
                    anim.name = name;
                    anim.frames = a;
                    [self.animations setObject:anim forKey:name];
                    [anim release];
                }
            }
        }
    }
    
    return self;
}

-(void)dealloc
{
    [_spritesheets release];
    _spritesheets = nil;
    
    [_animations release];
    _animations = nil;
    
    [super dealloc];
}

@end
