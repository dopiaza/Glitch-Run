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


#import "QueryStringParser.h"


@implementation QueryStringParser

- (id) initWithQueryString:(NSString *)queryString
{
	if (self = [super init])
	{
		dict = [[NSMutableDictionary alloc] initWithCapacity:10];
		NSArray *elements = [queryString componentsSeparatedByString:@"&"];
		for (NSString *element in elements)
		{
			NSArray *a = [element componentsSeparatedByString:@"="];
			NSString *key = [((NSString *)[a objectAtIndex:0]) stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *value = ([a count] == 1 ? @"" : [((NSString *)[a objectAtIndex:1]) stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
			[dict setValue:value forKey:key];
		}
	}
	return self;
}

- (NSString *)valueForKey:(NSString*)key
{
	return [dict valueForKey:key];
}

- (NSArray *)keys
{
	return [dict allKeys];
}

- (void) dealloc
{
	[dict removeAllObjects];
	[dict release];
	
	[super dealloc];
}

@end
