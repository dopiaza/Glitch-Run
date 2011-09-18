//
//  GlitchSpriteSheet.h
//  Glitch
//
//  Created by David Wilkinson on 23/07/2011.
//  Copyright 2011 Lumen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlitchSpriteSheet : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSInteger columns;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, retain) NSArray *frames;
@property (nonatomic, retain) NSString *url;

@end
