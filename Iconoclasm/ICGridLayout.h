#import <Foundation/Foundation.h>
#import "ICLayout.h"
#import <UIKit/UIView.h>
#import "ICScaleEngine.h"

@interface ICGridLayout : NSObject<ICLayout> {
	NSArray* cols;
	NSArray* rows;
  NSArray* landscapeCols;
  NSArray* landscapeRows;
  BOOL useRawPoints;
  BOOL useiPadSpacingMath;
  int totalNumberOfIcons;
  id<ICScaleEngine> scaleEngine;
  id<ICScaleEngine> scaleEngineLandscape;

  // columnAtPoint:, rowAtPoint: cache
  CGSize iconListSizeWhenCached;
  NSArray* colMinCache;
  NSArray* rowMinCache;

  BOOL isSevenLayout;
}

-(id) initWithDictionaryRepresentation:(NSDictionary*)d;

-(int) xCoordinateForColumn:(int)col;
-(int) yCoordinateForRow:(int)row;

-(CGPoint) landscapeRawPointForX:(int)x Y:(int)y;
-(int) landscapeXCoordinateForColumn:(int)col;
-(int) landscapeYCoordinateForRow:(int)row;

@property(nonatomic, retain) NSArray* cols;
@property(nonatomic, retain) NSArray* rows;
@property(nonatomic, retain) NSArray* landscapeCols;
@property(nonatomic, retain) NSArray* landscapeRows;
@property(nonatomic) BOOL useRawPoints;
@property(nonatomic) BOOL useiPadSpacingMath;
@property(nonatomic) int totalNumberOfIcons;
@property(nonatomic, retain) id<ICScaleEngine> scaleEngine;
@property(nonatomic, retain) id<ICScaleEngine> scaleEngineLandscape;

@property(nonatomic) CGSize iconListSizeWhenCached;
@property(nonatomic, retain) NSArray* colMinCache;
@property(nonatomic, retain) NSArray* rowMinCache;

@property(nonatomic) BOOL isSevenLayout;
@end
