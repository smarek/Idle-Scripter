//
//  IdleScripterAppDelegate.h
//  IdleScripter
//
//  Created by Marek S on 9.2.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <IOKit/IOKitLib.h>

@interface IdleScripterAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSButton *activation_on;
	IBOutlet NSButton *deactivation_on;
	IBOutlet NSButton *activation_choose;
	IBOutlet NSButton *deactivation_choose;
	IBOutlet NSButton *preferences_save;
	IBOutlet NSSlider *idle_interval;
	IBOutlet NSTextFieldCell *interval_label;
	IBOutlet NSTextField *activation_path;
	IBOutlet NSTextField *deactivation_path;
	NSDictionary *setup;
	NSTimer *tikac;
	NSTimer *vracec;
	bool running;
	NSMenu *barmenu;
	NSMenuItem *prefs_item;
	NSMenuItem *quit_item;
	NSFileManager *nsfm;
}
/*
 asd
 */

-(IBAction)activation_choose:(id)sender;
-(IBAction)deactivation_choose:(id)sender;
-(IBAction)save_choose:(id)sender;
-(IBAction)activation_on_choose:(id)sender;
-(IBAction)deactivation_on_choose:(id)sender;
-(IBAction)timer_slide:(id)sender;
-(int64_t)SystemIdleTime;

@property (assign) IBOutlet NSWindow *window;

@end
