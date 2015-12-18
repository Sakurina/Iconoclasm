#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSTableCell.h>

static BOOL infiniboardDylibSpotted() {
  return [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Infiniboard.dylib"];
}

@interface IconoclasmPrefsController : PSListController {
}
@end

@implementation IconoclasmPrefsController

-(void) respring:(id)unused {
  if (kCFCoreFoundationVersionNumber < 790.00)
    system("killall SpringBoard");
  else
    system("killall backboardd");
}

-(NSString*) navigationTitle {
  return @"Iconoclasm";
}

-(NSArray*) specifiers {
  if (!_specifiers) {
    _specifiers = [[self loadSpecifiersFromPlistName:@"IconoclasmPrefs" target:self] retain];

    if (kCFCoreFoundationVersionNumber < 675.00) {
      for (PSSpecifier* spec in _specifiers) {
        if ([[spec propertyForKey:@"key"] hasPrefix:@"PerPage"]) {
          [spec setProperty:[NSNumber numberWithBool:NO] forKey:@"enabled"];
        }
      }
    }
    if (infiniboardDylibSpotted()) {
      for (PSSpecifier* spec in _specifiers) {
        if ([[spec propertyForKey:@"id"] isEqualToString:@"PPGroup"]) {
          [spec setProperty:@"This feature currently does not work alongside Infiniboard." forKey:@"footerText"];
        }
        if ([[spec propertyForKey:@"key"] hasPrefix:@"PerPage"]) {
          [spec setProperty:[NSNumber numberWithBool:NO] forKey:@"enabled"];
        }
      }
    }

  }
  return _specifiers;
}

-(NSArray*) layouts {
  NSArray* layoutsRaw = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Iconoclasm/Layouts" error:nil];
  NSMutableArray* layoutsNoPlist = [NSMutableArray array];
  for (NSString* layout in layoutsRaw) {
    if ([layout hasSuffix:@".plist"])
      [layoutsNoPlist addObject:[layout stringByReplacingOccurrencesOfString:@".plist" withString:@""]];
  }
  return layoutsNoPlist;
}

// Called by "Enable Iconoclasm"
// Used to prepare the SB for 4 columns and respring on toggle; may want to remove icon caches as well though that's minor
-(void) setToggle:(id)value specifier:(NSString*)specifier {
  [self setPreferenceValue:value specifier:specifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self respring:nil];
}

-(void) getMoreLayouts:(id)unused {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://sections/Addons%20(Iconoclasm)"]];
}

@end
