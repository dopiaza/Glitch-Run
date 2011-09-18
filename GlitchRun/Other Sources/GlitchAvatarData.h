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


#import <Foundation/Foundation.h>
#import "GlitchAnimationSet.h"
#import "cocos2d.h"
#import "DZDataLoader/DZDataLoader.h"

@class GlitchAvatarData;

@protocol GlitchAvatarDataDelegate <NSObject>

-(void)glitchAvatarDataLoaded:(GlitchAvatarData *)avatarData;
-(void)glitchAvatarData:(GlitchAvatarData *)avatarData failedWithError:(NSError *)error;

@end




@interface GlitchAvatarData : NSObject
<DZDataLoaderDelegate>
{
}

-(void)loadFromAnimationSet:(GlitchAnimationSet *)animationSet withDelegate:(NSObject<GlitchAvatarDataDelegate> *)delegate;
-(CCAnimation *)animationForName:(NSString *)name;
-(CCTexture2D *)defaultTexture;

@end
