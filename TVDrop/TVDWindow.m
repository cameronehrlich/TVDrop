//
//  TVDWindow.m
//  TVDrop
//
//  Created by Cameron Ehrlich on 5/7/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import "TVDWindow.h"

@implementation TVDWindow

- (void)awakeFromNib
{
    [self setMinSize:NSSizeFromCGSize(CGSizeMake(200, 150))];
    [self center];
}

- (BOOL)isMovableByWindowBackground
{
    return YES;
}

@end
