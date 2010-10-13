//
//  SHKZaptIn.m
//  ShareKit
//
//  Created by Éverton Ribeiro on 13/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SHKZaptIn.h"
#import "SHK.h"

@implementation SHKZaptIn

- (NSURL *)getServiceURL
{
	return [NSURL URLWithString:[NSMutableString stringWithFormat:@"http://zapt.in/api/links/shorten?version=1.0&login=%@&key=%@&longUrl=%@&format=text",
								 SHKZaptInLogin,
								 SHKZaptInKey,																		  
								 SHKEncodeURL(self.url)
								 ]];
}

- (void)resultAnalyser:(NSString *)result
{
	///if already a bitly login, use url instead
	if ([result isEqualToString:@"207, There was a problem posting your request. Please try again., ERROR"])
		result = [self.url.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[self sendURLtoDelegate:result];
}

@end
