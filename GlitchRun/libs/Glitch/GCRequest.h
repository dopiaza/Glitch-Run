/*-
 *  Glitch iOS SDK
 *  
 *  Copyright 2011 Tiny Speck, Inc.
 *  Created by Brady Archambo.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License. 
 *
 *  See more about Glitch at http://www.glitch.com
 *  http://www.tinyspeck.com
 */


#import <Foundation/Foundation.h>


@protocol GCRequestDelegate;


@interface GCRequest : NSObject {
    NSString * _url; // Full url for request, e.g. "http://api.glitch.com/simple/players.info"
    NSString * _method; // Specific method without 'simple', e.g. "players.info"
    NSDictionary * _params; // Dictionary of parameters passed in the request
    id<GCRequestDelegate> _requestDelegate; // Delegate that will be called when events occur before, during, and after the request
    NSURLConnection * _connection; // Connection object - this is held on to until the request completes
    NSMutableData * _receivedResponseData; // Response data, filled up as information is received from the server
    NSDictionary * _additionalData; // Optional additional data dictionary, can be used to store whatever you want that relates to a particular request
}


@property (nonatomic, copy) NSString * url;
@property (nonatomic, copy) NSString * method;
@property (nonatomic, copy) NSDictionary * params;
@property (nonatomic, assign) id<GCRequestDelegate> requestDelegate;
@property (nonatomic, assign) NSURLConnection * connection;
@property (nonatomic, assign) NSMutableData * receivedResponseData;
@property (nonatomic, copy) NSDictionary * additionalData;


#pragma mark - Initialization

// Do not call this directly - call Glitch, which will call this lower-level method
//
// Get a GCRequest object with a specificed method,
// delegate to call when request/response events occur,
// and any parameters passed in for the request.
+ (GCRequest *)requestWithMethod:(NSString*)method
                     delegate:(id<GCRequestDelegate>)delegate
                       params:(NSDictionary*)params
                         additionalData:(NSDictionary*)additionalData;


#pragma mark - Interacting with the API

// Once you have the request object, call this to actually perform the asynchronous request
- (void)connect;

// Parse the data from the server into an object using JSON parser
- (id)parseResponse:(NSData *)data;


#pragma mark - Utility

+ (NSString *)urlEncodeString:(NSString*)string;
+ (NSString*)serializeURL:(NSString*)url params:(NSDictionary*)params;
+ (NSString*)serializeParams:(NSDictionary*)params;
+ (NSDictionary*)deserializeParams:(NSString*)query;


@end


/*------------------------------------------------------*/


@protocol GCRequestDelegate <NSObject>


@optional

// Called when request was completed
- (void)requestFinished:(GCRequest*)request withResult:(id)result;


// Called when request fails
- (void)requestFailed:(GCRequest*)request withError:(NSError*)error;


@end