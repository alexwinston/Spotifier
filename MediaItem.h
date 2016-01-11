//
//  MediaItem.h
//  TranscodingMachine
//
//  Created by Cory Powers on 3/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface MediaItem :  NSObject 
{
}
@property (nonatomic, readwrite, retain) NSString *title;
@property (nonatomic, readwrite, retain) NSString *artist;
@property (nonatomic, readwrite, retain) NSString *album;
@property (nonatomic, readwrite) NSUInteger trackNumber;
@property (nonatomic, readwrite) NSUInteger discNumber;
@property (nonatomic, readwrite) NSUInteger year;

@end


