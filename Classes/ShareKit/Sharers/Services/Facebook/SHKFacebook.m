//
//  SHKFacebook.m
//  ShareKit
//
//  Created by Nathan Weiner on 6/18/10.

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKFacebook.h"

@interface SHKFacebook (Private)

- (void)sendImage;

@end


@implementation SHKFacebook

@synthesize facebook;
@synthesize pendingFacebookAction;

- (id)init
{
	if (self = [super init]) {
		facebook = [[Facebook alloc] init];
	}
	return self;
}

- (void)dealloc
{
	facebook.sessionDelegate = nil;
	[facebook release];
	[super dealloc];
}


#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle
{
	return @"Facebook";
}

+ (BOOL)canShareURL
{
	return YES;
}

+ (BOOL)canShareText
{
	return YES;
}

+ (BOOL)canShareImage
{
	return YES;
}

+ (BOOL)canShareOffline
{
	return NO; // TODO - would love to make this work
}

#pragma mark -
#pragma mark Configuration : Dynamic Enable

- (BOOL)shouldAutoShare
{
	return YES; // FBConnect presents its own dialog
}

#pragma mark -
#pragma mark Authentication

- (BOOL)isAuthorized
{	
	if([facebook isSessionValid])
		return YES;
	else
		return NO;
}

- (void)promptAuthorization
{
	self.pendingFacebookAction = SHKFacebookPendingLogin;
	
	NSArray* permissions =  [[NSArray arrayWithObjects: 
                      @"publish_stream", @"read_stream", @"offline_access", @"photo_upload" ,nil] retain];
	
	[facebook authorize:SHKFacebookKey permissions:permissions delegate:self];

}

- (void)authFinished:(SHKRequest *)request
{		
	
}

- (void)logout
{
	[facebook logout:self];
}

#pragma mark -
#pragma mark Share API Methods

- (NSString*)actionLinksString {
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys: 
														   SHKMyAppName,@"text",SHKMyAppURL,@"href", nil], nil];
	return [jsonWriter stringWithObject:actionLinks];
}

- (BOOL)send
{			
	if (item.shareType == SHKShareTypeURL || item.shareType == SHKShareTypeText )
	{
		SBJSON *jsonWriter = [[SBJSON new] autorelease];
				
		NSMutableDictionary* attachment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									item.title, @"name", nil];
		
		if ([item customValueForKey:@"caption"]) {
			[attachment setObject:[item customValueForKey:@"caption"] forKey:@"caption"];
		}
		
		if(item.shareType == SHKShareTypeURL) {
			[attachment setObject:[item.URL absoluteString] forKey:@"href"];
			
			if ([item customValueForKey:@"description"]) {
				[attachment setObject:[item customValueForKey:@"description"] forKey:@"description"];
			}
			
		} else if(item.shareType == SHKShareTypeText) {
			[attachment setObject:item.text forKey:@"description"];
		}
		
		if(item.image) {
			[attachment setObject:UIImageJPEGRepresentation(item.image,1.0) forKey:@"picture"];
		}
		

		NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
		
		
		NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   SHKFacebookKey, @"api_key",
									   SHKLocalizedString(@"Enter your message:"),  @"user_message_prompt",
									   [self actionLinksString], @"action_links",
									   attachmentStr, @"attachment",
									   nil];
		
		NSLog(@"AY: %@", params);
		
		
		
		self.pendingFacebookAction = SHKFacebookPendingStatus;
		
		[facebook dialog: @"stream.publish"
				andParams: params
			  andDelegate:self];

	}
	
	else if (item.shareType == SHKShareTypeImage)
	{		
		[self sendImage];
	}
	
	return YES;
}

- (void)sendImage
{
	[self sendDidStart];
	
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									UIImageJPEGRepresentation(item.image,1.0), @"picture",
									item.title, @"caption",
									nil];
	[facebook requestWithMethodName: @"photos.upload" 
						   andParams: params
					   andHttpMethod: @"POST" 
						 andDelegate: self];
}

- (void)dialogDidSucceed:(FBDialog*)dialog
{
	[self sendDidFinish];
}

- (void)dialogDidCancel:(FBDialog*)dialog
{
	if (pendingFacebookAction == SHKFacebookPendingStatus)
		[self sendDidCancel];
}

- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL*)url
{
	return YES;
}


#pragma mark FBSessionDelegate methods

-(void) fbDidLogin
{
	// Try to share again
	if (pendingFacebookAction == SHKFacebookPendingLogin)
	{
		self.pendingFacebookAction = SHKFacebookPendingNone;
		[self share];
	}
}

- (void)fbDidNotLogin:(BOOL)cancelled
{	
}


-(void) fbDidLogout
{
}


#pragma mark FBRequestDelegate methods

- (void)request:(FBRequest*)aRequest didLoad:(id)result 
{
	//if ([aRequest. isEqualToString:@"facebook.photos.upload"]) 
	//{
		// PID is in [result objectForKey:@"pid"];
		[self sendDidFinish];
	//}
}

- (void)request:(FBRequest*)aRequest didFailWithError:(NSError*)error 
{
	[self sendDidFailWithError:error];
}



@end
