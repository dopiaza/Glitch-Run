//
//  GlitchPlayerInfo.m
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


#import "GlitchPlayerInfo.h"


@implementation GlitchPlayerInfo

@synthesize userName;
@synthesize playerName;
@synthesize playerTsid;
@synthesize avatarUrl;

-(id) initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.userName = [dict valueForKey:@"user_name"];
        self.playerName = [dict valueForKey:@"player_name"];
        self.playerTsid = [dict valueForKey:@"player_tsid"];
        self.avatarUrl = [dict valueForKey:@"avatar_url"];
    }
    
    return self;
}

-(id) initWithObject:(NSObject *)object
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        self = [self initWithDictionary:(NSDictionary *)object];
    }
    else
    {
        self = [super init];
    }
    
    return self;
}

-(void)dealloc
{
    self.userName = nil;
    self.playerName = nil;
    self.playerTsid = nil;
    self.avatarUrl = nil;
    
    [super dealloc];
}

@end
