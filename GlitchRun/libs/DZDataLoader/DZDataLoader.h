//
// DZDataLoader
//
// Copyright 2011 Lumen Services Limited
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

#import <Foundation/Foundation.h>

typedef NSInteger DZDataLoadToken;

@protocol DZDataLoaderDelegate <NSObject>

-(void)dataLoaded:(NSData *)data forToken:(DZDataLoadToken)token;
-(void)dataLoadFailedWithError:(NSError *)error forToken:(DZDataLoadToken)token;

@end

@interface DZDataLoader : NSObject

+(DZDataLoader *)sharedDataLoader;

-(DZDataLoadToken)loadData:(NSURL *)dataUrl withDelegate:(NSObject<DZDataLoaderDelegate> *)delegate;
-(void)cancelDataLoadForToken:(DZDataLoadToken)token;

@property (nonatomic, assign) NSTimeInterval timeout;

@end
