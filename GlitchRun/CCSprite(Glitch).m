//
//  CCSprite(Glitch).m
//  GlitchRun
//
//  Created by David Wilkinson on 20/09/2011.
//  Copyright 2011 Lumen Services Limited. All rights reserved.
//

#import "CCSprite(Glitch).h"

@implementation CCSprite (CCSprite_Glitch_)

-(CGSize)scaledContentSize
{
    CGSize contentSize = self.contentSize;
    return CGSizeMake(contentSize.width * self.scaleX, contentSize.height * self.scaleY);
}

@end
