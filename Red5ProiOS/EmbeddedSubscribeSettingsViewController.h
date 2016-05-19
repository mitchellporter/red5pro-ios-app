//
//  EmbeddedSubscribeSettingsViewController.h
//  Red5Pro
//
//  Created by Kyle Kellogg on 5/18/16.
//  Copyright © 2016 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmbeddedSettingsViewController.h"
#import "StreamListUtility.h"

@interface EmbeddedSubscribeSettingsViewController : EmbeddedSettingsViewController<UITableViewDataSource, UITableViewDelegate, listListener>

@property (weak, nonatomic) IBOutlet UITableView *stream;

@property (weak, nonatomic) IBOutlet UILabel *streamsAvailableLbl;

@property (weak, nonatomic) IBOutlet UIButton *advancedBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@end
