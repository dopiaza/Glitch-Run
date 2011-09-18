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

#import <CommonCrypto/CommonDigest.h>

#import "DZDataCache.h"

static DZDataCache *_sharedDZDataCache = nil;

@interface NSDictionary (SortByFileModificationDate)

-(NSComparisonResult)compareFileModificationDate:(id)object;

@end

@implementation NSDictionary (SortByFileModificationDate)

-(NSComparisonResult)compareFileModificationDate:(id)object
{
	NSComparisonResult result = NSOrderedSame;
	if ([object isKindOfClass:[NSDictionary class]])
	{
		NSDictionary *otherDict = (NSDictionary *)object;
		if ([self fileModificationDate] < [otherDict fileModificationDate])
		{
			result = NSOrderedAscending;
		}
		else if ([self fileModificationDate] > [otherDict fileModificationDate])
		{	
			result = NSOrderedDescending;
		}
	}
	return result;
}

@end


@interface DZDataCache ()

-(void)calculateCacheSize;
-(NSString *) md5:(NSString *)str;
-(NSString *)calculatePathToCachedFileForUrl:(NSURL *)url;
-(void)pruneCacheToAccomodateFileOfSize:(unsigned long)size;
-(void)touchFileForUrl:(NSURL *)url;
-(void)touchFileForPath:(NSString *)path;



@property (copy, nonatomic) NSString *cachePath;
@property (retain, nonatomic) NSFileManager *fileManager;
@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) unsigned long cacheSize;

@end


@implementation DZDataCache

@synthesize cachePath = _cachePath;
@synthesize fileManager = _fileManager;
@synthesize enabled = _enabled;
@synthesize cacheSize = _cacheSize;
@synthesize maximumCacheSize = _maximumCacheSize;

-(id)init
{
    self = [super init];
	if (self)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		self.cachePath = [documentsDirectory stringByAppendingPathComponent:@"DZDataCache"];
		
		NSFileManager *fm = [[NSFileManager alloc] init];
		self.fileManager = fm;
		[fm release];
		
		if ([self.fileManager fileExistsAtPath:self.cachePath])
		{
			self.enabled = YES;
		}
		else
		{
			self.enabled = [self.fileManager createDirectoryAtPath:self.cachePath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		
		if (self.enabled)
		{
			[self calculateCacheSize];			
		}
		else 
		{
			NSLog(@"DZDataCache cache disabled");
		}

	}
	return self;
}


-(void)dealloc
{
    [_cachePath release];
	_cachePath = nil;
    
    [_fileManager release];
	_fileManager = nil;
	
	[super dealloc];
}


+(DZDataCache *)sharedDataCache
{
	if (!_sharedDZDataCache)
	{
		_sharedDZDataCache = [[DZDataCache alloc] init];
	}
	
	return _sharedDZDataCache;
}


-(void)calculateCacheSize
{
	unsigned long n = 0;
	NSError *error = nil;
	NSDirectoryEnumerator *dirEnum = [self.fileManager enumeratorAtPath:self.cachePath];
	
	NSString *file;
	while ((file = [dirEnum nextObject])) 
	{
		NSString *filePath = [self.cachePath stringByAppendingPathComponent:file];
		NSDictionary *attr = [self.fileManager attributesOfItemAtPath:filePath error:&error];
		if (!error)
		{
			n += [attr fileSize];
		}
		else 
		{
			NSLog(@"Cannot get file size for %@ [%@] - disabling DZDataCache", filePath, [error userInfo]);
			self.enabled = NO;
			break;
		}
	}
	
	self.cacheSize = n;
}

-(void)storeDataInCache:(NSData *)data forUrl:(NSURL *)url
{
	if (self.enabled)
	{
		[self pruneCacheToAccomodateFileOfSize:[data length]];
		NSString *path = [self calculatePathToCachedFileForUrl:url];
		[self.fileManager createFileAtPath:path contents:data attributes:nil];
		self.cacheSize += [data length];
		//NSLog(@"DZDataCache: Storing %@ -> %@", path, [url absoluteString]);		
	}
}

-(void)touchFileForUrl:(NSURL *)url
{
	if (self.enabled)
	{
		NSString *path = [self calculatePathToCachedFileForUrl:url];
		[self touchFileForPath:path];
	}	
}


-(void)touchFileForPath:(NSString *)path
{	
	if (self.enabled)
	{
		NSError *error = nil;
		
		if ([self.fileManager fileExistsAtPath:path])
		{
			NSDictionary *attr = [NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate];
			[self.fileManager setAttributes:attr ofItemAtPath:path error:&error];
		}
	}	
}

-(NSString *)pathToCachedFileForUrl:(NSURL *)url
{
	NSString *path = nil;
	
	if (self.enabled)
	{
		path = [self calculatePathToCachedFileForUrl:url];
		
		if (![self.fileManager fileExistsAtPath:path])
		{
			path = nil;
		}
		
		//NSLog(@"DZDataCache: Search %@ -> %@", [url absoluteString], path);	
		[self touchFileForPath:path];
	}
	
	return path;
}


-(NSData *)cachedDataForUrl:(NSURL *)url
{
	NSData *data = nil;
	if (self.enabled)
	{
		NSString *path = [self pathToCachedFileForUrl:url];
		if (path)
		{
			data = [self.fileManager contentsAtPath:path];
			[self touchFileForPath:path];
		}		
	}
	return data;
}

-(NSString *)calculatePathToCachedFileForUrl:(NSURL *)url
{
	return [self.cachePath stringByAppendingPathComponent:[self md5:[url absoluteString]]];
}
			
// TODO - Overcomplicated
-(void)pruneCacheToAccomodateFileOfSize:(unsigned long)size
{
	unsigned long maxCacheSizeInBytes = ((unsigned long)self.maximumCacheSize) * 1024L * 1024L;
	// First of all, check to see if there's already enough space there
	if (self.cacheSize + size <= maxCacheSizeInBytes)
	{
		// We're fine
		return;
	}
	
	//NSLog(@"DZDataCache: Pruning - need %lu bytes, current cache size is %lu bytes, max is %lu MBytes", size, self.cacheSize, self.maximumCacheSize);
	
	// OK, need to prune cache
	NSMutableDictionary *filesAvailable = [[NSMutableDictionary alloc] initWithCapacity:10];
	NSMutableDictionary *filesToPrune = [[NSMutableDictionary alloc] initWithCapacity:10];
	unsigned long bytesToSave = size - (maxCacheSizeInBytes - self.cacheSize);
	unsigned long bytesSaved = 0;
	
	// So, let's build up a list of candidates to remove
	NSError *error = nil;
	NSDirectoryEnumerator *dirEnum = [self.fileManager enumeratorAtPath:self.cachePath];
	
	NSString *file;
	while ((file = [dirEnum nextObject])) 
	{
		NSString *filePath = [self.cachePath stringByAppendingPathComponent:file];
		NSDictionary *attr = [self.fileManager attributesOfItemAtPath:filePath error:&error];
		if (!error)
		{
            [filesAvailable setObject:attr forKey:filePath];
        }
    }
    
    // Prune files, oldest first, until we have enough space
    NSArray *sortedFiles = [filesAvailable keysSortedByValueUsingSelector:@selector(compareFileModificationDate:)];

    for (int n = 0; n < [sortedFiles count]; n++)
    {
        NSString *f = [sortedFiles objectAtIndex:n];
        NSDictionary *attr = [filesAvailable objectForKey:f];
        
        [filesToPrune setObject:attr forKey:f];
        bytesSaved += [attr fileSize];
        if (bytesSaved >= bytesToSave)
        {
            break;
        }
    }
    
	// And now let's prune the files
	for (NSString *f in [filesToPrune allKeys])
	{
		NSDictionary *a = [filesToPrune objectForKey:f];
		[self.fileManager removeItemAtPath:f error:nil];
		self.cacheSize -= [a fileSize];
		//NSLog(@"DZDataCache: Removing %@ [%ul] bytes", f, [a fileSize]);
	}
	
	[filesToPrune release];
}

-(void)emptyCache
{
	NSDirectoryEnumerator *dirEnum = [self.fileManager enumeratorAtPath:self.cachePath];
	
	NSString *file;
	while ((file = [dirEnum nextObject])) 
	{
		NSString *filePath = [self.cachePath stringByAppendingPathComponent:file];
		[self.fileManager removeItemAtPath:filePath error:nil];
	}
	self.cacheSize = 0;
}


- (NSString *) md5:(NSString *)str 
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(cStr, strlen(cStr), result);
	
	return [NSString 
			stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]
			];	
}


@end
