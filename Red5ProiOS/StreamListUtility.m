//
//  StreamListUtility.m
//  Red5Pro
//
//  Created by David Heimann on 5/2/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "StreamListUtility.h"

@interface StreamListUtility()

@property BOOL callCancel;
@property int callQueue;

@property NSArray *cachedStreams;

@end

@implementation StreamListUtility

static StreamListUtility* instance;

- (NSString *) setting:(NSString *)setting WithDefault:(NSString *)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *theSetting = [defaults objectForKey:setting];
    
    if (theSetting == nil)
        return value;
    
    return theSetting;
}

+(StreamListUtility*) getInstance {
    if (instance == nil) {
        instance = [StreamListUtility alloc];
        instance.liveStreams = [[NSMutableArray alloc] init];
        instance.callCancel = false;
        instance.loopDelay = 2.5;
        instance.callQueue = 0;
        instance.cachedStreams = @[];
    }
    
    return instance;
}

-(void) callWithReturn:(id <listListener>) listener{
    _delegate = listener;
    [self cancelLoop];
    
    [self makeCall];
}

-(NSArray *) callWithBlock:(void (^)(NSArray *streams))block {
    [self makeCallWithBlock:^(NSArray *streams) {
        self.cachedStreams = streams;
        
        block(streams);
    }];
    
    return self.cachedStreams;
}

-(void) callStreamsOnce {
    [self cancelLoop];
    _callCancel = true;
    
    [self makeCall];
}

-(void) callInLoop{
    [self makeCall];
}

-(void) cancelLoop {
    _callQueue++;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void) clearAndDisconnect {
    [self cancelLoop];
    
    _delegate = nil;
}

-(void) makeCall {
    NSString *domain = [self setting:@"domain" WithDefault:@"127.0.0.1"];
    NSString *app = [self setting:@"app" WithDefault:@"live"];
    
    if ([domain isEqualToString:@"127.0.0.1"]) {
        [self performSelector:@selector(callLoop:) withObject:self afterDelay:_loopDelay];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@:5080/%@/streams.jsp", domain, app];
    
    int calledInQueue = _callQueue;
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (calledInQueue != _callQueue) {
                                   return;
                               }
                               
                               if (error) {
                                   NSLog(@"Error, %@", [error localizedDescription]);
                                   if (_delegate != nil) {
                                       [_delegate listError:error];
                                   }
                               } else {
                                   NSError *e = nil;
                                   NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
                                   
                                   [self clearStreams];
                                   for (NSDictionary *dict in list) {
                                       [_liveStreams addObject:[dict objectForKey:@"name"]];
                                   }
                                   
                                   if (_delegate != nil)
                                       [_delegate listUpdated:_liveStreams];
                               }
                             
                               [self performSelectorOnMainThread:@selector(callLoop:) withObject:nil waitUntilDone:false];
                           }];
}

-(void) makeCallWithBlock:(void (^)(NSArray *streams))block {
    NSString *domain = [self setting:@"domain" WithDefault:@"127.0.0.1"];
    NSString *app = [self setting:@"app" WithDefault:@"live"];
    
    if ([domain isEqualToString:@"127.0.0.1"]) {
        [self performSelector:@selector(callLoop:) withObject:self afterDelay:_loopDelay];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@:5080/%@/streams.jsp", domain, app];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   NSLog(@"Error, %@", [error localizedDescription]);
                                   if (_delegate != nil) {
                                       [_delegate listError:error];
                                   }
                               } else {
                                   NSError *e = nil;
                                   NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
                                   NSMutableArray *streams = [[NSMutableArray alloc] init];
                                   
                                   [self clearStreams];
                                   for (NSDictionary *dict in list) {
                                       [streams addObject:[dict objectForKey:@"name"]];
                                   }
                                   
                                   block(streams);
                               }
                           }];
}

-(void) callLoop:(id)sender{
    [self performSelector:@selector(makeCall) withObject:nil afterDelay: _loopDelay];
}

-(void) clearStreams {
    if(_liveStreams == nil)
        _liveStreams = [[NSMutableArray alloc] init];
    
    [_liveStreams removeAllObjects];
}

@end
