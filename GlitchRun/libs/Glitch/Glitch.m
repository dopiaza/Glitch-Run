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


#import "Glitch.h"
#import "GlitchConfig.h"


static NSString * const kGCAuthUrl = @"http://api.glitch.com/oauth2/authorize";


@implementation Glitch


NSString * AccessTokenSavePath() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"GlitchOAuthAccessToken.cache"];
}


@synthesize accessToken = _accessToken,
                sessionDelegate = _sessionDelegate;


#pragma mark - Initialization

- (id)initWithDelegate:(id<GCSessionDelegate>)delegate
{
    self = [super init];
    if (self) {
        _sessionDelegate = delegate;
        _authenticating = NO;
    }
    
    return self;
}


#pragma mark - Authorization with Glitch

// Pass in "identity", "read", or "write" as scope. See Glitch API docs for more info about OAuth scopes!
- (void)authorizeWithScope:(NSString*)scope
{
    [self authorizeWithScope:scope andState:nil];
}


// State is an optional value used by the client to maintain state between the request and callback.
// The auth server includes this value when redirecting the user-agent back to the client.
- (void)authorizeWithScope:(NSString*)scope andState:(NSString*)state
{
    _authenticating = YES;
    
    // Set scope to identity if we don't have it
    NSString * serviceScope = scope ? scope : @"identity";
    
    // Check for saved token
    NSString * savedToken = [NSKeyedUnarchiver unarchiveObjectWithFile:AccessTokenSavePath()];
    
    if (savedToken)
    {
        // Using saved token
        _accessToken = [savedToken copy];
        
        // Call auth.check to validate token before proceeding
        GCRequest * request = [self requestWithMethod:@"auth.check" delegate:self];
        
        // Add scope and (optionally) state to the additional data dictionary so that we can reauthorize later with these parameters if auth.check fails for any reason
        request.additionalData = state ? [NSDictionary dictionaryWithObjectsAndKeys:scope, @"scope", state, @"state", nil] : [NSDictionary dictionaryWithObject:scope forKey:@"scope"];
        
        [request connect];
        
        return;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             GCAPIKey,@"client_id",
                             GCRedirectURI,@"redirect_uri",
                             @"token",@"response_type",
                             serviceScope,@"scope",
                             nil];
    
    if (state)
    {
        [params setValue:state forKey:@"state"];
    }
    
    
    NSString * authUrl = [GCRequest serializeURL:kGCAuthUrl params:params];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authUrl]];
}


- (void)handleOpenURL:(NSURL *)url {
    // If the URL's structure doesn't match the structure used for Glitch authorization, ignore.
    if ([[url absoluteString] hasPrefix:GCRedirectURI]) {
        // Get the hash tag fragment from the URL
        NSString * fragment = [url fragment];
        
        // Get parameters dictionary from the hash tag fragment
        NSDictionary * params = [GCRequest deserializeParams:fragment];
        NSString * accessToken = [params valueForKey:@"access_token"];
        
        _authenticating = NO;
        
        if (accessToken)
        {
            // Successfully logged in! Yay!
            _accessToken = [accessToken copy];
            
            [self saveAccessTokenToDisk];
            
            if ([_sessionDelegate respondsToSelector:@selector(glitchLoginSuccess)])
            {
                [_sessionDelegate glitchLoginSuccess];
            }
        }
        else
        {
            // Throw ERROR!
            if ([_sessionDelegate respondsToSelector:@selector(glitchLoginFail:)])
            {
                [_sessionDelegate glitchLoginFail:nil];
            }
        }
    }
}


- (void)logout
{
    _accessToken = nil;
    [[NSFileManager defaultManager] removeItemAtPath:AccessTokenSavePath() error:nil];
    
    if ([_sessionDelegate respondsToSelector:@selector(glitchLoggedOut)])
    {
        [_sessionDelegate glitchLoggedOut];
    }
}


- (BOOL)isAuthenticated
{
    return !_authenticating && _accessToken;
}


#pragma mark - Utility

- (void)saveAccessTokenToDisk
{
    [NSKeyedArchiver archiveRootObject:_accessToken toFile:AccessTokenSavePath()];
}


#pragma mark - Interacting with the API

- (GCRequest*)requestWithMethod:(NSString*)method delegate:(id<GCRequestDelegate>)delegate params:(NSDictionary*)params additionalData:(NSDictionary*)additionalData
{
    NSMutableDictionary * requestParams = [NSMutableDictionary dictionaryWithObject:_accessToken forKey:@"oauth_token"];
    
    if (params)
    {
        [requestParams addEntriesFromDictionary:params];
    }
    
    return [GCRequest requestWithMethod:method delegate:delegate params:requestParams additionalData:additionalData];
}


- (GCRequest*)requestWithMethod:(NSString*)method delegate:(id<GCRequestDelegate>)delegate params:(NSDictionary*)params
{
    return [self requestWithMethod:method delegate:delegate params:params additionalData:nil];
}


- (GCRequest*)requestWithMethod:(NSString*)method delegate:(id<GCRequestDelegate>)delegate
{
    return [self requestWithMethod:method delegate:delegate params:nil];
}


#pragma mark - Glitch Request Delegate Methods for Checking Auth Token

// Called when request was completed
- (void)requestFinished:(GCRequest*)request withResult:(id)result
{
    // Validate we've got the right response
    if ([request.method isEqualToString:@"auth.check"])
    {
        // Perform validation on the response
        if ([result isKindOfClass:[NSDictionary class]])
        {
            // Get the status of the auth token
            id ok = [(NSDictionary*)result objectForKey:@"ok"];
            
            // Ensure that we're ok! (the number is 1)
            if (ok && [ok isKindOfClass:[NSNumber class]] && [(NSNumber*)ok boolValue])
            {
                _authenticating = NO;
                
                if ([_sessionDelegate respondsToSelector:@selector(glitchLoginSuccess)])
                {
                    [_sessionDelegate glitchLoginSuccess];
                }
                
                return;
            }
        }
    }
    
    // Otherwise remove old auth key re-auth
    [self reauth:request.additionalData];
}


// Called when request fails
- (void)requestFailed:(GCRequest*)request withError:(NSError*)error
{
    // Remove old key and reauth
    [self reauth:request.additionalData];
}


// Reauthorize with additional data
- (void)reauth:(NSDictionary*)additionalData
{
    if (additionalData)
    {
        // Remove old auth key re-auth
        _accessToken = nil;
        [[NSFileManager defaultManager] removeItemAtPath:AccessTokenSavePath() error:nil];
        
        id scope = [additionalData objectForKey:@"scope"];
        id state = [additionalData objectForKey:@"state"];
        
        [self authorizeWithScope:scope andState:state];
    }
}



@end
