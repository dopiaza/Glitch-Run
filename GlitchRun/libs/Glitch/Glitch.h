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
#import "GCRequest.h"


@protocol GCSessionDelegate;


@interface Glitch : NSObject <GCRequestDelegate> {
    NSString * _accessToken;
    id<GCSessionDelegate> _sessionDelegate;
    BOOL _authenticating;
}


@property (nonatomic, copy) NSString * accessToken;
@property (nonatomic, assign) id<GCSessionDelegate> sessionDelegate;


#pragma mark - Initialization

- (id)initWithDelegate:(id<GCSessionDelegate>)delegate;


#pragma mark - Authorization with Glitch

- (void)authorizeWithScope:(NSString*)scope; // Pass in "identity", "read", or "write" as scope. See Glitch API docs for more info about OAuth scopes!
- (void)authorizeWithScope:(NSString*)scope andState:(NSString*)state;
- (void)handleOpenURL:(NSURL*)url;
- (void)logout;
- (BOOL)isAuthenticated;


#pragma mark - Utility

- (void)saveAccessTokenToDisk;


#pragma mark - Interacting with the API

- (GCRequest*)requestWithMethod:(NSString*)method delegate:(id<GCRequestDelegate>)delegate params:(NSDictionary*)params;
- (GCRequest*)requestWithMethod:(NSString*)method delegate:(id<GCRequestDelegate>)delegate;


#pragma mark - Glitch Request Delegate Methods for Checking Auth Token

- (void)reauth:(NSDictionary*)additionalData;


@end


/*------------------------------------------------------*/


@protocol GCSessionDelegate <NSObject>


@optional

// Called when login was successful
- (void)glitchLoginSuccess;


// Called when login fails
- (void)glitchLoginFail:(NSError*)error;


// Called when logout was completed
- (void)glitchLoggedOut;


@end
