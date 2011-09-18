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


#ifndef GlitchRun_SpriteContactListener_h
#define GlitchRun_SpriteContactListener_h

#import "Box2DSprite.h"

@protocol Box2DContactDelegate <NSObject>

-(void)beginContact:(b2Contact *)contact;
-(void)endContact:(b2Contact *)contact;
-(void)preSolve:(b2Contact *)contact manifold:(b2Manifold *)oldManifold;
-(void)postSolve:(b2Contact *)contact impulse:(b2ContactImpulse *)impulse;

@end

class Box2DContactListener : public b2ContactListener 
{
    public:
        NSObject<Box2DContactDelegate> *delegate;
        
        
        Box2DContactListener(NSObject<Box2DContactDelegate> *delegate)
        { 
            this->delegate = delegate;
        }
        
        void BeginContact(b2Contact* contact) 
        { 
            [delegate beginContact:contact];
        }
        
        void EndContact(b2Contact* contact) 
        { 
            [delegate endContact:contact];
        }
        
        void PreSolve(b2Contact* contact, const b2Manifold* oldManifold) 
        { 
            [delegate preSolve:(b2Contact *)contact manifold:(b2Manifold *)oldManifold];
        }
        
        void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) 
        {  
            [delegate postSolve:(b2Contact *)contact impulse:(b2ContactImpulse *)impulse];
        }
    
};

#endif
