#import <CoreGraphics/CGGeometry.h>
@class UIView;
@class ICFreeformLayout;
@protocol ICLayout
-(CGPoint) rawPointForX:(int)x Y:(int)y;
-(CGPoint) pointForX:(int)x Y:(int)y inIconList:(UIView*)iL;
-(CGRect) rectForIcons;

-(int) iconRowsForInterfaceOrientation:(int)orientation;
-(int) iconColumnsForInterfaceOrientation:(int)orientation;
-(int) columnAtPoint:(CGPoint)pt inIconList:(id)iL;
-(int) rowAtPoint:(CGPoint)pt inIconList:(id)iL;
-(ICFreeformLayout*) freeformLayoutRepresentation;
@end
