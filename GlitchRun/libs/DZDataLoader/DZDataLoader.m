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

#import <UIKit/UIKit.h>
#import "DZDataLoader.h"
#import "DZDataCache.h"


@interface DZDataInfo : NSObject 
{
@public
    DZDataLoadToken token;
    NSMutableData *data;
    NSURL *url;
    NSURLConnection *connection;
    NSObject<DZDataLoaderDelegate> *delegate;
}

@end

@implementation DZDataInfo

-(void)dealloc
{
    [data release];
    [url release];
    [connection release];
    [delegate release];
    [super dealloc];
}

@end

static DZDataLoader *_sharedDataLoader = nil;
static DZDataLoadToken _imageTokenCounter = 1;

@interface DZDataLoader ()

-(void)dataReadyForDataInfo:(DZDataInfo *)dataInfo;

@property (retain) NSMutableDictionary *dataMap;

@end

@implementation DZDataLoader

@synthesize dataMap = _dataMap;
@synthesize timeout = _timeout;

+(DZDataLoader *)sharedDataLoader
{
    if (_sharedDataLoader == nil)
    {
        _sharedDataLoader = [[DZDataLoader alloc] init];
    }
    
    return _sharedDataLoader;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.dataMap = [NSMutableDictionary dictionaryWithCapacity:10];
        self.timeout = 30.0;
    }
    
    return self;
}


-(DZDataLoadToken)loadData:(NSURL *)dataUrl withDelegate:(NSObject<DZDataLoaderDelegate> *)delegate
{
    DZDataLoadToken keyVal = 0;
    
    if (dataUrl)
	{
        keyVal = _imageTokenCounter++;

        DZDataInfo *data = [[DZDataInfo alloc] init];
        data->token = keyVal;
        data->data = [[NSMutableData dataWithCapacity:10000] retain];
        data->url = [dataUrl retain];
        data->delegate = [delegate retain];

        // First of all, check the cache.
		NSData *cachedData = [[DZDataCache sharedDataCache] cachedDataForUrl:dataUrl];

        if (cachedData)
		{
            NSLog(@"Using cache for %@", [dataUrl absoluteString]);
            [data->data appendData:cachedData];
            [self performSelectorOnMainThread:@selector(dataReadyForDataInfo:) withObject:data waitUntilDone:NO];
		}
		else 
		{
            // No cached copy, so start the load
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL: dataUrl
                                                        cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval: self.timeout];
            
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
            
            // and we save the connection for later
            data->connection = [connection retain];
            [connection release];
        }
        
        NSNumber *key = [NSNumber numberWithInteger:keyVal];
        [self.dataMap setObject:data forKey:key];
        [data release];			
    }
    
    return keyVal;
}

-(DZDataInfo *)findDataInfoForConnection:(NSURLConnection *) connection
{
	DZDataInfo *data = nil;
	
    for (DZDataInfo *dataInfo in [self.dataMap allValues])
    {
        if (dataInfo->connection == connection)
        {
            data = dataInfo;
            break;
        }
    }
	
	return data;
}

-(void)cancelDataLoadForToken:(DZDataLoadToken)token
{
    NSNumber *key = [NSNumber numberWithInteger:token];
    DZDataInfo *dataInfo = [self.dataMap objectForKey:key];
    if (dataInfo)
    {
        [dataInfo->connection cancel];
        [self.dataMap removeObjectForKey:key];
    }
}

#pragma mark - NSURLConnection delegate methods

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    DZDataInfo *dataInfo = [self findDataInfoForConnection:connection];
	NSMutableData *d = dataInfo->data;
	[d setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData: (NSData *) data
{
    DZDataInfo *dataInfo = [self findDataInfoForConnection:connection];
	NSMutableData *d = dataInfo->data;
	[d appendData: data];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError: (NSError *) error
{
    DZDataInfo *dataInfo = [self findDataInfoForConnection:connection];
    if (dataInfo->delegate)
    {
        [dataInfo->delegate dataLoadFailedWithError:error forToken:dataInfo->token];
    }
    [self.dataMap removeObjectForKey:[NSNumber numberWithInteger:dataInfo->token]];
}

- (void)connectionDidFinishLoading: (NSURLConnection *) connection
{
    DZDataInfo *dataInfo = [self findDataInfoForConnection:connection];
    [[DZDataCache sharedDataCache] storeDataInCache:dataInfo->data forUrl:dataInfo->url];
    [self dataReadyForDataInfo:dataInfo];
}

-(void)dataReadyForDataInfo:(DZDataInfo *)dataInfo
{
    if (dataInfo->delegate)
    {
        [dataInfo->delegate dataLoaded:dataInfo->data forToken:dataInfo->token];
    }

    [self.dataMap removeObjectForKey:[NSNumber numberWithInteger:dataInfo->token]];    
}

@end
