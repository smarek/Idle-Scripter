//
//  IdleScripterAppDelegate.m
//  IdleScripter
//
//  Created by Marek S on 9.2.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IdleScripterAppDelegate.h"

@implementation IdleScripterAppDelegate

@synthesize window;

-(void)awakeFromNib{
	nsfm = [NSFileManager defaultManager];
	if ([nsfm fileExistsAtPath:[@"~/Library/Preferences/IdleScripter.plist" stringByExpandingTildeInPath]]) {
		setup = [NSDictionary dictionaryWithContentsOfFile:[@"~/Library/Preferences/IdleScripter.plist" stringByExpandingTildeInPath]];
		[activation_on setState:([setup valueForKey:@"ActivationOnState"] == [NSNumber numberWithInt:1])];
		[deactivation_on setState:([setup valueForKey:@"DeactivationOnState"] == [NSNumber numberWithInt:1])];
		[activation_path setStringValue:[setup valueForKey:@"ActivationPath"]];
		[deactivation_path setStringValue:[setup valueForKey:@"DeactivationPath"]];
		[idle_interval setStringValue:[setup valueForKey:@"IdleInterval"]];
		[self timer_slide:self];
	} 
	tikac = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(tik) userInfo:nil repeats:YES];
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
	NSStatusItem *statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
	NSImage *itemImage = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"]];
	[statusItem retain];
	
	barmenu = [[NSMenu alloc] initWithTitle:@"IdleTimer"];
	prefs_item = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(prefs_click) keyEquivalent:@"p"];
	quit_item = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit_click) keyEquivalent:@"q"];
	[barmenu addItem:prefs_item];
	[barmenu addItem:quit_item];
	
	[statusItem setImage: itemImage];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:barmenu];
}

-(IBAction)activation_choose:(id)sender{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	// That has got to be one of the most repetitive Cocoa lines of code ;-)
	
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanCreateDirectories:NO]; // Added by DustinVoss
	[openPanel setPrompt:@"Activation: Choose script file"]; // Should be localized
	[openPanel setCanChooseFiles:YES];
	[openPanel beginWithCompletionHandler:^(NSInteger result) {
		if (result == NSOKButton) {
			[openPanel orderOut:self];
			[activation_path setStringValue:[openPanel filename]];
		}}];
}
-(IBAction)deactivation_choose:(id)sender{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	// That has got to be one of the most repetitive Cocoa lines of code ;-)
	
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanCreateDirectories:NO]; // Added by DustinVoss
	[openPanel setPrompt:@"Deactivation: Choose script file"]; // Should be localized
	[openPanel setCanChooseFiles:YES];
	[openPanel beginWithCompletionHandler:^(NSInteger result) {
		if (result == NSOKButton) {
			[openPanel orderOut:self];
			[deactivation_path setStringValue:[openPanel filename]];
		}}];
}
-(IBAction)save_choose:(id)sender{
	setup = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:[activation_on state]],@"ActivationOnState",
						  [NSNumber numberWithInt:[deactivation_on state]],@"DeactivationOnState",
						  [activation_path stringValue],@"ActivationPath",
						  [deactivation_path stringValue],@"DeactivationPath",
						  [NSNumber numberWithInt:[idle_interval intValue]],@"IdleInterval",
						  nil];
	NSData *plist = [NSPropertyListSerialization dataFromPropertyList:setup format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
	[plist writeToFile:[@"~/Library/Preferences/IdleScripter.plist" stringByExpandingTildeInPath] atomically:YES];
	[window orderOut:self];
	[NSApp hide:nil];
}
-(IBAction)activation_on_choose:(id)sender{
	if ([activation_on state] == NSOnState) {
		[activation_choose setEnabled:YES];
	}
	else {
		[activation_choose setEnabled:NO];
	}
}
-(IBAction)deactivation_on_choose:(id)sender{
	if ([deactivation_on state] == NSOnState) {
		[deactivation_choose setEnabled:YES];
	}
	else {
		[deactivation_choose setEnabled:NO];
	}
}
-(IBAction)timer_slide:(id)sender{
	[interval_label setStringValue:[idle_interval stringValue]];
}

- (void) tik {
	int idle = [self SystemIdleTime];
	if (idle >= ([idle_interval intValue]*60)) {
		if(!running){
			NSLog(@"1");
			NSString *path = [setup valueForKey:@"ActivationPath"];
			if([nsfm fileExistsAtPath:path]){
				NSLog(@"2");
				NSTask *task = [[NSTask alloc] init];
				[task setLaunchPath:@"/usr/bin/osascript"];
				[task setArguments:[NSArray arrayWithObject:path]];
				[task launch];
			}
			running = YES;
			vracec = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(tik) userInfo:nil repeats:YES];
		}
	}
	else {
		if([vracec isValid]){
			[vracec invalidate];
		}
		if (running) {
			running = NO;
			NSLog(@"3");
			NSString *path = [setup valueForKey:@"DeactivationPath"];
			if([nsfm fileExistsAtPath:path]){
				NSLog(@"4");
				NSTask *task = [[NSTask alloc] init];
				[task setLaunchPath:@"/usr/bin/osascript"];
				[task setArguments:[NSArray arrayWithObject:path]];
				[task launch];
			}
		}
	}
}

-(void) prefs_click{
	[window makeKeyAndOrderFront:self];
}

-(void) quit_click {
	[self save_choose:nil];
	[NSApp terminate: nil];
}

- (int64_t) SystemIdleTime{
    int64_t idlesecs = -1;
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iter) == KERN_SUCCESS) {
        io_registry_entry_t entry = IOIteratorNext(iter);
        if (entry) {
            CFMutableDictionaryRef dict = NULL;
            if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS) {
                CFNumberRef obj = CFDictionaryGetValue(dict, CFSTR("HIDIdleTime"));
                if (obj) {
                    int64_t nanoseconds = 0;
                    if (CFNumberGetValue(obj, kCFNumberSInt64Type, &nanoseconds)) {
                        idlesecs = (nanoseconds >> 30); // Divide by 10^9 to convert from nanoseconds to seconds.
                    }
                }
                CFRelease(dict);
            }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
    }
    return idlesecs;
}   

@end
