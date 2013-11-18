//
//  SCTrackTableViewCell.h
//  SoundCheck
//
//  Created by Ole Krause-Sparmann on 17.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import <UIKit/UIKit.h>

// The track result set is visualized in a table view with cells of this type
@interface SCTrackTableViewCell : UITableViewCell

// This image view shows the track's artwork image
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;

// This label shows the track title
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

// This labels shows the name of the user that owns the track
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

// Id of the currently visualized track. This is used for the update mechanism
// when images arrive from the API to avoid reload of the whole tagble
@property (strong, nonatomic) NSString *trackId;

@end
