#include <Foundation/Foundation.h>
#include "ICLayout.h"
#include "ICScaleEngine.h"

@class NSObject;
@interface ICFreeformLayout : NSObject<ICLayout> {
  NSArray* origins;
  NSArray* landscapeOrigins;
  BOOL useRawPoints;
  BOOL useiPadSpacingMath;
  id<ICScaleEngine> scaleEngine;
  id<ICScaleEngine> scaleEngineLandscape;
}
-(id) init;
-(id) rows;
-(id) cols;
-(id) initWithDictionaryRepresentation:(NSDictionary*) d;
-(CGPoint) rawPointForX:(int)x Y:(int)y;
-(CGPoint) pointForX:(int)x Y:(int)y inIconList:(UIView*)iL;
-(CGRect) rectForIcons;
-(int) rowAtPoint:(CGPoint)pt inIconList:(id)iL;
-(int) xCoordinateForIcon:(int)iconNum;
-(int) yCoordinateForIcon:(int)iconNum;
-(int) landscapeXCoordinateForIcon:(int)iconNum;
-(int) landscapeYCoordinateForIcon:(int)iconNum;
-(CGPoint) landscapeRawPointForX:(int)x Y:(int)y;
-(ICFreeformLayout*) freeformLayoutRepresentation;

@property(nonatomic, retain) NSArray* origins;
@property(nonatomic, retain) NSArray* landscapeOrigins;
@property(nonatomic) BOOL useRawPoints;
@property(nonatomic) BOOL useiPadSpacingMath;
@property(nonatomic, retain) id<ICScaleEngine> scaleEngine;
@property(nonatomic, retain) id<ICScaleEngine> scaleEngineLandscape;
@end
