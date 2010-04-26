//
//  NSButtonCellTextColor.h
//  MineSweeper
//
//  Created by Nicholas Ewing on 4/27/09.
//  Copyright 2009 Kuzoa, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSButtonCell (TextColor)

- (NSColor *) textColor;
- (void) setTextColor: (NSColor *)textColor;

@end