#import "CustomMatrix.h"
#import "MineController.h"

@implementation CustomMatrix 

- (void) rightMouseDown: (NSEvent*) theEvent {
	NSInteger r, c; 
	NSPoint pt = [self convertPoint: [theEvent locationInWindow] fromView: nil]; 
	
	[self getRow: &r column: &c forPoint: pt]; 
	NSButtonCell *bcell = [self cellAtRow: r column: c]; 
	
	if ([bcell isEnabled]) {
		[self selectCellAtRow:r column: c];
		[[self target] rightClicked: self];
	}
}

@end 
