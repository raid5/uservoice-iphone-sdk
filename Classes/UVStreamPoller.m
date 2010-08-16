//
//  UVStreamPoller.m
//  UserVoice
//
//  Created by Scott Rutherford on 12/08/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVStreamPoller.h"
#import "UVStreamEvent.h"
#import "UVSession.h"
#import "UVClientConfig.h"

@implementation UVStreamPoller
static UVStreamPoller* _instance;

@synthesize repeatingTimer, lastPollTime;

+ (UVStreamPoller *)instance {
	@synchronized([UVStreamPoller class]) {
		if (!_instance)
			[[self alloc] init];
		
		return _instance;
	}
	
	return nil;
}

+ (id)alloc {
	@synchronized([UVStreamPoller class]) {
		NSAssert(_instance == nil, @"Attempted to allocate a second instance of a singleton.");
		_instance = [super alloc];
		return _instance;
	}
	
	return nil;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here

	}
	return self;
}

- (void)pollServer:(NSTimer*)theTimer {
	NSLog(@"Polling the UserVoice server");
	NSDate *lastEventTime;
	if (lastPollTime!=nil) {
		lastEventTime = lastPollTime;
		
	} else {
		lastEventTime = [UVSession currentSession].startTime;
	}
	
	[UVStreamEvent publicForForum:[UVSession currentSession].clientConfig.forum 
					  andDelegate:self
							since:lastEventTime];
}

- (void)didRetrievePublicStream:(NSArray *)theStream {
	NSLog(@"Got public stream");
}

- (void)didRetrievePrivateStream:(NSArray *)theStream {
	NSLog(@"Got private stream");
}

- (NSDictionary *)userInfo {
    return [NSDictionary dictionaryWithObject:[NSDate date] forKey:@"StartDate"];
}

- (BOOL)timerIsRunning {
	return self.repeatingTimer != nil;
}

- (void)startTimer {	
	if (self.repeatingTimer == nil) {
		NSLog(@"Instantiating timer to start in 120 seconds");
		
		NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:120.0];
		self.repeatingTimer = [[NSTimer alloc] initWithFireDate:fireDate
													   interval:60.0
														 target:self
													   selector:@selector(pollServer:)
													   userInfo:[self userInfo]
														repeats:YES];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:self.repeatingTimer forMode:NSDefaultRunLoopMode];
	}
}

- (void)stopTimer {
	[repeatingTimer invalidate];
    self.repeatingTimer = nil;
}

@end