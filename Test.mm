//
//  Test.mm
//  Pandora
//
//  Created by Alex Winston on 6/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Test.h"


@implementation Test

+ (Test*)test {
    return [[[Test alloc] init] autorelease];
}

- (void)tagFile:(NSString *)filename withTrack:(SPTrack *)track {
    NSImage *coverImage = [[track album] coverImage];
    NSArray *imageRepresentations = [coverImage representations];		
    NSData *bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:imageRepresentations 
                                                                  usingType:NSJPEGFileType
                                                                 properties:nil];
    
    [bitmapData writeToFile:@"/Users/alexwinston/Desktop/spotify.png" atomically:NO];
    
    MediaItem *metadata = [[[MediaItem alloc] init] autorelease];
    metadata.title = [track name];
    metadata.artist = [[[track album] artist] name];
    metadata.album = [[track album] name];
    metadata.trackNumber = [track trackNumber];
    metadata.discNumber = [track discNumber];
    metadata.year = [[track album] year];
    
    [[Test test] tagFile:filename withMetadata:metadata];
    [[Test test] tagFile:filename withCoverFilename:@"/Users/alexwinston/Desktop/spotify.png"];
}

- (void)tagFile:(NSString *)filename withMetadata:(MediaItem *)anItem {
    NSLog(@"tagFile:%@", filename);

    NSTask *metadataTask = [[[NSTask alloc] init] autorelease];
    
    NSMutableArray *taskArgs = [NSMutableArray array];
    if ([anItem title] != [NSString string]) {
        [taskArgs addObject:@"-s"];
        [taskArgs addObject:[anItem title]];
    }
    if ([anItem artist] != [NSString string]) {
        [taskArgs addObject:@"-a"];
        [taskArgs addObject:[anItem artist]];
    }
    if ([anItem album] != [NSString string]) {
        [taskArgs addObject:@"-A"];
        [taskArgs addObject:[anItem album]];
    }
    [taskArgs addObject:@"-t"];
    [taskArgs addObject:[NSString stringWithFormat:@"%d", [anItem trackNumber]]];
    [taskArgs addObject:@"-d"];
    [taskArgs addObject:[NSString stringWithFormat:@"%d", [anItem discNumber]]];
    [taskArgs addObject:@"-y"];
    [taskArgs addObject:[NSString stringWithFormat:@"%d", [anItem year]]];
    
    [taskArgs addObject:filename];
    
    NSLog(@"NSTask: %@", [taskArgs componentsJoinedByString:@" "]);
    [metadataTask setArguments:taskArgs];
    
    // Launch path for mp4tags
    NSString *appResourceDir = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Resources"];
    [metadataTask setLaunchPath:[appResourceDir stringByAppendingPathComponent:@"mp4tags"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [metadataTask setStandardOutput:pipe];
    [metadataTask launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    [metadataTask waitUntilExit];
    
    NSString *pipeString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog (@"%@", pipeString);
}

- (void)tagFile:(NSString *)filename withCoverFilename:(NSString *)coverFilename {
    NSLog(@"tagFile:%@withCoverFilename:%@", filename, coverFilename);
    
    NSTask *mp4artAddTask = [[NSTask alloc] init];
    
    NSMutableArray *taskArgs = [NSMutableArray array];
    [taskArgs addObject:@"--keepgoing"];
    [taskArgs addObject:@"--add"];
    [taskArgs addObject:coverFilename];
    [taskArgs addObject:@"--art-any"];
    [taskArgs addObject:filename];
    
    NSLog(@"NSTask: %@", [taskArgs componentsJoinedByString:@" "]);
    [mp4artAddTask setArguments:taskArgs];
    
    // Launch path for mp4tags
    NSString *appResourceDir = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Resources"];
    [mp4artAddTask setLaunchPath:[appResourceDir stringByAppendingPathComponent:@"mp4art"]];
    
    NSPipe *pipe = [NSPipe pipe];
    [mp4artAddTask setStandardOutput:pipe];
    [mp4artAddTask launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    [mp4artAddTask waitUntilExit];
    
    NSString *pipeString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog (@"%@", pipeString);
}

@end
