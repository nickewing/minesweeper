#import "MineController.h"
#import "MineField.h"

const ushort diffSizes[] = {8, 15, 20};
const ushort diffMines[] = {8, 30, 60};

@implementation MineController

// Application should exit when window closes
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

// Setup after Nib is awake
- (void) awakeFromNib {	
	[NSApp setDelegate:self];
	
	// Setup timer for game clock
	timer = [NSTimer scheduledTimerWithTimeInterval: 1
							target: self
							selector: @selector(clockTimer:)
							userInfo: nil
							repeats: YES];
	
	// Setup images
	mineImage = [NSImage imageNamed: @"bomb.png"];
	isMineImage = [NSImage imageNamed: @"is_bomb.png"];
	notMineImage = [NSImage imageNamed: @"not_bomb.png"];
	flagImage = [NSImage imageNamed: @"flag_red.png"];
	
	happyImage = [NSImage imageNamed: @"emoticon_smile.png"];
	sadImage = [NSImage imageNamed: @"emoticon_unhappy.png"];
	scaredImage = [NSImage imageNamed: @"emoticon_surprised.png"];
	winkImage = [NSImage imageNamed: @"emoticon_wink.png"];
	
	// Make a new game
	gameDiff = EASY;
	
	field = [[MineField alloc] init];
	
	[self setDifficulty: gameDiff];
	[self updateDisplay];
}

- (void) clockTimer: (NSTimer *) timer {
	if (gameStartTime == nil || [field detonated] || [field deactived]) return;
	
	NSTimeInterval ti = -[gameStartTime timeIntervalSinceNow];
	
	int m = ti / 60;
	int s = (int) ti % 60;
	
	[remainingTime setStringValue: [NSString stringWithFormat: @"%d:%02d", m, s]]; 
}

// Change the game difficulty and update the board
- (void) setDifficulty: (difficulty) diffId {
	gameDiff = diffId;
	
	moves = 0;
	gameStartTime = nil;
	[remainingTime setStringValue: @"0:00"];
	
	[statusButton setImage: happyImage];
	
	[field setSize: diffSizes[diffId] andMineCount: diffMines[diffId]];
	
	[self updateDisplay];
}

// New game selected from the main menu
- (void) newGame: (id) sender {
	[self setDifficulty: gameDiff];
}

// Difficulty selected from drop down list
- (void) changeDiff: (id) sender {
	//[self setDifficulty: [[sender selectedItem] tag]];
	
	[self setDifficulty: [sender tag]];
	
	NSSize oldSize = [fieldMatrix frame].size;
	
	// resize fieldMatrix
	[fieldMatrix renewRows: [field perimeterSize] columns: [field perimeterSize]];
	[fieldMatrix sizeToCells];
	
	NSSize newSize = [fieldMatrix frame].size;
	NSRect windowFrame = [window frame];
	
	windowFrame.size.width += newSize.width - oldSize.width;
	windowFrame.size.height += newSize.height - oldSize.height;
	windowFrame.origin.y -= newSize.height - oldSize.height;
	
	[window setFrame: windowFrame display: YES];
	
	[self updateDisplay];
}

// Update status button image
- (void) updateStatusButton: (NSTimer *) timer {
	// Update button image
	if ([field detonated]) {
		[statusButton setImage: sadImage];
	} else if ([field deactived]) {
		[statusButton setImage: winkImage];
	} else {
		[statusButton setImage: happyImage];
	}
}

// Field matrix left clicked
- (void) fieldPress: (id) sender {
	[self handlePress: sender withRightClick: NO];
}

// Field matrix right clicked 
- (void) rightClicked: (id) sender {
	[self handlePress: sender withRightClick: YES];
}

// Handle left click, right click, and control click
- (void) handlePress: (id) sender withRightClick: (BOOL) rightClick {
	if ([field detonated] || [field deactived]) return;
	
	int eventflags = [[[sender window] currentEvent] modifierFlags];
	ushort row = [sender selectedRow];
	ushort col = [sender selectedColumn];
	
	if (gameStartTime == nil)
		gameStartTime = [[NSDate alloc] init];
	
	if (rightClick || eventflags & NSControlKeyMask) {
		[field toggleFlagAtRow: row column: col];
	} else {
		// Flash scared face for a fraction of a second
		[statusButton setImage: scaredImage];
		[NSTimer scheduledTimerWithTimeInterval: 0.3
				target: self
				selector: @selector(updateStatusButton:)
				userInfo: nil
				repeats: NO];
		
		[field stepOnRow: row column: col];
		
		// Don't allow the first click to be a detonation
		while (!moves && [field detonated]) {
			[field setSize: diffSizes[gameDiff] andMineCount: diffMines[gameDiff]];
			[field stepOnRow: row column: col];
		}
	}
	
	++moves;
	
	[self updateDisplay];
}

// Refresh the field matrix, showing any changes to the model
- (void) updateDisplay {
	ushort i, j;
	
	// Show board changes
	if ([field detonated]) {
		[remainingMines setStringValue: @"BOOM"];
		//[fieldMatrix setEnabled: NO];
	} else if ([field deactived]) {
		[remainingMines setStringValue: @"YOU WIN"];
		//[fieldMatrix setEnabled: NO];
	} else {
		[remainingMines setStringValue: [NSString stringWithFormat: @"%d", [field minesRemaining]]];
	}
	
	// Show changes to the cells
	for (i = 0; i < [field perimeterSize]; i++) {
		for (j = 0; j < [field perimeterSize]; j++) {
			MineSquare* sq = [field squareAtRow: i column: j];
			NSButtonCell* button = [fieldMatrix cellAtRow: i column: j];
			
			if (![field detonated]) {
				if ([sq empty]) {
					[button setEnabled: NO];
					if ([sq adjacent]) {
						[button setTitle: [NSString stringWithFormat: @"%d", [sq adjacent]]];
					} else {
						[button setTitle: @""];
					}
					[button setImage: nil];
				} else if ([sq flagged]) {
					[button setImage: flagImage];
					[button setEnabled: YES];
				} else {
					[button setTitle: @""];
					[button setEnabled: YES];
					[button setImage: nil];
				}
			} else if ([sq flagged] && [sq isMine]) {
				[button setImage: isMineImage];
			} else if ([sq flagged] && ![sq isMine]) {
				[button setImage: notMineImage];
			} else if ([sq isMine]) {
				[button setImage: mineImage];
			}
		}
	}
}

@end
