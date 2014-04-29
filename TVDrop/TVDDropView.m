//
//  TVDDropView.m
//  Pods
//
//  Created by Cameron Ehrlich on 4/29/14.
//
//

#import "TVDDropView.h"
#import <QuartzCore/QuartzCore.h>
#import "TVDAppDelegate.h"

@implementation TVDDropView

- (void)awakeFromNib
{
    [self registerForDraggedTypes:@[NSURLPboardType, NSFilenamesPboardType]];
    [self.layer setBackgroundColor:[[NSColor greenColor] CGColor]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    [(TVDAppDelegate*)[[NSApplication sharedApplication] delegate] setFileToPlayURL:[NSURL URLFromPasteboard:pboard]];
    [(TVDAppDelegate*)[[NSApplication sharedApplication] delegate] connectAndPlay];
    
    return YES;
}

@end
