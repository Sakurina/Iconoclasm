/*
 * Iconoclasm 1.7.2
 */

#include "Iconoclasm.h"
CHDeclareClass(SBIconListView);
CHDeclareClass(SBRootIconListView);
CHDeclareClass(SBFolderIconListView);
CHDeclareClass(SBDockIconListView);
CHDeclareClass(SBNewsstandIconListView);
CHDeclareClass(SBIconListModel);
CHDeclareClass(SpringBoard);
CHDeclareClass(SBIconModel);
CHDeclareClass(ICIconListView);
CHDeclareClass(SBRootFolder);
CHDeclareClass(SBIconController);
CHDeclareClass(SBIconContentView);
CHDeclareClass(SBIconView);
CHDeclareClass(SBFolderIcon);

@interface SBDockIconListView
-(CGFloat) horizontalIconPadding;
-(CGFloat) sideIconInset;
@end
@interface SBIconView
+(CGSize) defaultIconSize;
@end

static BOOL infinidockDylibSpotted() {
  return [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Infinidock.dylib"];
}

// indexOfList takes an icon list model
#define indexOfList(iL) ((kCFCoreFoundationVersionNumber < 790.00) ? (NSUInteger)[[SBIMINSTANCE rootFolder] indexOfIconList:iL] : (NSUInteger)[[SBIMINSTANCE rootFolder] indexOfList:iL])
#define indexPath(s, r) ((kCFCoreFoundationVersionNumber < 790.00) ? [objc_getClass("SBIconIndexPath") indexPathWithIconIndex:r listIndex:s] : [NSIndexPath indexPathForRow:r inSection:s])
#define REMAINDER(array, startIndex) [array subarrayWithRange:NSMakeRange(startIndex, [array count]-startIndex)]

static id<ICLayout> defaultLayout = nil;
static NSString* defLayoutName = nil;
static BOOL freeformOn = NO;

static BOOL extrasEnabled = NO;
static id<ICLayout> extrasLayout = nil;
static NSString* extrasLayoutName = nil;
static BOOL extrasFreeformOn = NO;

static BOOL perPageOn = NO;
static NSArray* perPageLayoutNames = nil;
static NSArray* perPageLayouts = nil;
static int perPageMaxIcons;

static id<ICLayout> pp(int page) {
  page = (page > 10) ? 10 : page; 
  return [perPageLayouts objectAtIndex:page];
}

static id<ICLayout> ppp(id iL) {
  int page = indexOfList([iL model]);
  return pp(page);
}

/**********************/
#pragma mark "FALLBACK"
/**********************/

static NSDictionary* fallbackLayout() {
  NSArray* c = [NSArray arrayWithObjects:Nint(4), Nint(67), Nint(130), Nint(193), Nint(256), nil];
  NSArray* r = [NSArray arrayWithObjects:Nint(14), Nint(102), Nint(190), Nint(278), nil];
  return [NSDictionary dictionaryWithObjectsAndKeys:Nbool(YES), @"EasyGrid", c, @"Cols", r, @"Rows", nil];
}

/**********************/
#pragma mark "HOOKS"
/**********************/

CHClassMethod1(int, SBIconListView, iconRowsForInterfaceOrientation, int, interfaceOrientation) {
  if (perPageOn) return perPageMaxIcons;
  return [defaultLayout iconRowsForInterfaceOrientation:interfaceOrientation];
}

CHClassMethod1(int, SBIconListView, iconColumnsForInterfaceOrientation, int, interfaceOrientation) {
  if (perPageOn) return 1;
  return [defaultLayout iconColumnsForInterfaceOrientation:interfaceOrientation];
}

CHClassMethod1(int, SBRootIconListView, iconRowsForInterfaceOrientation, int, interfaceOrientation) {
  if (perPageOn) return perPageMaxIcons;
  return [defaultLayout iconRowsForInterfaceOrientation:interfaceOrientation];
}

CHClassMethod1(int, SBRootIconListView, iconColumnsForInterfaceOrientation, int, interfaceOrientation) {
  if (perPageOn) return 1;
  return [defaultLayout iconColumnsForInterfaceOrientation:interfaceOrientation];
}

CHMethod2(CGPoint, SBIconListView, originForIconAtX, int, x, Y, int, y) {
  if ([self class] == CHClass(ICIconListView))
    return CHSuper2(SBIconListView, originForIconAtX, x, Y, y);
  if (notVirginView(self))
    return CHSuper2(SBIconListView, originForIconAtX, x, Y, y);
  if (perPageOn) return [ppp(self) pointForX:x Y:y inIconList:(UIView*)self];
  return [defaultLayout pointForX:x Y:y inIconList:(UIView*)self];
}

struct SBIconCoordinate {
  NSUInteger row;
  NSUInteger col;
};

CHMethod1(CGPoint, SBRootIconListView, originForIconAtCoordinate, SBIconCoordinate, coord) {
  if ([self isKindOfClass:objc_getClass("SBDockIconListView")]) {
    CGPoint orig = CHSuper1(SBRootIconListView, originForIconAtCoordinate, coord);
    if (isiPad) {
      orig.y = 20;
    }
    return orig;
  }
  int page = indexOfList([self model]);
  int x = coord.col-1;
  int y = coord.row-1;
  if (perPageOn) return [ppp(self) pointForX:x Y:y inIconList:(UIView*)self];
  CGPoint origin = [defaultLayout pointForX:x Y:y inIconList:(UIView*)self];
  return [defaultLayout pointForX:x Y:y inIconList:(UIView*)self];
}

CHMethod0(CGFloat, SBDockIconListView, horizontalIconPadding) {
  // No bug on iPhone so just return the usual
  if (!isiPad)
    return CHSuper0(SBDockIconListView, horizontalIconPadding);

  NSUInteger iconCount = (NSUInteger)[self iconsInRowForSpacingCalculation];
  int orientation = 0;
  object_getInstanceVariable(self, "_orientation", (void**)&orientation);

  if (orientation <= 2) {
    // Portrait
    switch (iconCount) {
      case 5: return 56;
      case 6: return 44;
      default: return 100;
    }
  } else {
    // Landscape
    if (iconCount == 6)
      return 80;
    else
      return 120;
  }
}

CHMethod0(CGFloat, SBDockIconListView, _additionalSideInsetToCenterIcons) {
  // No bug on iPhone so just return the usual
  if (!isiPad)
    return CHSuper0(SBDockIconListView, _additionalSideInsetToCenterIcons);

  NSUInteger iconCount = (NSUInteger)[self iconsInRowForSpacingCalculation];
  if (infinidockDylibSpotted())
    iconCount = (NSUInteger)[[self visibleIcons] count];

  CGFloat dockWidth = ((CGRect)([self bounds])).size.width;

  CGFloat iconWidth = ((CGSize)([CHClass(SBIconView) defaultIconSize])).width;
  CGFloat horizPadding = ((CGFloat)([self horizontalIconPadding]));
  CGFloat sideIconInset = ((CGFloat)([self sideIconInset]));
  return (dockWidth - (iconWidth * iconCount) - (horizPadding * (iconCount - 1)) - (2 * sideIconInset)) / 2;
}

CHMethod1(int, SBIconListView, columnAtPoint, CGPoint, point) {
  if (notVirginView(self))
    return CHSuper1(SBIconListView, columnAtPoint, point);
  if (perPageOn) return [ppp(self) columnAtPoint:point inIconList:(UIView*)self];
  return [defaultLayout columnAtPoint:point inIconList:(UIView*)self];
}

CHMethod1(int, SBIconListView, rowAtPoint, CGPoint, point) {
  if (notVirginView(self))
    return CHSuper1(SBIconListView, rowAtPoint, point);
  if (perPageOn) return [ppp(self) rowAtPoint:point inIconList:(UIView*)self];
  return [defaultLayout rowAtPoint:point inIconList:(UIView*)self];
}

CHMethod0(void, SBIconContentView, layoutSubviews) {
  CHSuper0(SBIconContentView, layoutSubviews);
  [defaultLayout recacheWithIconList:[[CHClass(SBIconController) sharedInstance] rootIconListAtIndex:0]];
}


/**************************/
#pragma mark "DEVELOPER API"
/**************************/

CHClassMethod1(int, ICIconListView, iconRowsForInterfaceOrientation, int, interfaceOrientation) {
  return [extrasLayout iconRowsForInterfaceOrientation:interfaceOrientation];
}

CHClassMethod1(int, ICIconListView, iconColumnsForInterfaceOrientation, int, interfaceOrientation) {
  return [extrasLayout iconColumnsForInterfaceOrientation:interfaceOrientation];
}

CHMethod2(CGPoint, ICIconListView, originForIconAtX, int, x, Y, int, y) {
  return [extrasLayout pointForX:x Y:y inIconList:(UIView*)self];
}

CHMethod1(int, ICIconListView, columnAtPoint, CGPoint, point) {
  return [extrasLayout columnAtPoint:point inIconList:(UIView*)self];
}

CHMethod1(int, ICIconListView, rowAtPoint, CGPoint, point) {
  return [extrasLayout rowAtPoint:point inIconList:(UIView*)self];
}

/**********************/
#pragma mark "PER-PAGE STUFFS"
/**********************/

#define isNullIcon(i) ([i isKindOfClass:objc_getClass("SBDestinationHole")] || [i isKindOfClass:objc_getClass("SBNullIcon")])

#define isRealIcon(i) !isNullIcon(i)

static int realIconCount(id model) {
  // Excludes the one currently being added/moved.
  NSArray* icons = [model icons];
  int realIcons = 0;
  for (id i in icons) {
    if (isRealIcon(i))
      realIcons++;
  }
  return realIcons;
}

CHMethod2(id, SBIconListModel, insertIcon, id, icon, atIndex, unsigned*, index) {
  // Before and after have accurate icon counts; before has a null icon at the destination slot, after doesn't
  id sup = CHSuper2(SBIconListModel, insertIcon, icon, atIndex, index);
  if (notVirginModel(self)) return sup;
  if (kCFCoreFoundationVersionNumber > 800)
    if (![[self folder] isEqual:[[CHClass(SBIconController) sharedInstance] rootFolder]]) 
      return sup;
  // After super is called, get a subarray of icons where index >= maxIcons
  NSUInteger whichPage = indexOfList(self);
  if (whichPage == UINT_MAX) return sup;
  int maxIcons = [[pp(whichPage) origins] count];
  if (realIconCount(self) <= maxIcons)
    return sup;
  int end = [[self icons] count] - maxIcons;
  NSArray* overflowing = [[self icons] subarrayWithRange:NSMakeRange(maxIcons, end)];
  // Reverse array, remove icon from this icon list, insert at index 0 of next list
  NSEnumerator* enumerator = [overflowing reverseObjectEnumerator];
  id element;
  while (element = [enumerator nextObject]) {
    [self removeIcon:element];
    unsigned zero = 0;
    [getNextPage_model(whichPage) insertIcon:element atIndex:&zero];
  }
  return sup;
}


CHMethod1(id, SBRootFolder, indexPathForFirstFreeSlotAvoidingFirstList, BOOL, avoidFirstList) {
  int firstList = avoidFirstList ? 1 : 0;
  id lists = [[SBIMINSTANCE rootFolder] lists];
  for (int i=firstList; i < [lists count]; i++) {
    id list = [[self lists] objectAtIndex:i];
    int iconCount = realIconCount(list);
    int maxIcons = [[pp(i) origins] count];
    if (iconCount < maxIcons) {
      return indexPath(i, iconCount);
    } 
  }
  // Didn't find a non-full list -> create one
  id emptyList = [[SBIMINSTANCE rootFolder] addEmptyList];
  NSUInteger emptyListIndex = indexOfList(emptyList);
  return indexPath(emptyListIndex, 0);
}
/**********************/
#pragma mark "STARTUP"
/**********************/

static NSDictionary* layoutDictForName(NSString* name) {
  //return [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Users/sakurina/src/_projects/Iconoclasm/net.r-ch.iconoclasm/Library/Iconoclasm/Layouts/%@.plist", name]];
  return [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/Library/Iconoclasm/Layouts/%@.plist", name]];
}

static id<ICLayout> layoutForName(NSString* name, BOOL* isFreeform) {
  NSDictionary* dict = layoutDictForName(name) ?: fallbackLayout();
  *isFreeform = !isEasyGrid(dict);
  if (!(*isFreeform))
    return [[[ICGridLayout alloc] initWithDictionaryRepresentation:dict] autorelease];
  else
    return [[[ICFreeformLayout alloc] initWithDictionaryRepresentation:dict] autorelease];
}

static void prepareDefaultLayout() {
  defaultLayout = [layoutForName(defLayoutName, &freeformOn) retain];
}

static void prepareExtrasLayout() {
  extrasLayout = [layoutForName(extrasLayoutName, &extrasFreeformOn) retain];
}

static BOOL infiniboardDylibSpotted() {
  return [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Infiniboard.dylib"];
}


BOOL isEnabled() {
  NSNumber* enabledNum = (NSNumber*) ICPref(@"Enable");
  if (enabledNum && ![enabledNum boolValue])
    return NO;

  defLayoutName = [(NSString*)ICPref(@"CurrentLayout") retain] ?: @"Five-Column SB (5x4)";
  NSDictionary* dld = layoutDictForName(defLayoutName);
  if (dld)
    freeformOn = !isEasyGrid(dld);
  else
    freeformOn = NO;

  NSNumber* extrasEnabledNum = (NSNumber*) ICPref(@"ExtrasEnabled");
  if (extrasEnabledNum != nil) {
    extrasEnabled = [extrasEnabledNum boolValue];
  } else {
    extrasEnabled = NO;
  }

  extrasLayoutName = [(NSString*)ICPref(@"ExtrasLayout") retain] ?: @"Five-Column SB (5x4)";
  NSDictionary* extrasDict = layoutDictForName(extrasLayoutName);
  if (extrasDict)
    extrasFreeformOn = !isEasyGrid(extrasDict);
  else
    extrasFreeformOn = NO;

  if (kCFCoreFoundationVersionNumber < 675.00) return YES;
  if (infiniboardDylibSpotted()) return YES;

  NSNumber* perPageOnNum = (NSNumber*) ICPref(@"PerPageLayoutsEnabled");
  perPageOn = [perPageOnNum boolValue];
  if (perPageOn) {
    NSArray* _perPageLayoutNames = [NSArray array];
    for (int i=0; i<11; i++) {
      NSString* prefKey = [NSString stringWithFormat:@"PerPageLayout-Page%i", i];
      NSString* prefValue = ((NSString*) ICPref(prefKey) ?: @"Five-Column SB (5x4)");
      _perPageLayoutNames = [_perPageLayoutNames arrayByAddingObject:prefValue];
    }
    perPageLayoutNames = [_perPageLayoutNames retain];
  }

  return YES;
}

static void preparePerPageLayouts() {
  if (!perPageOn) return;
  perPageMaxIcons = INT_MIN;

  NSArray* _layouts = [NSArray array];
  for (NSString* name in perPageLayoutNames) {
    BOOL isFreeform = NO;
    id<ICLayout> l = [layoutForName(name, &isFreeform) freeformLayoutRepresentation];
    int iconCount = [[l origins] count];
    if (iconCount > perPageMaxIcons) perPageMaxIcons = iconCount;
    _layouts = [_layouts arrayByAddingObject:l];
  }
  perPageLayouts = [_layouts retain];
}

CHMethod1(void, SpringBoard, applicationDidFinishLaunching, id, application) {
  prepareDefaultLayout();
  prepareExtrasLayout();
  preparePerPageLayouts();
  CHSuper1(SpringBoard, applicationDidFinishLaunching, application);
  if ((kCFCoreFoundationVersionNumber >= 550) && (kCFCoreFoundationVersionNumber <= 600))
    [[objc_getClass("ISIconSupport") sharedInstance] repairAndReloadIconState];
}

CHMethod0(NSDictionary*, SBIconModel, iconState) {
  NSDictionary* iconState = CHSuper0(SBIconModel, iconState);
  NSArray* remainder = [NSArray array];
  NSArray* pages = [NSArray array];
  NSArray* originals = [iconState objectForKey:@"iconLists"];
  int i = 0;
  for (NSArray* o in originals) {
    int maxCount = [[pp(i) origins] count];
    if ([o count] <= maxCount) {
      pages = [pages arrayByAddingObject:o];
    } else {
      NSArray* p = [o subarrayWithRange:NSMakeRange(0,maxCount)];
      NSArray* r = REMAINDER(o, maxCount);
      pages = [pages arrayByAddingObject:p];
      remainder = [remainder arrayByAddingObjectsFromArray:r];
    }
    i++;
  }
  while ([remainder count] > 0) {
    int maxCount = [[pp(i) origins] count];
    if ([remainder count] <= maxCount) {
      pages = [pages arrayByAddingObject:remainder];
      break;
    } else {
      NSArray* p = [remainder subarrayWithRange:NSMakeRange(0, maxCount)];
      pages = [pages arrayByAddingObject:p];
      remainder = REMAINDER(remainder, maxCount);
      i++;
    }
  }
  return [NSDictionary dictionaryWithObjectsAndKeys:pages, @"iconLists", [iconState objectForKey:@"buttonBar"], @"buttonBar", nil];
}

/*******************************/
#pragma mark "IN FOLDERS (iOS7+)"
/*******************************/

CHClassMethod1(int, SBFolderIconListView, iconRowsForInterfaceOrientation, int, interfaceOrientation) {
  return [extrasLayout iconRowsForInterfaceOrientation:interfaceOrientation];
}

CHClassMethod1(int, SBFolderIconListView, iconColumnsForInterfaceOrientation, int, interfaceOrientation) {
  return [extrasLayout iconColumnsForInterfaceOrientation:interfaceOrientation];
}

CHMethod1(CGPoint, SBFolderIconListView, originForIconAtCoordinate, SBIconCoordinate, coord) {
  int x = coord.col-1;
  int y = coord.row-1;
  return [extrasLayout pointForX:x Y:y inIconList:(UIView*)self];
}

CHClassMethod0(int, SBFolderIcon, _maxIconsInGridImage) {
  CGFloat iconWidth = ((CGSize)([CHClass(SBIconView) defaultIconSize])).width;
  CGFloat iconHeight = ((CGSize)([CHClass(SBIconView) defaultIconSize])).height;
  // Thanks to ashikase for the fix
  // Without this, the folder icon breaks on any layout with less icons than the default icon dimensions
  return [extrasLayout iconRowsForInterfaceOrientation:0] * [extrasLayout iconRowsForInterfaceOrientation:0];
}

/**********************/
#pragma mark "CONSTRUCTOR"
/**********************/

CHConstructor {
  @autoreleasepool {
    if (!isEnabled()) {
      return;
    }

    BOOL runningSeven = kCFCoreFoundationVersionNumber > 800;

    // IconSupport
    dlopen("/Library/MobileSubstrate/DynamicLibraries/IconSupport.dylib", RTLD_NOW);
    [[objc_getClass("ISIconSupport") sharedInstance] addExtension:@"net.r-ch.iconoclasm"];

    CHLoadLateClass(SpringBoard);
    CHLoadLateClass(SBIconListView);
    CHLoadLateClass(SBRootIconListView);
    CHLoadLateClass(SBFolderIconListView);
    CHLoadLateClass(SBDockIconListView);
    CHLoadLateClass(SBNewsstandIconListView);
    CHLoadLateClass(SBIconModel);
    CHLoadLateClass(SBIconListModel);
    CHLoadLateClass(SBRootFolder);
    CHLoadLateClass(SBIconController);
    CHLoadLateClass(SBIconContentView);
    CHLoadLateClass(SBIconView);
    CHLoadLateClass(SBFolderIcon);

    CHHook1(SpringBoard, applicationDidFinishLaunching);
    if (!runningSeven)
      CHClassHook1(SBIconListView, iconRowsForInterfaceOrientation);
      CHClassHook1(SBIconListView, iconColumnsForInterfaceOrientation);
      CHHook2(SBIconListView, originForIconAtX, Y);

    if (freeformOn || perPageOn || runningSeven) {
      // Add these on iOS 7 too because grid math is just wonky
      CHHook1(SBIconListView, columnAtPoint);
      CHHook1(SBIconListView, rowAtPoint);
    }

    CHRegisterClass(ICIconListView, SBIconListView) {
      CHClassHook1(ICIconListView, iconRowsForInterfaceOrientation);
      CHClassHook1(ICIconListView, iconColumnsForInterfaceOrientation);
      CHHook2(ICIconListView, originForIconAtX, Y);

      if (extrasFreeformOn || freeformOn) {
        CHHook1(ICIconListView, columnAtPoint);
        CHHook1(ICIconListView, rowAtPoint);
      }
    }

    if (perPageOn) {
      CHHook2(SBIconListModel, insertIcon, atIndex);
      CHHook1(SBRootFolder, indexPathForFirstFreeSlotAvoidingFirstList);
      CHHook0(SBIconModel, iconState);
    }

    // iOS 7
    if (runningSeven) {
      CHClassHook1(SBRootIconListView, iconRowsForInterfaceOrientation);
      CHClassHook1(SBRootIconListView, iconColumnsForInterfaceOrientation);
      CHHook1(SBRootIconListView, originForIconAtCoordinate);

      if ((freeformOn || perPageOn) && !infinidockDylibSpotted()) {
        CHHook0(SBDockIconListView, horizontalIconPadding);
        CHHook0(SBDockIconListView, _additionalSideInsetToCenterIcons);
      }
      
      if (!freeformOn && !perPageOn)
        CHHook0(SBIconContentView, layoutSubviews);

      if (extrasEnabled) {
        CHClassHook0(SBFolderIcon, _maxIconsInGridImage);
        CHClassHook1(SBFolderIconListView, iconRowsForInterfaceOrientation);
        CHClassHook1(SBFolderIconListView, iconColumnsForInterfaceOrientation);
        CHHook1(SBFolderIconListView, originForIconAtCoordinate);
      }

    }
  }
}
