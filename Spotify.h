//
//  Spotify.h
//  Randomify
//
//  Created by Alex Winston on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"

@protocol SPSpotifyDelegate;
@interface Spotify : NSObject {
    SPSession *session;
    id<SPSpotifyDelegate> delegate;
    
    @private
    SPSearch *search;
    SPArtistBrowse *artistBrowse;
    SPAlbumBrowse *albumBrowse;
    SPImage *albumImage;
}
- (id)initWithSession:(SPSession *)session delegate:(id)delegate;
- (BOOL)searchWithSearchQuery:(NSString *)searchQuery;
- (BOOL)browseArtist:(SPArtist *)anArtist type:(sp_artistbrowse_type)browseMode;
- (BOOL)browseAlbum:(SPAlbum *)anAlbum;
@end

@protocol SPSpotifyDelegate <NSObject>
@optional
- (void)SPSession:(SPSession *)session didFinishSearch:(SPSearch *)search;
- (void)SPSession:(SPSession *)session didFinishArtistBrowse:(SPArtistBrowse *)artistBrowse;
- (void)SPSession:(SPSession *)session didFinishAlbumBrowse:(SPAlbumBrowse *)albumBrowse;
@end
