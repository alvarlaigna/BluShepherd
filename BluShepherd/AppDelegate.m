//
//  AppDelegate.m
//  BluShepherd
//
//  Created by Simon Fell on 11/26/16.
//  Copyright © 2016 Simon Fell. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayerList.h"
#import "NowPlayingView.h"
#import "LibraryDataSource.h"
#import "CoverArtCache.h"
#import "ControlsView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *nowPlayingView;
@property (weak) IBOutlet NSView *controlsView;

-(NSURLSession *)createSession;
@end

@implementation AppDelegate

+(AppDelegate *) delegate {
    return [NSApp delegate];
}

-(void)registerDefaults {
    NSDictionary *d = @{
                        @"BlissURL" : @"http://localhost:3220/",
                        @"hasBlissEnabled" : [NSNumber numberWithBool:YES]
                        };
    [[NSUserDefaults standardUserDefaults] registerDefaults:d];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self registerDefaults];
    self.session = [self createSession];
    self.coverCache = [[CoverArtCache alloc] init];

    NowPlayingView *npv = [[NowPlayingView alloc] initWithNibName:nil bundle:nil];
    [self.nowPlayingView addSubview:[npv view]];
    
    ControlsView *cv = [[ControlsView alloc] initWithNibName:nil bundle:nil];
    [self.controlsView addSubview:[cv view]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:notificationPlayerSelection object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
        Player *p = [n object];
        npv.selectedPlayer = p;
        cv.selectedPlayer = p;
        self.selectedPlayer = p;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100), dispatch_get_main_queue(), ^{
            self.library.selectedPlayer = p;
        });
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.coverCache flush];
}

-(IBAction)play:(id)sender {
    [self.selectedPlayer play:sender];
}

-(IBAction)pause:(id)sender {
    [self.selectedPlayer pause:sender];
}

-(NSURLSession *)createSession {
    // Configuring NSURLSession
    NSURLSessionConfiguration *cfg = [[NSURLSessionConfiguration defaultSessionConfiguration] copy];
    cfg.HTTPMaximumConnectionsPerHost = 5;
    cfg.HTTPShouldSetCookies = NO;
    cfg.timeoutIntervalForRequest = 70;
    cfg.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    return [NSURLSession sessionWithConfiguration:cfg];
}

@end
