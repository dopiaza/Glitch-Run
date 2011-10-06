//
//  PreloaderOperation.h
//  GlitchRun
//
//  Created by David Wilkinson on 04/10/2011.
//  Copyright 2011 Lumen Services Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlitchAvatarData.h"

@protocol LoaderDelegate;

@interface AnimationPreloaderOperation : NSOperation
<GlitchAnimationLoadDelegate>

-(id)initWithLoaderDelegate:(NSObject<LoaderDelegate> *)delegate;

@end
