#import <Cocoa/Cocoa.h>
#import "MineField.h"

typedef enum _difficulty {EASY, STANDARD, HARD} difficulty;

@interface MineController : NSObject {
	IBOutlet NSMatrix* fieldMatrix;
	IBOutlet NSPopUpButton* diffSelect;
	IBOutlet NSTextField* remainingMines;
	IBOutlet NSTextField* remainingTime;
	IBOutlet NSButton* statusButton;
	IBOutlet NSWindow* window;
	
	NSTimer* timer;
	NSDate* gameStartTime;
	
	unsigned short gameDiff;
	MineField* field;
	
	NSImage* mineImage;
	NSImage* isMineImage;
	NSImage* notMineImage;
	NSImage* flagImage;
	
	NSImage* happyImage;
	NSImage* sadImage;
	NSImage* scaredImage;
	NSImage* winkImage;
	
	unsigned int moves;
}

- (void) awakeFromNib;
- (void) clockTimer: (NSTimer *) timer;
- (void) rightClicked: (id) sender;

- (void) changeDiff: (id) sender;
- (void) fieldPress: (id) sender;
- (void) newGame: (id) sender;

- (void) handlePress: (id) sender withRightClick: (BOOL) rightClick;
- (void) updateDisplay;
- (void) setDifficulty: (difficulty) diffId;

@end
