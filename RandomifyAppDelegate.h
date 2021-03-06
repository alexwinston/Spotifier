/**
 * Copyright (c) 2006-2010 Spotify Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * This example application show how to use libspotify in a Mac OS X
 * application, playing randomly from your Starred playlist.
 *
 * This file is part of the libspotify examples suite.
 */

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CocoaLibSpotify.h"
#import "TPAACAudioConverter.h"
#import "Spotify.h"

const uint8_t g_appkey[] = {
	0x01, 0xFE, 0x41, 0x13, 0xCC, 0xF2, 0x50, 0x32, 0x6C, 0xD8, 0xD2, 0x6B, 0x87, 0xFA, 0xFB, 0x45,
	0xAE, 0x69, 0xF8, 0x2A, 0x17, 0x3A, 0xBB, 0x95, 0xA0, 0x57, 0x27, 0x7A, 0x9B, 0xA1, 0x47, 0x7C,
	0x05, 0xBD, 0x9C, 0x00, 0x53, 0xF7, 0xB9, 0xC4, 0x3F, 0x31, 0xC3, 0xE6, 0x9A, 0xD8, 0x5A, 0x50,
	0xFF, 0x71, 0xDF, 0x63, 0xA8, 0x81, 0x33, 0x13, 0x27, 0x74, 0xBC, 0x30, 0x62, 0x1E, 0x85, 0x85,
	0xD2, 0x3C, 0x68, 0x1E, 0xD8, 0xFC, 0x5E, 0xA2, 0x31, 0xDA, 0xC1, 0xF2, 0x11, 0xCF, 0x96, 0xFD,
	0x75, 0x91, 0xF9, 0xD2, 0x22, 0xAA, 0x32, 0xE3, 0x02, 0xB4, 0x1A, 0x5C, 0x2B, 0x3D, 0x6F, 0x71,
	0x51, 0x3E, 0x23, 0xA0, 0x0B, 0xD9, 0xB2, 0x36, 0x73, 0x19, 0x0F, 0xAA, 0xDF, 0x04, 0x25, 0x64,
	0x80, 0x64, 0x9C, 0x94, 0x5B, 0x29, 0x7D, 0xF0, 0x70, 0x32, 0x63, 0x80, 0x53, 0x6E, 0xC6, 0x46,
	0x58, 0x92, 0xFA, 0xE0, 0xD8, 0x3F, 0x47, 0x26, 0xAD, 0x42, 0x55, 0xA1, 0x91, 0x84, 0x74, 0x10,
	0xF3, 0xD0, 0x35, 0x7E, 0xF4, 0x4D, 0x3F, 0x71, 0x3D, 0x60, 0x88, 0x1F, 0x73, 0x81, 0x9E, 0x0D,
	0xBA, 0xB4, 0xE4, 0x11, 0xFA, 0xA4, 0x16, 0x6C, 0x5B, 0xB9, 0x87, 0x8D, 0x30, 0xC9, 0x3C, 0x54,
	0xFC, 0xC2, 0x8B, 0x29, 0x84, 0x24, 0x9A, 0xE1, 0x97, 0xE7, 0xBF, 0x54, 0xE3, 0xDB, 0x8D, 0xE7,
	0x98, 0xEF, 0x39, 0x9C, 0xFB, 0xDA, 0xEE, 0x79, 0x86, 0xBF, 0x6B, 0xDE, 0xE1, 0x59, 0x5C, 0x46,
	0xD4, 0x57, 0x19, 0x49, 0x7D, 0x4B, 0xDE, 0x28, 0x13, 0xBA, 0x7F, 0xEC, 0xBA, 0x38, 0x2B, 0xFE,
	0x9C, 0x6B, 0xBD, 0x1B, 0xF2, 0x65, 0x23, 0x4D, 0xFE, 0x3A, 0x92, 0x17, 0x2F, 0xB5, 0x12, 0xE0,
	0x12, 0x9B, 0xAD, 0x80, 0xD0, 0x85, 0x35, 0x7C, 0x19, 0x60, 0xC1, 0x16, 0xDF, 0xBE, 0xF8, 0xC8,
	0x97, 0x80, 0xF8, 0x80, 0xCF, 0x7A, 0xFB, 0x79, 0xAE, 0x8B, 0x45, 0x89, 0xCB, 0x40, 0x33, 0x78,
	0x53, 0x7E, 0xF6, 0xFF, 0x4F, 0x19, 0x7D, 0x46, 0xCC, 0xEA, 0xA2, 0x8A, 0xED, 0xDD, 0xEF, 0xC6,
	0xA0, 0xE2, 0x3E, 0xC0, 0x7B, 0xEC, 0x52, 0x27, 0xDC, 0x7B, 0xE6, 0xD4, 0xBB, 0x47, 0xC0, 0x3F,
	0x85, 0x82, 0x74, 0x05, 0x94, 0x36, 0x45, 0x85, 0x58, 0x9E, 0x06, 0x5F, 0x56, 0x87, 0xDA, 0xC2,
	0xF7,
};
const size_t g_appkey_size = sizeof(g_appkey);

typedef struct audio_fifo_data {
	int channels;
	int rate;
	int nsamples;
	int16_t samples[0];
} audio_fifo_data_t;

@interface RandomifyAppDelegate : NSObject<SPSessionDelegate, SPSessionPlaybackDelegate, SPSessionAudioDeliveryDelegate,
                                            SPSpotifyDelegate, TPAACAudioConverterDelegate>
{
    Spotify *spotify;
    
    NSMutableArray *queuedTracks;
    int queuedTracksTotal;
    int queuedTracksCount;
    
    SPTrack *currentTrack;
    BOOL isDownloading;

    AudioStreamBasicDescription inputFormat;
    TPAACAudioConverter *audioConverter;

    AudioFileID audioFile;
//    NSMutableData *audioData;
    SInt64      currentPacket;
    
    IBOutlet NSWindow *window;
	IBOutlet NSTextField *username;
	IBOutlet NSTextField *password;
    IBOutlet NSTextField *albumURL;
    IBOutlet NSButton *downloadButton;
    IBOutlet NSTextField *currentTrackName;
    IBOutlet NSProgressIndicator *queueProgress;
}
- (IBAction)login:(id)sender;
- (IBAction)download:(id)sender;

- (void)downloadTracks:(id)sender;
- (void)downloadTrack:(SPTrack *)track;
- (void)playTrack:(SPTrack *)track;
- (void)convertTrack:(SPTrack *)track;
@end
