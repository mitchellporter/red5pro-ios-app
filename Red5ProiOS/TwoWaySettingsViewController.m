//
//  TwoWaySettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/3/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "TwoWaySettingsViewController.h"
#import "SettingsViewController.h"
#import "StreamViewController.h"
#import "StreamListUtility.h"
#import "StreamTableViewCell.h"

@interface TwoWaySettingsViewController ()

@property NSArray *liveStreams;

@end

@implementation TwoWaySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.table setDelegate:self];
    [self.table setDataSource:self];
    self.liveStreams = @[];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.stream.text = [defaults objectForKey:@"stream"];
    
    [self setSubscribeBtnEnabled:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.liveStreams = [[StreamListUtility getInstance] callWithBlock:^(NSArray *streams) {
        NSMutableArray *onlyGoodStreams = [NSMutableArray arrayWithArray:streams];
        
        NSInteger idx = [onlyGoodStreams indexOfObject:self.stream.text];
        [onlyGoodStreams removeObjectAtIndex:idx];
        
        self.liveStreams = onlyGoodStreams;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

- (void) setSubscribeBtnEnabled:(BOOL)isEnabled {
    [self.subscribeBtn setEnabled:isEnabled];
    [self.subscribeBtn setAlpha:isEnabled ? 1.0f : 0.5f];
}

#pragma mark - Table

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StreamTableViewCell *cell = (StreamTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"streamCell"];
    
    cell.streamNameLbl.text = [[self liveStreams] objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.liveStreams.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StreamTableViewCell *cell = (StreamTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString *connectToStreamName = [cell.streamNameLbl text];
    NSString *streamName = self.stream.text;
    
    [self connectTo:connectToStreamName withStreamName:streamName];
    [self setSubscribeBtnEnabled:YES];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setSubscribeBtnEnabled:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"twoWaySettingsToSettings"]) {
        SettingsViewController *settingsController = (SettingsViewController *)segue.destinationViewController;
        
        if(settingsController != nil && [settingsController respondsToSelector:@selector(setCurrentMode:)]) {
            settingsController.currentMode = self.currentMode;
        }
    } else if ([segue.identifier isEqualToString:@"twoWaySettingsToStreamView"]) {
        StreamViewController *streamController = (StreamViewController *)segue.destinationViewController;
        
        if (streamController != nil && [streamController respondsToSelector:@selector(setCurrentMode:)]) {
            streamController.currentMode = self.currentMode;
        }
    }
}

- (IBAction)onSubscribeTouch:(id)sender {
    StreamTableViewCell *cell = (StreamTableViewCell *)[self.table cellForRowAtIndexPath:[self.table indexPathForSelectedRow]];
    NSString *connectToStreamName = [cell.streamNameLbl text];
    NSString *streamName = self.stream.text;
    
    [self connectTo:connectToStreamName withStreamName:streamName];
    
    [self performSegueWithIdentifier:@"twoWaySettingsToStreamView" sender:self];
}

- (IBAction)onListRefreshTouch:(id)sender {
    self.liveStreams = [[StreamListUtility getInstance] callWithBlock:^(NSArray *streams) {
        NSMutableArray *onlyGoodStreams = [NSMutableArray arrayWithArray:streams];
        
        NSInteger idx = [onlyGoodStreams indexOfObject:self.stream.text];
        [onlyGoodStreams removeObjectAtIndex:idx];
        
        self.liveStreams = onlyGoodStreams;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
}

#pragma mark - Connections

- (void) connectTo:(NSString *)connectionStreamName withStreamName:(NSString *)streamName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:streamName forKey:@"stream"];
    [defaults setObject:connectionStreamName forKey:@"connectToStream"];
    [defaults synchronize];
    
    NSLog(@"Selected %@ and publishing %@", connectionStreamName, streamName);
    //  TODO: Connect to connectionStreamName and publish streamName
}

@end
