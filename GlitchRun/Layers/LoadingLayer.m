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


#import "LoadingLayer.h"
#import "Glitch.h"

@interface LoadingLayer ()

@property (assign, nonatomic) NSTimeInterval loadTime;
@property (retain, nonatomic) CCLabelBMFont *loadingLabel;
@property (assign, nonatomic) int progress;

@end


@implementation LoadingLayer

@synthesize loadTime = _loadTime;
@synthesize loadingLabel = _loadingLabel;
@synthesize progress = _progress;

-(id) init
{
    self = [super init];
    
	if (self)
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        NSString *fntFile = @"GlitchMain.fnt";
        
        self.loadingLabel = [CCLabelBMFont labelWithString:@"Loading"  fntFile:fntFile];
        self.loadingLabel.position = ccp((screenSize.width - self.loadingLabel.contentSize.width)/2, screenSize.height/2);
        self.loadingLabel.anchorPoint = ccp(0, 0);

        [self addChild:self.loadingLabel];

        [self scheduleUpdate];
        self.loadTime = [NSDate timeIntervalSinceReferenceDate];
    }
	
    return self;
}

- (void) dealloc
{
    [_loadingLabel release];
    _loadingLabel = nil;
    
	[super dealloc];
}

-(void) update:(ccTime)deltaTime
{
    [self updateProgress];
}

-(void)updateProgress
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    double diff = now - self.loadTime;
    //NSLog(@"Diff: %.3f", diff);
    if (diff >= 0.3)
    {
        [self.loadingLabel setString:[NSString stringWithFormat:@"Loading%@", [@"........" substringToIndex:(self.progress++ % 6)]]];  
        self.loadTime = now; 
    }
}

@end
