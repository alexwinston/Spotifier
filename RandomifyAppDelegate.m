/**
 * Copyright (c) 2006-2010 Spotify Ltd
 * This file is part of the libspotify examples suite.
 * See RandomifyAppDelegate.h for license.
 */

#import "RandomifyAppDelegate.h"
#import "Test.h"

@implementation RandomifyAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] 
											   userAgent:@"com.spotify.SPSession"
												   error:nil];
    [[SPSession sharedSession] setDelegate:self];
    [[SPSession sharedSession] setAudioDeliveryDelegate:self];
    [[SPSession sharedSession] setPlaybackDelegate:self];
    
    inputFormat.mFormatID = kAudioFormatLinearPCM;
    inputFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
    inputFormat.mSampleRate = 44100;
    inputFormat.mChannelsPerFrame = 2;
    inputFormat.mFramesPerPacket = 1;
    inputFormat.mBytesPerFrame = sizeof(short) * inputFormat.mChannelsPerFrame;
    inputFormat.mBytesPerPacket = inputFormat.mBytesPerFrame;
    inputFormat.mBitsPerChannel = (inputFormat.mBytesPerFrame * 8) / inputFormat.mChannelsPerFrame;
    
    queuedTracks = [[NSMutableArray array] retain];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(downloadTracks:)
                                   userInfo:nil
                                    repeats:YES];
}

#pragma mark -
#pragma mark SPSessionPlaybackDelegate Methods

- (NSInteger)session:(id <SPSessionPlaybackProvider>)aSession shouldDeliverAudioFrames:(const void *)audioFrames
            ofCount:(NSInteger)frameCount
  streamDescription:(AudioStreamBasicDescription)audioDescription {

	audio_fifo_data_t *afd = NULL;
	size_t s;
    
	if (frameCount == 0)
		return 0; // Audio discontinuity, do nothing
    
	s = frameCount * sizeof(int16_t) * audioDescription.mChannelsPerFrame;
    
	afd = malloc(sizeof(audio_fifo_data_t) + s);
	memcpy(afd->samples, audioFrames, s);
    
	afd->nsamples = frameCount;
    
	afd->rate = audioDescription.mSampleRate;
	afd->channels = audioDescription.mChannelsPerFrame;
    
//    printf("%lld\n", currentPacket);
    AudioFileWritePackets(audioFile, false, frameCount, NULL, currentPacket / audioDescription.mBytesPerPacket, (UInt32 *) &frameCount, afd->samples);
//    [audioData appendBytes:afd->samples length:s];
    currentPacket += frameCount * audioDescription.mBytesPerPacket;
    
    free(afd);
	return frameCount;
}

- (void)sessionDidEndPlayback:(id <SPSessionPlaybackProvider>)aSession {
    NSLog(@"sessionDidEndPlayback");
//    unsigned int    length = [audioData length] / sizeof(float);
//    void            *outBytes = [audioData mutableBytes]; //[outData mutableBytes];
//    UInt32          outBytesLength = [audioData length]; //[outData length];
 
//    OSStatus err = AudioFileWriteBytes(audioFile, 0, 0, &outBytesLength, outBytes);
//    if (noErr != err) {
//        [NSException raise:@"AudioFileWriteBytes" format:@"AudioFileWriteBytes failed (status=%d)", err];
//    }
    
    AudioFileClose(audioFile);
    
    [self convertTrack:currentTrack];
}

#pragma mark -
#pragma mark SPSessionDelegate Methods

- (void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
    NSLog(@"sessionDidLoginSuccessfully");
}

- (void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
	[window presentError:error];
}

#pragma mark -
#pragma mark TPAACAudioConverterDelegate Methods

- (void)AACAudioConverterDidFinishConversion:(TPAACAudioConverter *)converter {
    NSLog(@"AACAudioConverterDidFinishConversion");

    [[Test test] tagFile:[converter destination]
               withTrack:currentTrack];
    
    isDownloading = NO;
    
    [currentTrackName setStringValue:@""];
}

- (void)AACAudioConverter:(TPAACAudioConverter*)converter didFailWithError:(NSError *)error {
    NSLog(@"AACAudioConverter:didFailWithError %@", [error description]);
}

#pragma mark -

- (IBAction)login:(id)sender;
{    
    [[SPSession sharedSession] attemptLoginWithUserName:[username stringValue]
                                               password:[password stringValue]
                                    rememberCredentials:NO];
//    [[SPSession sharedSession] setPreferredBitrate:1]; // 320000
    
    spotify = [[[Spotify alloc] initWithSession:[SPSession sharedSession] delegate:self] retain];
    
    [downloadButton setEnabled:YES];
}

- (IBAction)download:(id)sender {
//    [spotify searchWithSearchQuery:@"artist:josh+garrels"];
    
//    [spotify browseArtist:[SPArtist artistWithArtistURL:[NSURL URLWithString:@"spotify:artist:7mnBLXK823vNxN3UWB7Gfz"]]
//                                                   type:SP_ARTISTBROWSE_NO_TRACKS];
    
    [spotify browseAlbum:[SPAlbum albumWithAlbumURL:[NSURL URLWithString:[albumURL stringValue]]
                                          inSession:[SPSession sharedSession]]];
}

- (void)SPSession:(SPSession *)session didFinishSearch:(SPSearch *)search {
    for (SPArtist *artist in [search artists]) {
        NSLog(@"%@ %@", [artist name], [artist spotifyURL]);
        [spotify browseArtist:artist type:SP_ARTISTBROWSE_NO_TRACKS];
    }
    
    for (SPAlbum *album in [search albums]) {
        NSLog(@"%@ %@ %d", [album name], [album spotifyURL], [album isAvailable]);
    }
    
    for (SPTrack *track in [search tracks]) {
        NSLog(@"%@ %@ %d", [track name], [track spotifyURL], [track availability]);
    }
}
- (void)SPSession:(SPSession *)session didFinishArtistBrowse:(SPArtistBrowse *)artistBrowse {
    for (SPAlbum *album in [artistBrowse albums]) {
//        if ([album isAvailable])
            NSLog(@"%@ %@ %d", [album name], [album spotifyURL], [album isAvailable]);
    }
}

- (void)SPSession:(SPSession *)session didFinishAlbumBrowse:(SPAlbumBrowse *)albumBrowse {
    for (SPTrack *track in [albumBrowse tracks]) {
        NSLog(@"%@ %@ %d", [track name], [track spotifyURL], [track availability]);
        [queuedTracks addObject:track];
    }
    
    queuedTracksTotal = [queuedTracks count];
    queuedTracksCount = 0;
    [queueProgress setMaxValue:[queuedTracks count]];
}

#pragma mark -

- (void)downloadTracks:(id)sender {
    if (!isDownloading && [queuedTracks count] > 0) {
        isDownloading = YES;
        
        [queueProgress setDoubleValue:++queuedTracksCount];
        [queueProgress setNeedsDisplay:YES];
        
        [self downloadTrack:[queuedTracks objectAtIndex:0]];
        [queuedTracks removeObjectAtIndex:0];
    }
}

- (void)downloadTrack:(SPTrack *)track {
    NSLog(@"%@ %@ %d", [track name], [track spotifyURL], [track availability]);
    [currentTrackName setStringValue:[NSString stringWithFormat:@"%@, %@", [[track album] name], [track name]]];
    
    char *filename = "/Users/alexwinston/Desktop/spotify.wav";
    CFURLRef fileURL = CFURLCreateFromFileSystemRepresentation(NULL, (UInt8 *) filename, strlen(filename), false);
    
    if (noErr != AudioFileCreateWithURL(fileURL, kAudioFileWAVEType, &inputFormat, kAudioFileFlags_EraseFile, &audioFile))
        puts("AudioFileCreateWithURL failed");
    
    [self playTrack:track];
}

- (void)playTrack:(SPTrack *)track {
	if (track != nil) {
        if (!track.isLoaded) {
            // Since we're trying to play a brand new track that may not be loaded, 
            // we may have to wait for a moment before playing. Tracks that are present 
            // in the user's "library" (playlists, starred, inbox, etc) are automatically loaded
            // on login. All this happens on an internal thread, so we'll just try again in a moment.
            [self performSelector:@selector(playTrack:) withObject:track afterDelay:0.1];
            return;
        }
        
        if (currentTrack != nil) {
            [currentTrack release];
            currentTrack = nil;
        }
        currentTrack = [track retain];
        currentPacket = 0;
        
        NSError *error = nil;
        if (![[SPSession sharedSession] playTrack:track error:&error]) {
            [window presentError:error];
        }
        NSLog(@"playTrack");
        
        return;
    }
}

- (void)convertTrack:(SPTrack *)track {
    NSString *artist = [[[[track album] artist] name] stringByReplacingOccurrencesOfString:@"/" withString:@":"];
    NSString *album = [[[track album] name] stringByReplacingOccurrencesOfString:@"/" withString:@":"];
    NSString *directory = [[NSString stringWithFormat:@"~/Desktop/%@/%@", artist, album] stringByExpandingTildeInPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *destinationFilename = [directory stringByAppendingFormat:@"/%d - %@.m4a",
                                     [track trackNumber],
                                     [[track name] stringByReplacingOccurrencesOfString:@"/" withString:@":"]];
    
    if (audioConverter != nil) {
        [audioConverter release];
        audioConverter = nil;
    }
    audioConverter = [[[TPAACAudioConverter alloc] initWithDelegate:self
                                                             source:@"/Users/alexwinston/Desktop/spotify.wav"
                                                        destination:destinationFilename] retain];
    [audioConverter start];
}

@end
