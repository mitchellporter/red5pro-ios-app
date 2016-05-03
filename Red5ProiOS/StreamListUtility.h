//
//  StreamListUtility.h
//  Red5Pro
//
//  Created by David Heimann on 5/2/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//


//delegate interface to receive updates to the liveStreams array
@protocol listListener <NSObject>

-(void)listUpdated:(NSArray*)updatedList;

@end

@interface StreamListUtility : NSObject

@property NSMutableArray* liveStreams;

//listener that will recieve updates
@property id<listListener> delegate;

@property float loopDelay;

//get utility instance - singleton application
+(StreamListUtility*) getInstance;

//set delegate and begin a loop to get the list of streams
-(void) callWithReturn:(id<listListener>) listener;

-(void) callStreamsOnce;

-(void) callInLoop;

//cancel a loop of calls
-(void) cancelLoop;

//cancel loop, remove delegate
-(void) clearAndDisconnect;

-(void) clearStreams;

@end

//simple use -
//getInstance
//callWithReturn
//(delegate updates list view when update is pushed to it)
//clearAndDisconnect when done
