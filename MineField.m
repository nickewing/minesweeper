#import "MineField.h"
#import "MineSquare.h"
#include <time.h>


@implementation MineField

@synthesize perimeterSize;
@synthesize minesRemaining;
@synthesize detonated;
@synthesize deactived;

// Return the square at specified row and column
- (MineSquare*) squareAtRow: (ushort) row column: (ushort) column {
	return [[squares objectAtIndex: row] objectAtIndex: column];
}

// Step on a square: Lose or recurse
- (void) stepOnRow: (ushort) row column: (ushort) column {
	MineSquare* sq = [self squareAtRow: row column: column];
	
	// don't allow flagged mines to be pressed
	if ([sq flagged]) return;
	
	if ([sq isMine]) {
		detonated = YES; // Lose!
	} else {
		++recurseId;
		NSLog(@"step on: %d %d", row, column);
		[self recurseFromRow: row column: column];
		
		if (squaresRemaining == 0) {
			deactived = YES;
		}
	}
}

// Recurse through mine squares showing empty areas after a square is stepped on
- (void) recurseFromRow: (ushort) row column: (ushort) column {
	MineSquare* sq = [self squareAtRow: row column: column];
	
	//NSLog(@"Checking %d %d", row, column);
	
	if ([sq recurseId] >= recurseId) {
		//NSLog(@"Already recursed %d %d", row, column);
		return;
	}
	
	if (![sq isMine] && ![sq flagged]) {
		if (![sq empty]) --squaresRemaining;
		
		[sq setEmpty: YES];
		//NSLog(@"Remaining: %d r%d c%d", squaresRemaining, row, column);
	}
	if ([sq adjacent]) {
		//NSLog(@"Found adj at: %d %d", row, column);
		return;
	}
	
	[sq setRecurseId: recurseId];
	
	if (column - 1 >= 0) [self recurseFromRow: row column: column - 1];
	if (column + 1 < perimeterSize) [self recurseFromRow: row column: column + 1];
	if (row - 1 >= 0) [self recurseFromRow: row - 1 column: column];
	if (row + 1 < perimeterSize) [self recurseFromRow: row + 1 column: column];
}

// Toggle flagged value
- (void) toggleFlagAtRow: (ushort) row column: (ushort) column {
	MineSquare* sq = [self squareAtRow: row column: column];
	
	BOOL flagValue = [sq flagged] ? NO : YES;
	
	if (flagValue == NO) ++minesRemaining;
	else if (minesRemaining >= 1) --minesRemaining;
	
	[sq setFlagged: flagValue];
}

// Resize the board and place mines
- (void) setSize: (ushort) size andMineCount: (ushort) mineCount {
	ushort remainingMines = minesRemaining = mineCount;
	ushort i, j;
	short x, y;
	ushort sizeSquared = size * size;
	
	squaresRemaining = sizeSquared - remainingMines;
	
	perimeterSize = size;
	recurseId = 0;
	detonated = deactived = NO;
	
	srand(time(NULL));
	
	squares = [[NSMutableArray alloc] init];
	
	// create matrix size x size
	for (i = 0; i < size; i++) {
		NSMutableArray* arr = [[NSMutableArray alloc] init];
		
		for (j = 0; j < size; j++) {
			[arr addObject: [[MineSquare alloc] init]];
		}
		
		[squares addObject: arr];
	}
	
	for (i = j = 0; remainingMines;) {
		// randomly place mines
		if (rand() % sizeSquared < 1 && remainingMines > 0) {
			MineSquare* sq = [self squareAtRow: i column: j];
			
			// skip if square is already a mine
			if (![sq isMine]) {
				[sq setIsMine: YES];

				for (x = -1; x <= 1; x++) {
					for (y = -1; y <= 1; y++) {
						if (	(x == 0 && y == 0)
							||	i + x < 0
							||	j + y < 0
							||	i + x >= perimeterSize
							||	j + y >= perimeterSize
						) continue;
						
						NSLog(@"Added adj at row: %d col: %d", i + x, j + y);
						MineSquare* adjSq = [self squareAtRow: i + x column: j + y];
						[adjSq setAdjacent: [adjSq adjacent] + 1];
					}
				}
				
				--remainingMines;
				//NSLog(@"Added log at row: %d col: %d remaining: %d", i, j, remainingMines);
			}
		}
		
		j++;
		if (j >= size) {
			j = 0;
			i++;
		}
		if (i >= size) i = 0;
	}
}

@end
