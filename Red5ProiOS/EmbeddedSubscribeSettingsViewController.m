//
//  EmbeddedSubscribeSettingsViewController.m
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import "EmbeddedSubscribeSettingsViewController.h"
#import "StreamTableViewCell.h"
#import "ALToastView.h"

@interface EmbeddedSubscribeSettingsViewController ()

@property NSArray *liveStreams;

@end

@implementation EmbeddedSubscribeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.stream.delegate = self;
    self.stream.dataSource = self;
    
    self.liveStreams = @[];
    
    self.doneBtn.enabled = NO;
    self.doneBtn.alpha = 0.5f;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.settingsViewController != nil) {
        if (self.settingsViewController.currentMode == r5_example_stream) {
            [[StreamListUtility getInstance] callWithBlock:^(NSArray *streams) {
                [self updateTableDataWithArray:streams];
            }];
            
            [[StreamListUtility getInstance] callWithReturn:self];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[StreamListUtility getInstance] clearAndDisconnect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

#pragma mark - IBActions

- (IBAction) onAdvancedTouch:(id)sender {
    if (self.settingsViewController != nil) {
        [self.settingsViewController goToAdvancedForCurrentMode];
    }
}

- (IBAction) onDoneTouch:(id)sender {
    NSIndexPath *selected = [self.stream indexPathForSelectedRow];
    if (selected != nil) {
        if (self.settingsViewController != nil) {
            [self.settingsViewController doneSettings];
        }
    }
}

#pragma mark - Table

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StreamTableViewCell *cell = (StreamTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"streamCell"];
    
    NSInteger idx = indexPath.row;
    cell.streamNameLbl.text = (idx != NSNotFound && idx < self.liveStreams.count) ? [self.liveStreams objectAtIndex:idx] : @"Whoops! Hold on...";
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.liveStreams.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StreamTableViewCell *cell = (StreamTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString *connectToStreamName = [cell.streamNameLbl text];
    
    [self.doneBtn setAlpha:1.0f];
    [self.doneBtn setEnabled:YES];
    
    [self connectTo:connectToStreamName];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.doneBtn.alpha = 0.5f;
    self.doneBtn.enabled = NO;
}

#pragma mark - Connections

- (void) connectTo:(NSString *)connectionStreamName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:connectionStreamName forKey:@"connectToStream"];
    [defaults synchronize];
}

#pragma mark - List Listener

- (void) updateTableDataWithArray:(NSArray *)array {
    NSIndexPath *selected = [self.stream indexPathForSelectedRow];
    StreamTableViewCell *cell = selected ? [self.stream cellForRowAtIndexPath:selected] : nil;
    NSString *selectedLabel = cell ? cell.streamNameLbl.text : nil;
    
    self.liveStreams = array;
    
    NSInteger selectedIdx = selectedLabel ? [array indexOfObject:selectedLabel] : NSNotFound;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.liveStreams.count == 1) {
            self.streamsAvailableLbl.text = @"1 STREAM";
        } else {
            self.streamsAvailableLbl.text = [NSString stringWithFormat:@"%lu STREAMS", (unsigned long)self.liveStreams.count];
        }
        
        [self.stream reloadData];
        
        if (selectedIdx != NSNotFound) {
            NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForRow:selectedIdx inSection:0];
            [self.stream selectRowAtIndexPath:newSelectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    });
}

- (void) listUpdated:(NSArray *)updatedList {
    [self updateTableDataWithArray:updatedList];
}

- (void) listError:(NSError *)error {
    if (self.settingsViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ALToastView toastInView:self.settingsViewController.view withText:error.localizedDescription];
        });
    }
}

@end
