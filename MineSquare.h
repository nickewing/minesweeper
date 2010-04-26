#import <Cocoa/Cocoa.h>

@interface MineSquare : NSObject {
	BOOL isMine;
	BOOL flagged;
	BOOL empty;
	unsigned short adjacent;
	unsigned int recurseId;
}

@property (readwrite) BOOL isMine;
@property (readwrite) BOOL flagged;
@property (readwrite) BOOL empty;
@property (readwrite) unsigned short adjacent;
@property (readwrite) unsigned int recurseId;

@end
