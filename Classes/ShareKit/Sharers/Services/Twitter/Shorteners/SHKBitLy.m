//
//  SHKBitLy.m
//  ShareKit
//
//  Created by Éverton Ribeiro on 13/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SHKBitLy.h"
#import "SHK.h"

@implementation SHKBitLy

@synthesize url = _url;
@synthesize request = _request;
@synthesize delegate = _delegate;
@synthesize finishedSelector = _finishedSelector;

- (id)initWithUrl:(NSURL *)url delegate:(id)delegate isFinishedSelector:(SEL)selector
{
	if (self = [super init])
	{
		NSLog(@"init short: %@", url.absoluteString);
		self.url = url;
		self.delegate = delegate;
		self.finishedSelector = selector;
		[self shortenURL];
	}
	
	return self;
}

- (void)dealloc 
{
	[_url release];
	[_request release];
	[super dealloc];
}

#pragma mark Shortening url

- (NSURL *)getServiceURL
{
	return [NSURL URLWithString:[NSMutableString stringWithFormat:@"http://api.bit.ly/v3/shorten?login=%@&apikey=%@&longUrl=%@&format=txt",
								 SHKBitLyLogin,
								 SHKBitLyKey,																		  
								 SHKEncodeURL(self.url)
								 ]];
}

- (void)sendURLtoDelegate:(NSString *)url
{
	if ([self.delegate respondsToSelector:self.finishedSelector])
		[self.delegate performSelector:self.finishedSelector withObject:url];
}

- (void)shortenURL
{	
	if (![SHK connected])
	{
		[self sendURLtoDelegate:[self.url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		return;
	}
	
	self.request = [[SHKRequest alloc] initWithURL:[self getServiceURL]
											 params:nil
										   delegate:self
								 isFinishedSelector:@selector(shortenURLFinished:)
											 method:@"GET"
										  autostart:YES];
}

- (void)shortenURLFinished:(SHKRequest *)aRequest
{
	
	NSString *result = [[aRequest getResult] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	NSLog(@"result short: %@", result);
	
	if (result == nil || [NSURL URLWithString:result] == nil)
	{
		// TODO - better error message
		[[[[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Shorten URL Error")
									 message:SHKLocalizedString(@"We could not shorten the URL.")
									delegate:nil
						   cancelButtonTitle:SHKLocalizedString(@"Continue")
						   otherButtonTitles:nil] autorelease] show];
		
		[self sendURLtoDelegate:[self.url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	
	else
	{
		[self resultAnalyser:result];
	}
}

- (void)resultAnalyser:(NSString *)result
{
	///if already a bitly login, use url instead
	if ([result isEqualToString:@"ALREADY_A_BITLY_LINK"])
		result = [self.url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[self sendURLtoDelegate:result];
}

@end
