#import <Cocoa/Cocoa.h>
#import "MineSquare.h"

typedef unsigned short ushort;

@interface MineField : NSObject {
	NSMutableArray *squares;
	
	BOOL detonated;
	BOOL deactived;
	ushort minesRemaining;
	ushort squaresRemaining;
	ushort perimeterSize;
	unsigned int recurseId;
}

@property (readonly) ushort perimeterSize;
@property (readonly) ushort minesRemaining;
@property (readonly) BOOL detonated;
@property (readonly) BOOL deactived;

- (void) stepOnRow: (ushort) row column: (ushort) column;
- (void) recurseFromRow: (ushort) row column: (ushort) column;
- (MineSquare*) squareAtRow: (ushort) row column: (ushort) column;
- (void) toggleFlagAtRow: (ushort) row column: (ushort) column;
- (void) setSize: (ushort) size andMineCount: (ushort) mineCount;

@end