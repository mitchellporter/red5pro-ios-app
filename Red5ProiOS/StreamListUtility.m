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

@end

@implementation StreamListUtility

static StreamListUtility* instance;

+(StreamListUtility*) getInstance {
    
    if(instance == nil){
        instance = [StreamListUtility alloc];
        instance.liveStreams = [[NSMutableArray alloc] init];
        instance.callCancel = false;
        instance.loopDelay = 2.5;
        instance.callQueue = 0;
    }
    
    return instance;
}

-(void) callWithReturn:(id <listListener>) listener{
    _delegate = listener;
    [self cancelLoop];
    
    [self makeCall];
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
    NSLog(@"WTFMATE15");
}

-(void) clearAndDisconnect {
    [self cancelLoop];
    
    _delegate = nil;
}

-(void) makeCall {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *domain = (NSString*)[defaults objectForKey:@"domain"];
    NSString *app = (NSString*)[defaults objectForKey:@"app"];
    
    if( domain == nil ){
        [self performSelector:@selector(callLoop:) withObject:self afterDelay:_loopDelay];
        return;
    }
    if( app == nil ){
        app = @"live";
    }
    
    NSString *url = [@"http://" stringByAppendingString:domain];
    url = [url stringByAppendingString:[@":5080/" stringByAppendingString:app]];
    url = [url stringByAppendingString:@"/streams.jsp"];
    
    int calledInQueue = _callQueue;
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(calledInQueue != _callQueue){
             return;
         }
        
        if(error){
            NSLog(@"Error,%@", [error localizedDescription]);
        }
        else{
            NSError *e = nil;
            NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
            
            [self clearStreams];
            for (NSDictionary *dict in list) {
                [_liveStreams addObject:[dict objectForKey:@"name"]];
            }
            
            if(_delegate != nil)
                [_delegate listUpdated:_liveStreams];
        }
        
         [self performSelectorOnMainThread:@selector(callLoop:) withObject:nil waitUntilDone:false];
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
