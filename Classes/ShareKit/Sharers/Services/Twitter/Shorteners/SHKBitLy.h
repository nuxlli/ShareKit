//
//  SHKBitLy.h
//  ShareKit
//
//  Created by Éverton Ribeiro on 13/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHKRequest.h"

@interface SHKBitLy : NSObject {
	id	_delegate;
	SEL _finishedSelector;
	
	NSURL *_url;
	SHKRequest *_request;
}

@property(retain) NSURL *url;
@property(retain) SHKRequest *request;

@property(assign) id delegate;
@property(assign) SEL finishedSelector;

- (id)initWithUrl:(NSURL *)url delegate:(id)delegate isFinishedSelector:(SEL)selector;
- (void)sendURLtoDelegate:(NSString *)url;
- (NSURL *)getServiceURL;
- (void)shortenURL;
- (void)shortenURLFinished:(SHKRequest *)aRequest;
- (void)resultAnalyser:(NSString *)result;

@end
