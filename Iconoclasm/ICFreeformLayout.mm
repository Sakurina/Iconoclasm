#include "ICFreeformLayout.h"
#include <CoreGraphics/CoreGraphics.h>
#include <UIKit/UIKit.h>
//#include <UIKit/UIView.h>
#include <objc/runtime.h>
#include "SpringBoard/SBIcon.h"
#include "ICMacros.h"
#import "ICRawScaleEngine.h"
#import "ICShortScaleEngine.h"
#import "ICTallScaleEngine.h"
#import "ICiPadScaleEngine.h"
#import "ICiPadLandscapeScaleEngine.h"
#import "ICiPhoneSixScaleEngine.h"
#import "ICiPhoneSixPlusPortraitScaleEngine.h"
#import "ICiPhoneSixPlusLandscapeScaleEngine.h"

@implementation ICFreeformLayout
@synthesize origins, useRawPoints, useiPadSpacingMath, landscapeOrigins, scaleEngine, scaleEngineLandscape;

-(id) init {
  if (self = [super init]) {
    self.origins = nil;
    self.landscapeOrigins = nil;
    self.useRawPoints = NO;
    self.useiPadSpacingMath = NO;
    self.scaleEngine = nil;
    self.scaleEngineLandscape = nil;
  }
  return self;
}

-(int) iconRowsForInterfaceOrientation:(int)orientation {
  return [self.origins count];
}

-(int) iconColumnsForInterfaceOrientation:(int)orientation {
  return 1;
}

-(id) initWithDictionaryRepresentation:(NSDictionary*) d {
  if (self = [self init]) {
    BOOL runningSeven = kCFCoreFoundationVersionNumber > 800;
    BOOL isiPhoneSixPlus = [[UIScreen mainScreen] bounds].size.height == 736;
    BOOL isiPhoneSix = [[UIScreen mainScreen] bounds].size.height == 667;
    BOOL shouldInheritiPhoneSixLayout = isiPhoneSixPlus || isiPhoneSix;
    BOOL hasTallScreen = [[UIScreen mainScreen] bounds].size.height == 568;
    BOOL shouldInheritiOSSevenTallLayout = isiPhoneSixPlus || isiPhoneSix || (hasTallScreen && runningSeven);
    BOOL supportsLandscape = isiPad || isiPhoneSixPlus;

    self.landscapeOrigins = nil;
    if (isiPad && runningSeven && [d objectForKey:@"Origins-7-iPad"]) {
      self.origins = [d objectForKey:@"Origins-7-iPad"];
      self.landscapeOrigins = [d objectForKey:@"Origins-7-iPad-Landscape"];
      self.useiPadSpacingMath = YES;
    } else if (isiPad && [d objectForKey:@"Origins-iPad"]) {
      self.origins = [d objectForKey:@"Origins-iPad"];
      self.landscapeOrigins = [d objectForKey:@"Origins-iPad-Landscape"];
      self.useiPadSpacingMath = YES;
    } else if (isiPhoneSixPlus && [d objectForKey:@"Origins-SixPlus"]) {
      self.origins = [d objectForKey:@"Origins-SixPlus"];
      self.landscapeOrigins = [d objectForKey:@"Origins-SixPlus-Landscape"];
    } else if (shouldInheritiPhoneSixLayout && [d objectForKey:@"Origins-Six"]) {
      self.origins = [d objectForKey:@"Origins-Six"];
    } else if (shouldInheritiOSSevenTallLayout && [d objectForKey:@"Origins-7-Tall"]) {
      self.origins = [d objectForKey:@"Origins-7-Tall"];
    } else if (hasTallScreen && [d objectForKey:@"Origins-Tall"]) {
      self.origins = [d objectForKey:@"Origins-Tall"];
    } else if (runningSeven && [d objectForKey:@"Origins-7-Short"]) {
      self.origins = [d objectForKey:@"Origins-7-Short"];
    } else {
      self.origins = [d objectForKey:@"Origins"];
    }
    self.useRawPoints = [[d objectForKey:@"UseRawPoints"] boolValue];
    self.scaleEngine = [self scaleEngineForDictionary:d landscape:NO];
    if (supportsLandscape) self.scaleEngineLandscape = [self scaleEngineForDictionary:d landscape:YES];
  }
  return self;
}

-(id<ICScaleEngine>) scaleEngineForDictionary:(NSDictionary*)d landscape:(BOOL)landscape {
  if ([[d objectForKey:@"UseRawPoints"] boolValue])
    return [ICRawScaleEngine sharedInstance];
  BOOL runningSeven = kCFCoreFoundationVersionNumber > 800;
  if (isiPad) {
    if ([d objectForKey:@"Origins-7-iPad-Landscape"] && landscape && runningSeven)
      return [ICiPadLandscapeScaleEngine sharedInstance];
    if ([d objectForKey:@"Origins-iPad-Landscape"] && landscape)
      return [ICiPadLandscapeScaleEngine sharedInstance];
    if ([d objectForKey:@"Origins-7-iPad"] && runningSeven)
      return [ICiPadScaleEngine sharedInstance];
    if ([d objectForKey:@"Origins-iPad"])
      return [ICiPadScaleEngine sharedInstance];
  }
  BOOL isiPhoneSixPlus = [[UIScreen mainScreen] bounds].size.height == 736;
  if (isiPhoneSixPlus && [d objectForKey:@"Origins-SixPlus-Landscape"] && landscape) {
    return [ICiPhoneSixPlusLandscapeScaleEngine sharedInstance];
  }
  if (isiPhoneSixPlus && [d objectForKey:@"Origins-SixPlus"]) {
    return [ICiPhoneSixPlusPortraitScaleEngine sharedInstance];
  }
  BOOL isiPhoneSix = [[UIScreen mainScreen] bounds].size.height == 667;
  BOOL shouldInheritiPhoneSixLayout = isiPhoneSixPlus || isiPhoneSix;
  if (shouldInheritiPhoneSixLayout && [d objectForKey:@"Origins-Six"]) {
    return [ICiPhoneSixScaleEngine sharedInstance];
  }
  BOOL hasTallScreen = [[UIScreen mainScreen] bounds].size.height == 568;
  BOOL shouldInheritiOSSevenTallLayout = isiPhoneSixPlus || isiPhoneSix || (hasTallScreen && runningSeven);
  if (shouldInheritiOSSevenTallLayout && [d objectForKey:@"Origins-7-Tall"])
    return [ICTallScaleEngine sharedInstance];
  if (hasTallScreen && [d objectForKey:@"Origins-Tall"])
    return [ICTallScaleEngine sharedInstance];
  return [ICShortScaleEngine sharedInstance];
}

-(CGPoint) rawPointForX:(int)x Y:(int)y {
  return CGPointMake([self xCoordinateForIcon:y], [self yCoordinateForIcon:y]);
}

-(CGPoint) pointForX:(int)x Y:(int)y inIconList:(UIView*)iL {
  BOOL isiPhoneSixPlus = [[UIScreen mainScreen] bounds].size.height == 736;
  BOOL supportsLandscape = isiPad || isiPhoneSixPlus;
  int orientation; CGPoint rawPt;
  orientation = [self currentOrientationForIconList:iL];
  rawPt = ((self.landscapeOrigins) && (orientation > 2)) ? [self landscapeRawPointForX:x Y:y] : [self rawPointForX:x Y:y];
  CGSize s = iL.frame.size;
  if (supportsLandscape && (orientation > 2))
    rawPt = [self.scaleEngineLandscape scaledPointForPoint:rawPt withIconListDimensions:s orientation:orientation];
  else
    rawPt = [self.scaleEngine scaledPointForPoint:rawPt withIconListDimensions:s orientation:orientation];
  // Offsetting by screenfuls for scrolling views I guess
  int screenfulsToOffset = (y / [self.origins count]);
  rawPt.y += (screenfulsToOffset * s.height);
  // integral
  rawPt.x = (int)rawPt.x;
  rawPt.y = (int)rawPt.y;
  return rawPt;
}

-(CGRect) rectForIcons {
  int upperMost=INT_MAX, leftMost=INT_MAX, rightMost=INT_MIN, bottomMost=INT_MIN;
  for (NSDictionary* point in self.origins) {
    int x = [[point objectForKey:@"x"] intValue];
    int y = [[point objectForKey:@"y"] intValue];
    if (x < leftMost)
      leftMost = x;
    if (x+60 > rightMost)
      rightMost = x+60;
    if (y < upperMost)
      upperMost = y;
    if (y+60 > bottomMost)
      bottomMost = y+60;
  }
  return CGRectMake(leftMost, upperMost, rightMost-leftMost, bottomMost-upperMost);
}

-(int) columnAtPoint:(CGPoint)pt inIconList:(id)iL {
  return 0;
}

#define PADDING 5

-(int) currentOrientationForIconList:(id)iL {
  int orientation=0;
  BOOL runningSeven = kCFCoreFoundationVersionNumber > 800;
  if (runningSeven) {
    orientation = (long long)[[objc_getClass("SBIconController") sharedInstance] orientation];
  } else {
    object_getInstanceVariable(iL, "_orientation", (void**)&orientation);
  }
  return orientation;
}

-(int) rowAtPoint:(CGPoint)pt inIconList:(id)iL {
  BOOL runningSeven = kCFCoreFoundationVersionNumber > 800;
  BOOL runningEight = kCFCoreFoundationVersionNumber > 1000;
  Class sbi = kCFCoreFoundationVersionNumber < 675 ? objc_getClass("SBIcon") : objc_getClass("SBIconView");
  CGSize iconSize = [sbi defaultIconSize];
  int orientation; NSArray* _origins;
  orientation = [self currentOrientationForIconList:iL];
  if (self.landscapeOrigins != nil)
    _origins = orientation <= 2 ? self.origins : self.landscapeOrigins;
  else
    _origins = self.origins;
  for (int i=[_origins count]-1; i >= 0; i--) {
    CGPoint origin = [self pointForX:0 Y:i inIconList:iL];
    CGRect thisIcon = CGRectMake(origin.x-PADDING,origin.y-PADDING,iconSize.width+2*PADDING,iconSize.height+2*PADDING);
    if (CGRectContainsPoint(thisIcon, pt)) {
      return i;
    }
  }
  return [_origins count]-1;
}

// Private

-(int) xCoordinateForIcon:(int)iconNum {
  return [[[self.origins objectAtIndex:(iconNum % [self.origins count])] objectForKey:@"x"] intValue];
}

-(int) yCoordinateForIcon:(int)iconNum {
  return [[[self.origins objectAtIndex:(iconNum % [self.origins count])] objectForKey:@"y"] intValue];
}

// Landscape

-(int) landscapeXCoordinateForIcon:(int)iconNum {
  return [[[self.landscapeOrigins objectAtIndex:(iconNum % [self.landscapeOrigins count])] objectForKey:@"x"] intValue];
}

-(int) landscapeYCoordinateForIcon:(int)iconNum {
  if (iconNum >= [self.landscapeOrigins count]) {
    int relativeToPage = [[[self.landscapeOrigins objectAtIndex:(iconNum % [self.landscapeOrigins count])] objectForKey:@"y"] intValue];
    return relativeToPage + (320 * (iconNum / [self.landscapeOrigins count]));
  }
  return [[[self.landscapeOrigins objectAtIndex:(iconNum % [self.landscapeOrigins count])] objectForKey:@"y"] intValue];
}

-(CGPoint) landscapeRawPointForX:(int)x Y:(int)y {
  return CGPointMake([self landscapeXCoordinateForIcon:y], [self landscapeYCoordinateForIcon:y]);
}

-(ICFreeformLayout*) freeformLayoutRepresentation {
  return self;
}

@end
