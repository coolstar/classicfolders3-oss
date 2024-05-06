#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Remover : NSObject {
}

@end


@implementation Remover

- (NSArray *)filePathsiPhone {
	return @[
		@"/System/Library/CoreServices/SpringBoard.app/FolderDropBG@2x~iphone.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowBottom@2x~iphone.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowBottomNotch@2x~iphone.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowTop@2x~iphone.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowTopNotch@2x~iphone.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderSwitcherBG-568h@2x~iphone.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderTitleEditField@2x.png"
		];
}

- (NSArray *)filePathsiPad {
	return @[
		@"/System/Library/CoreServices/SpringBoard.app/FolderDropBG~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderIconOverlay~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowBottom~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowBottomNotch~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowSide~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowTop~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowTopNotch~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderSwitcherBG~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderTitleEditField.png"
		];
}

- (NSArray *)filePathsiPadRetina {
	return @[
		@"/System/Library/CoreServices/SpringBoard.app/FolderDropBG@2x~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderIconOverlay@2x~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowBottom@2x~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowBottomNotch@2x~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowSide@2x~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowTop@2x~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderShadowTopNotch@2x~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderSwitcherBG@2x~ipad.png",
		@"/System/Library/CoreServices/SpringBoard.app/FolderTitleEditField@2x.png"
		];
}

- (NSArray *)filePaths { 
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		if ([[UIScreen mainScreen] scale] > 1.0){
			return [self filePathsiPadRetina];
		} else {
			return [self filePathsiPad];
		}
	} else {
		return [self filePathsiPhone];
	}
}

- (BOOL)uninstall {
	NSArray *files = [self filePaths];
	for (NSString *path in files){
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
	return true;
}

@end


int main(int argc, char **argv, char **envp) {
	BOOL success = NO;
	@autoreleasepool {
		unlink("/var/mobile/Library/Preferences/org.coolstar.classicfolders.license");
		unlink("/var/mobile/Library/Preferences/org.coolstar.classicfolders.license.signed");
		unlink("/var/mobile/Library/Preferences/org.coolstar.classicfolders2.license");
		unlink("/var/mobile/Library/Preferences/org.coolstar.classicfolders2.license.signed");
        unlink("/usr/lib/cslicenses/org.coolstar.classicfolders2.license");
        unlink("/usr/lib/cslicenses/org.coolstar.classicfolders2.license.signed");
		char *arg2 = argv[1];
		if (![[NSString stringWithUTF8String:arg2] isEqualToString:@"remove"]){
			NSLog(@"%@",@"Not removing files for upgrade.");
			return 0;
		}
		Remover *remover = [[Remover alloc] init];
		success = [remover uninstall];
		[remover release];
	}
	return (success ? 0 : 1);
}

