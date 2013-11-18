//
//  SCTrackUser.h
//  SoundCheck
//
//  Created by Ole Krause-Sparmann on 17.11.13.
//  Copyright (c) 2013 Ole Krause-Sparmann. All rights reserved.
//

#import <JSONModel/JSONModel.h>

// We only use the user name 
@interface SCTrackUser : JSONModel

@property (copy, nonatomic) NSString *username;

@end
