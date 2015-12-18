#import "ICGridLayout.h"
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>
#import <objc/runtime.h>
#import "ICMacros.h"
#include "SpringBoard/SBIcon.h"
#import "ICRawScaleEngine.h"
#import "ICShortScaleEngine.h"
#import "ICTallScaleEngine.h"
#import "ICiPadScaleEngine.h"
#import "ICiPadLandscapeScaleEngine.h"
#import "ICiPhoneSixScaleEngine.h"
#import "ICiPhoneSixPlusPortraitScaleEngine.h"
#import "ICiPhoneSixPlusLandscapeScaleEngine.h"

static NSArray* originsArrayFromGridArrays(NSArray* c, NSArray* r) {
  if (!c || !r) return nil;
  NSArray* o = [NSArray array];
  for (NSNumber* y in r) {
    for (NSNumber* x in c) {
      o = [o arrayByAddingObject:[NSDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
    }
  }
  return o;
}

@implementation ICGridLayout
@synthesize cols, rows, landscapeCols, landscapeRows, useRawPoints, useiPadSpacingMath, totalNumberOfIcons, scaleEngine, scaleEngineLandscape, iconListSizeWhenCached, colMinCache, rowMinCache;

-(id) init {
  if (self = [super init]) {
    self.cols = nil;
    self.rows = nil;
    self.landscapeCols = nil;
    self.landscapeRows = nil;
    self.useRawPoints = NO;
    self.useiPadSpacingMath = NO;
    self.totalNumberOfIcons = 0;
    self.scaleEngine = nil;
    self.scaleEngineLandscape = nil;
    self.iconListSizeWhenCached = CGSizeZero;
    self.colMinCache = nil;
    self.rowMinCache = nil;
    self.isSevenLayout = NO;
  }
  return self;
}

-(id) initWithDictionaryRepresentation:(NSDictionary*)d {
  if (self = [self init]) {
    BOOL runningSeven = kCFCoreFoundationVersionNumber > 800;
    BOOL isiPhoneSixPlus = [[UIScreen mainScreen] bounds].size.height == 736;
    BOOL isiPhoneSix = [[UIScreen mainScreen] bounds].size.height == 667;
    BOOL shouldInheritiPhoneSixLayout = isiPhoneSixPlus || isiPhoneSix;
    BOOL hasTallScreen = [[UIScreen mainScreen] bounds].size.height == 568;
    BOOL shouldInheritiOSSevenTallLayout = isiPhoneSixPlus || isiPhoneSix || (hasTallScreen && runningSeven);
    BOOL supportsLandscape = isiPad || isiPhoneSixPlus;


    if (isiPad && runningSeven && [d objectForKey:@"Cols-7-iPad"] && [d objectForKey:@"Rows-7-iPad"]) {
      self.cols = [d objectForKey:@"Cols-7-iPad"];
      self.rows = [d objectForKey:@"Rows-7-iPad"];
      self.useiPadSpacingMath = YES;
      self.isSevenLayout = YES;
      if ([d objectForKey:@"Cols-7-iPad-Landscape"] && [d objectForKey:@"Rows-7-iPad-Landscape"]) {
        self.landscapeCols = [d objectForKey:@"Cols-7-iPad-Landscape"];
        self.landscapeRows = [d objectForKey:@"Rows-7-iPad-Landscape"];
        NSAssert([landscapeCols count]*[landscapeRows count] == [cols count]*[rows count], @"GRID LAYOUT ERROR: Cols*Rows must be equal on portrait/landscape");
      }
    } else if (isiPad && [d objectForKey:@"Cols-iPad"] && [d objectForKey:@"Rows-iPad"]) {
      self.cols = [d objectForKey:@"Cols-iPad"];
      self.rows = [d objectForKey:@"Rows-iPad"];
      self.useiPadSpacingMath = YES;
      if ([d objectForKey:@"Cols-iPad-Landscape"] && [d objectForKey:@"Rows-iPad-Landscape"]) {
        self.landscapeCols = [d objectForKey:@"Cols-iPad-Landscape"];
        self.landscapeRows = [d objectForKey:@"Rows-iPad-Landscape"];
        NSAssert([landscapeCols count]*[landscapeRows count] == [cols count]*[rows count], @"GRID LAYOUT ERROR: Cols*Rows must be equal on portrait/landscape");
      }
    } else if (isiPhoneSixPlus && [d objectForKey:@"Cols-SixPlus"] && [d objectForKey:@"Rows-SixPlus"]) {
      self.cols = [d objectForKey:@"Cols-SixPlus"];
      self.rows = [d objectForKey:@"Rows-SixPlus"];
      if ([d objectForKey:@"Cols-SixPlus-Landscape"] && [d objectForKey:@"Rows-SixPlus-Landscape"]) {
        self.landscapeCols = [d objectForKey:@"Cols-SixPlus-Landscape"];
        self.landscapeRows = [d objectForKey:@"Rows-SixPlus-Landscape"];
        NSAssert([landscapeCols count]*[landscapeRows count] == [cols count]*[rows count], @"GRID LAYOUT ERROR: Cols*Rows must be equal on portrait/landscape");
      }
    } else if (shouldInheritiPhoneSixLayout && [d objectForKey:@"Cols-Six"] && [d objectForKey:@"Rows-Six"]) {
      self.cols = [d objectForKey:@"Cols-Six"];
      self.rows = [d objectForKey:@"Rows-Six"];
    } else if (shouldInheritiOSSevenTallLayout && [d objectForKey:@"Cols-7-Tall"] && [d objectForKey:@"Rows-7-Tall"]) {
        self.cols = [d objectForKey:@"Cols-7-Tall"];
        self.rows = [d objectForKey:@"Rows-7-Tall"];
        self.isSevenLayout = YES;
    } else if (hasTallScreen && [d objectForKey:@"Cols-Tall"] && [d objectForKey:@"Rows-Tall"]) {
        self.cols = [d objectForKey:@"Cols-Tall"];
        self.rows = [d objectForKey:@"Rows-Tall"];
    } else if (runningSeven && [d objectForKey:@"Cols-7-Short"] && [d objectForKey:@"Rows-7-Short"]) {
        self.cols = [d objectForKey:@"Cols-7-Short"];
        self.rows = [d objectForKey:@"Rows-7-Short"];
        self.isSevenLayout = YES;
    } else {
        self.cols = [d objectForKey:@"Cols"];
        self.rows = [d objectForKey:@"Rows"];
    }
    self.totalNumberOfIcons = [self.cols count] * [self.rows count];
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
    if ([d objectForKey:@"Cols-7-iPad-Landscape"] && [d objectForKey:@"Rows-7-iPad-Landscape"] && landscape && runningSeven)
      return [ICiPadLandscapeScaleEngine sharedInstance];
    if ([d objectForKey:@"Cols-iPad-Landscape"] && [d objectForKey:@"Rows-iPad-Landscape"] && landscape)
      return [ICiPadLandscapeScaleEngine sharedInstance];
    if ([d objectForKey:@"Cols-7-iPad"] && [d objectForKey:@"Rows-7-iPad"] && runningSeven)
      return [ICiPadScaleEngine sharedInstance];
    if ([d objectForKey:@"Cols-iPad"] && [d objectForKey:@"Rows-iPad"])
      return [ICiPadScaleEngine sharedInstance];
  }
  BOOL isiPhoneSixPlus = [[UIScreen mainScreen] bounds].size.height == 736;
  if (isiPhoneSixPlus && [d objectForKey:@"Cols-SixPlus-Landscape"] && [d objectForKey:@"Rows-SixPlus-Landscape"] && landscape) {
    return [ICiPhoneSixPlusLandscapeScaleEngine sharedInstance];
  }
  if (isiPhoneSixPlus && [d objectForKey:@"Cols-SixPlus"] && [d objectForKey:@"Rows-SixPlus"]) {
    return [ICiPhoneSixPlusPortraitScaleEngine sharedInstance];
  }
  BOOL isiPhoneSix = [[UIScreen mainScreen] bounds].size.height == 667;
  BOOL shouldInheritiPhoneSixLayout = isiPhoneSixPlus || isiPhoneSix;
  if (shouldInheritiPhoneSixLayout && [d objectForKey:@"Cols-Six"] && [d objectForKey:@"Rows-Six"]) {
    return [ICiPhoneSixScaleEngine sharedInstance];
  }
  BOOL hasTallScreen = [[UIScreen mainScreen] bounds].size.height == 568;
  BOOL shouldInheritiOSSevenTallLayout = isiPhoneSixPlus || isiPhoneSix || (hasTallScreen && runningSeven);
  if (shouldInheritiOSSevenTallLayout && [d objectForKey:@"Cols-7-Tall"] && [d objectForKey:@"Rows-7-Tall"])
    return [ICTallScaleEngine sharedInstance];
  if (hasTallScreen && [d objectForKey:@"Cols-Tall"] && [d objectForKey:@"Rows-Tall"])
    return [ICTallScaleEngine sharedInstance];
  return [ICShortScaleEngine sharedInstance];
}

-(int) iconRowsForInterfaceOrientation:(int)orientation {
  BOOL isiPhoneSixPlus = [[UIScreen mainScreen] bounds].size.height == 736;
  BOOL supportsLandscape = isiPad || isiPhoneSixPlus;
  if (supportsLandscape && self.landscapeRows && orientation > 2)
    return [self.landscapeRows count];
  return [self.rows count];
}

-(int) iconColumnsForInterfaceOrientation:(int)orientation {
  BOOL isiPhoneSixPlus = [[UIScreen mainScreen] bounds].size.height == 736;
  BOOL supportsLandscape = isiPad || isiPhoneSixPlus;
  if (supportsLandscape && self.landscapeCols && orientation > 2)
    return [self.landscapeCols count];
  return [self.cols count];
}

-(CGPoint) rawPointForX:(int)x Y:(int)y {
  return CGPointMake([self xCoordinateForColumn:x], [self yCoordinateForRow:y]);
}

-(CGPoint) pointForX:(int)x Y:(int)y inIconList:(UIView*)iL {
  BOOL isiPhoneSixPlus = [[UIScreen mainScreen] bounds].size.height == 736;
  BOOL supportsLandscape = isiPad || isiPhoneSixPlus;
  int orientation; CGPoint rawPt;
  object_getInstanceVariable(iL, "_orientation", (void**)&orientation);
  rawPt = ((self.landscapeCols) && (orientation > 2)) ? [self landscapeRawPointForX:x Y:y] : [self rawPointForX:x Y:y];
  CGSize s = iL.frame.size;
  if (supportsLandscape && (orientation > 2))
    rawPt = [self.scaleEngineLandscape scaledPointForPoint:rawPt withIconListDimensions:s orientation:orientation];
  else
    rawPt = [self.scaleEngine scaledPointForPoint:rawPt withIconListDimensions:s orientation:orientation];
  // Offsetting by screenfuls for scrolling views I guess
  int iconNum = (y * [self.cols count]) + x;
  int screenfulsToOffset = (iconNum / self.totalNumberOfIcons);
  rawPt.y += (screenfulsToOffset * s.height);
  // Integral
  rawPt.x = (int)rawPt.x;
  rawPt.y = (int)rawPt.y;
  return rawPt;
}

-(CGRect) rectForIcons {
  int upperMost=INT_MAX, leftMost=INT_MAX, rightMost=INT_MIN, bottomMost=INT_MIN;
  for (id _x in self.cols) {
    int x = [_x intValue];
    if (x < leftMost)
      leftMost = x;
    if (x+60 > rightMost)
      rightMost = x+60;
  }
  for (id _y in self.rows) {
    int y = [_y intValue];
    if (y < upperMost)
      upperMost = y;
    if (y+60 > bottomMost)
      bottomMost = y+60;
  }
  return CGRectMake(leftMost, upperMost, rightMost-leftMost, bottomMost-upperMost);

}

// Private
-(int) xCoordinateForColumn:(int)col {
  return [[self.cols objectAtIndex:(col % [self.cols count])] intValue];
}

-(int) yCoordinateForRow:(int)row {
  return [[self.rows objectAtIndex:(row % [self.rows count])] intValue];
}

// Landscape

-(CGPoint) landscapeRawPointForX:(int)x Y:(int)y {
  return CGPointMake([self landscapeXCoordinateForColumn:x], [self landscapeYCoordinateForRow:y]);
}

-(int) landscapeXCoordinateForColumn:(int)col {
  return [[self.landscapeCols objectAtIndex:(col % [self.landscapeCols count])] intValue];
}

-(int) landscapeYCoordinateForRow:(int)row {
  if (row >= [landscapeRows count]) {
    int relativeToPage = [[self.landscapeRows objectAtIndex:(row % [self.landscapeRows count])] intValue];
    int whichBlock = row / [self.landscapeRows count];
    int absolute = relativeToPage + (3 + [self yCoordinateForRow:([self.landscapeRows count]-1)] + 93) * whichBlock;
    return absolute;
  }
  return [[self.landscapeRows objectAtIndex:(row % [self.landscapeRows count])] intValue];
}

// Column/row at point for edge cases.
#define PADDING 5


-(int) columnAtPoint:(CGPoint)pt inIconList:(id)iL {
  int count = [self.colMinCache count];
  for (int i = count-1; i >= 0; i--) {
    // If we reverse through the rows we only need one comparison with the min
    int min = [[self.colMinCache objectAtIndex:i] intValue];
    if (pt.x >= min)
      return i;
  }
  return 0;
}

-(int) rowAtPoint:(CGPoint)pt inIconList:(id)iL {
  int count = [self.rowMinCache count];
  for (int i = count-1; i >= 0; i--) {
    // If we reverse through the rows we only need one comparison with the min
    int min = [[self.rowMinCache objectAtIndex:i] intValue];
    if (pt.y >= min)
      return i;
  }
  return 0;
}

-(NSString*) adequateOriginsKeyForScaleEngine:(id<ICScaleEngine>)se {
  if ([se isKindOfClass:[ICiPadLandscapeScaleEngine class]] && self.isSevenLayout) return @"Origins-7-iPad-Landscape";
  if ([se isKindOfClass:[ICiPadLandscapeScaleEngine class]]) return @"Origins-iPad-Landscape";
  if ([se isKindOfClass:[ICiPadScaleEngine class]] && self.isSevenLayout) return @"Origins-7-iPad";
  if ([se isKindOfClass:[ICiPadScaleEngine class]]) return @"Origins-iPad";
  if ([se isKindOfClass:[ICiPhoneSixPlusLandscapeScaleEngine class]]) return @"Origins-SixPlus-Landscape";
  if ([se isKindOfClass:[ICiPhoneSixPlusPortraitScaleEngine class]]) return @"Origins-SixPlus";
  if ([se isKindOfClass:[ICiPhoneSixScaleEngine class]]) return @"Origins-Six";
  if ([se isKindOfClass:[ICTallScaleEngine class]] && self.isSevenLayout) return @"Origins-7-Tall";
  if ([se isKindOfClass:[ICTallScaleEngine class]]) return @"Origins-Tall";
  if ([se isKindOfClass:[ICShortScaleEngine class]] && self.isSevenLayout) return @"Origins-7-Short";
  return @"Origins";
}

-(ICFreeformLayout*) freeformLayoutRepresentation {
  NSMutableDictionary* ffdict = [NSMutableDictionary dictionary];
  NSArray* origins = originsArrayFromGridArrays(self.cols, self.rows);
  NSString* originsKey = [self adequateOriginsKeyForScaleEngine:self.scaleEngine];
  [ffdict setObject:origins forKey:originsKey];
  if ((self.landscapeCols != nil) && (self.landscapeRows != nil)) {
    NSArray* originsL = originsArrayFromGridArrays(self.landscapeCols, self.landscapeRows);
    NSString* landscapeOriginsKey = [self adequateOriginsKeyForScaleEngine:self.scaleEngineLandscape];
    if (originsL) [ffdict setObject:originsL forKey:landscapeOriginsKey];
  }
  if (self.useRawPoints) [ffdict setObject:[NSNumber numberWithBool:YES] forKey:@"UseRawPoints"];
  return [[[ICFreeformLayout alloc] initWithDictionaryRepresentation:ffdict] autorelease];
}

-(void) recacheWithIconList:(id)iL {
  self.iconListSizeWhenCached = [iL bounds].size;
  NSMutableArray* mins = [NSMutableArray array];
  // Prep
  int orientation;
  int c;
  object_getInstanceVariable(iL, "_orientation", (void**)&orientation);
  Class sbi = kCFCoreFoundationVersionNumber < 675 ? objc_getClass("SBIcon") : objc_getClass("SBIconView");
  CGSize iconSize = [sbi defaultIconSize];
  int previousMax = INT_MIN;
  // Cols
  if (self.landscapeCols)
    c = [(orientation <= 2 ? self.cols : self.landscapeCols) count];
  else
    c = [self.cols count];
  for (int i=0; i < c; i++) {
    CGPoint origin = [self pointForX:i Y:0 inIconList:iL];
    int x = origin.x;
    // Calculate minimum; if previous max is found, just add one
    int min;
    if (previousMax != INT_MIN)
      min = previousMax + 1;
    else
      min = x - PADDING;
    // Calculate maximum
    int max;
    if (i < (c-1)) {
      CGPoint nextOrigin = [self pointForX:i+1 Y:0 inIconList:iL];
      int nextX = nextOrigin.x;
      int distance = (nextOrigin.x - (origin.x + iconSize.width));
      int padding = distance / 2;
      max = x + iconSize.width + padding;
    } else 
      max = x + iconSize.width + PADDING;
    previousMax = max;
    // Special cases for first and last cols
    if (i == 0)
      min = CGRectGetMinX([iL bounds]);
    if (i == (c-1))
      max = CGRectGetMaxX([iL bounds]);
    [mins addObject:[NSNumber numberWithInt:min]];
  }
  self.colMinCache = [[mins copy] autorelease];
  // Reset
  mins = [NSMutableArray array];
  previousMax = INT_MIN;
  // Rows
  if (self.landscapeRows)
    c = [(orientation <= 2 ? self.rows : self.landscapeRows) count];
  else
    c = [self.rows count];
  
  for (int i=0; i < c; i++) {
    CGPoint origin = [self pointForX:0 Y:i inIconList:iL];
    int y = origin.y;
    // Calculate minimum; if previous max is found, just add one
    int min;
    if (previousMax != INT_MIN)
      min = previousMax + 1;
    else
      min = y - PADDING;
    // Calculate maximum
    int max;
    if (i < (c-1)) {
      CGPoint nextOrigin = [self pointForX:0 Y:i+1 inIconList:iL];
      int nextY = nextOrigin.y;
      int distance = (nextOrigin.y - (origin.y + iconSize.height));
      int padding = distance / 2;
      max = y + iconSize.height + padding;
    } else
      max = y + iconSize.height + PADDING;
    previousMax = max;
    // Special cases for first and last rows
    if (i == 0)
      min = CGRectGetMinY([iL bounds]);
    if (i == (c-1))
      max = CGRectGetMaxY([iL bounds]);
    [mins addObject:[NSNumber numberWithInt:min]];
  }
  self.rowMinCache = [[mins copy] autorelease];
}

@end
