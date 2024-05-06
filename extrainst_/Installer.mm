
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <CoreFoundation/CFPropertyList.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <stdint.h>

#include "partial/partial.h"

#define kCSUpdateZIPRootPath @"AssetData/payload/replace"
#define kCSWorkingDirectory @"/tmp/classicfolders/"
#define SPLog NSLog

@interface Installer : NSObject {
}

@end

void callback(ZipInfo* info, CDFile* file, size_t progress) {
	int percentDone = progress * 100/file->compressedSize;
	SPLog(@"Getting: %d%%\n", percentDone);
}


@implementation Installer

- (NSString *)zipURL {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		if ([[UIScreen mainScreen] scale] > 1.0){
			//iPad 3 iOS 6.1.3
			return @"http://appldnld.apple.com/iOS6.1/091-3360.20130311.BmfR4/com_apple_MobileAsset_SoftwareUpdate/be85a5414fb52e4576a460a084f720c78119eb9f.zip";
		} else {
			//iPad 2 iOS 6.1.3
			return @"http://appldnld.apple.com/iOS6.1/091-3360.20130311.BmfR4/com_apple_MobileAsset_SoftwareUpdate/f43aceb9e06c9d1d0fdce491bdc0222093c8b377.zip";
		}
	} else {
		//iPod 5 iOS 6.1.3
		return @"http://appldnld.apple.com/iOS6.1/091-2634.20130319.Zza12/com_apple_MobileAsset_SoftwareUpdate/faa4165518414978e1a1e58a84480704a34c1548.zip";
	}
}

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

- (ZipInfo *)openZipFile {
	ZipInfo *info = PartialZipInit([[self zipURL] UTF8String]);
	return info;
}

- (BOOL)checkFilesExist {
	NSArray *files = [self filePaths];
	for (NSString *path in files){
		if (![[NSFileManager defaultManager] fileExistsAtPath:path])
			return false;
	}
	return true;
}

- (BOOL)downloadFilesFromZip:(ZipInfo *)info {
	BOOL success = YES;

	NSArray *files = [self filePaths];
	SPLog(@"Files: %@",files);
	//NSInteger count = [files count];
	for (NSString *path in files){
		SPLog(@"Downloading File: %@",path);
		NSString *zipPath = [kCSUpdateZIPRootPath stringByAppendingString:path];
		CDFile* file = PartialZipFindFile(info, [zipPath UTF8String]);
		if(!file)
		{
			SPLog(@"Cannot find %@\n", path);
			return 0;
		}

		unsigned char* data = PartialZipGetFile(info, file);
		int dataLen = file->size; 

		data = (unsigned char *)realloc(data, dataLen + 1);
		data[dataLen] = '\0';
	
		NSString *cachedPath = [kCSWorkingDirectory stringByAppendingString:[path lastPathComponent]];

		FILE* out;
		out = fopen([cachedPath UTF8String], "w");
		if (out == NULL)
		{
			SPLog(@"Failed to open file");
			exit(-1);
		}

		int done = 0;
		done = fwrite(data, sizeof(char), dataLen, out);
	
		fclose(out);

		free(data);
	}

	return success;
}

- (BOOL)installFiles {
	BOOL success = YES;

	for (NSString *path in [self filePaths]) {
		NSString *cachedPath = [kCSWorkingDirectory stringByAppendingPathComponent:[path lastPathComponent]];
		[[NSFileManager defaultManager] moveItemAtPath:cachedPath toPath:path error:nil];
	}

	return success;
}


- (BOOL)createCache {
	BOOL success =  YES;

	success = [[NSFileManager defaultManager] createDirectoryAtPath:kCSWorkingDirectory withIntermediateDirectories:NO attributes:nil error:NULL];

	return success;
}

- (BOOL)cleanUp {
	return [[NSFileManager defaultManager] removeItemAtPath:kCSWorkingDirectory error:NULL];
}

- (BOOL)install {
	BOOL success = YES;

	if ([self checkFilesExist]){
		SPLog(@"Files Exist. Exiting Normally.");
		return YES;
	}

	SPLog(@"Preparing...");
	[self cleanUp];

	SPLog(@"Creating download cache.");
	success = [self createCache];
	if (!success) { SPLog(@"Failed creating cache."); return success; }

	SPLog(@"Opening remote ZIP.");
	ZipInfo *info = [self openZipFile];
	if (!info) { [self cleanUp]; return false; }

	PartialZipSetProgressCallback(info, callback);

	SPLog(@"Downloading files to cache.");
	success = [self downloadFilesFromZip:info];
	if (!success) { PartialZipRelease(info); [self cleanUp]; SPLog(@"Failed downloading files."); return success; }

	SPLog(@"Installing downloaded files.");
	success = [self installFiles];
	if (!success) { PartialZipRelease(info); [self cleanUp];  SPLog(@"Failed installing files."); return success; }

	PartialZipRelease(info);

	SPLog(@"Cleaning up.");
	[self cleanUp];

	SPLog(@"Done!");
	return success;
}

@end


int main(int argc, char **argv, char **envp) {
	BOOL success = NO;
	unlink("/var/mobile/Library/Preferences/org.coolstar.classicfolders.license");
	unlink("/var/mobile/Library/Preferences/org.coolstar.classicfolders.license.signed");
	unlink("/var/mobile/Library/Preferences/org.coolstar.classicfolders2.license");
	unlink("/var/mobile/Library/Preferences/org.coolstar.classicfolders2.license.signed");
	unlink("/usr/lib/cslicenses/org.coolstar.classicfolders2.license");
	unlink("/usr/lib/cslicenses/org.coolstar.classicfolders2.license.signed");
	@autoreleasepool {
		Installer *installer = [[Installer alloc] init];
		success = [installer install];
		[installer release];
	}
	return (success ? 0 : 1);
}

