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


#import "NSDictionary(Glitch).h"

@implementation NSDictionary (NSDictionary_Glitch_)

-(NSInteger)intValueForKey:(NSString *)key
{
    NSInteger ret = 0;
    
    NSObject *o = [self objectForKey:key];
    if ([o isKindOfClass:[NSNumber class]])
    {
        ret = [(NSNumber *)o intValue];
    }
    else if ([o isKindOfClass:[NSString class]])
    {
        ret = [(NSString *)o intValue];
    }
    
    return ret;
}

-(long)longValueForKey:(NSString *)key
{
    NSInteger ret = 0;
    
    NSObject *o = [self objectForKey:key];
    if ([o isKindOfClass:[NSNumber class]])
    {
        ret = [(NSNumber *)o longValue];
    }
    else if ([o isKindOfClass:[NSString class]])
    {
        ret = [(NSString *)o intValue];
    }
    
    return ret;
}

-(float)floatValueForKey:(NSString *)key;
{
    float ret = 0.0F;
    
    NSObject *o = [self objectForKey:key];
    if ([o isKindOfClass:[NSNumber class]])
    {
        ret = [(NSNumber *)o floatValue];
    }
    else if ([o isKindOfClass:[NSString class]])
    {
        ret = [(NSString *)o floatValue];
    }
    
    
    return ret;
}

-(int)glitchResultCode
{
    int n = -1;
    NSObject *o = [self objectForKey:@"ok"];
    if ([o isKindOfClass:[NSNumber class]])
    {
        n = [(NSNumber *)o intValue];
    }
    return n;
}

-(NSString *)glitchError
{
    NSString *error = nil;;
    NSObject *o = [self objectForKey:@"error"];
    if ([o isKindOfClass:[NSString class]])
    {
        error = (NSString *)o;
    }
    return error;    
}

@end
