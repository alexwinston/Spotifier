//
//  Test.h
//  Pandora
//
//  Created by Alex Winston on 6/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "SPAlbum.h"
#include "SPTrack.h"
#include "MediaItem.h"


@interface Test : NSObject {
}
+ (Test*)test;
- (void)tagFile:(NSString *)filename withTrack:(SPTrack *)track;
- (void)tagFile:(NSString *)filename withMetadata:(MediaItem *)anItem;
- (void)tagFile:(NSString *)filename withCoverFilename:(NSString *)coverFilename;
@end
