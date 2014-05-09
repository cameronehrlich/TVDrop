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
#import <HexColor.h>

@implementation TVDDropView

- (void)awakeFromNib
{
    [self registerForDraggedTypes:@[NSURLPboardType, NSFilenamesPboardType]];
    [self.layer setBackgroundColor:[[NSColor colorWithHexString:@"#BEE5E9" alpha:1] CGColor]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    [self.layer setBackgroundColor:[[NSColor colorWithHexString:@"#C2EBCF" alpha:1] CGColor]];
    return NSDragOperationCopy;
}

-(void)draggingExited:(id<NSDraggingInfo>)sender
{
    [self.layer setBackgroundColor:[[NSColor colorWithHexString:@"#BEE5E9" alpha:1] CGColor]];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[[[TVDModel sharedInstance] airplayManager] connectedDevice] connected]) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        [[TVDModel sharedInstance] playFileAtURL:fileURL];
    }
    
    return YES;
}

-(void)keyUp:(NSEvent *)theEvent
{
    if (theEvent.keyCode == 49) {
        [[[[TVDModel sharedInstance] airplayManager] connectedDevice] sendPlayPause];
    }
}

-(void)keyDown:(NSEvent *)theEvent
{
    //override to stop the beeping
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

@end
