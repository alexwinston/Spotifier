//
//  Spotify.m
//  Randomify
//
//  Created by Alex Winston on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Spotify.h"

@implementation Spotify

- (id)initWithSession:(SPSession *)_session delegate:(id)_delegate {
    if ( !(self = [super init]) ) return nil;
    
    session = _session;
    delegate = _delegate;
    
    return self;
}

- (BOOL)searchWithSearchQuery:(NSString *)searchQuery {
    search = [[[SPSearch alloc] initWithSearchQuery:searchQuery inSession:session] retain];
    [self addObserver:self forKeyPath:@"search.searchInProgress" options:0 context:nil];
    
    return YES;
}

- (BOOL)browseArtist:(SPArtist *)artist type:(sp_artistbrowse_type)browseMode {
    artistBrowse = [[[SPArtistBrowse alloc] initWithArtist:artist inSession:session type:browseMode] retain];
    [self addObserver:self forKeyPath:@"artistBrowse.albums" options:0 context:nil];
    
    return YES;
}

- (BOOL)browseAlbum:(SPAlbum *)anAlbum {
    albumBrowse = [[[SPAlbumBrowse alloc] initWithAlbum:anAlbum inSession:session] retain];
    [self addObserver:self forKeyPath:@"albumBrowse.album.cover.image" options:0 context:nil];
    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%@", keyPath);
    if ([keyPath isEqualToString:@"search.searchInProgress"]) {
        [delegate SPSession:session didFinishSearch:search];
        [search release];
    } else if ([keyPath isEqualToString:@"artistBrowse.albums"]) {
        [delegate SPSession:session didFinishArtistBrowse:artistBrowse];
        [artistBrowse release];
    } else if ([keyPath isEqualToString:@"albumBrowse.album.cover.image"]) {
        if ([[albumBrowse album] coverImage] != nil) {
            NSLog(@"albumImage.image %@", [albumBrowse album].cover.image);
            [delegate SPSession:session didFinishAlbumBrowse:albumBrowse];
            [albumBrowse release];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
