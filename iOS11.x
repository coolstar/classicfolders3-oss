#import "Headers.h"

#define isModern [[CSClassicFolderSettingsManager sharedInstance] modern]

%group FolderHooks
%hook SBFolderIconListView

+ (NSUInteger)iconColumnsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)){
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
			return 5;
		else {
			if ([[UIScreen mainScreen] bounds].size.width > 320){
				return 6;
			} else if ([[UIScreen mainScreen] bounds].size.height > 480){
				return 5;
			} else {
				return 4;
			}
		}
	}
	return 4;
}

+ (NSUInteger)maxVisibleIconRowsInterfaceOrientation:(UIInterfaceOrientation)arg1 {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		return %orig;
	else {
		if ([[UIScreen mainScreen] bounds].size.width > 320){
				return 5;
		} else if ([[UIScreen mainScreen] bounds].size.height > 480){
				return 4;
		} else {
				return 3;
		}
	}
}

- (CGFloat)sideIconInset {
	if (isModern)
		return 17.0f;

	if ([[UIScreen mainScreen] bounds].size.width > 320 && [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
		return 27.0f;
	else
		return 17.0f;
}

- (CGFloat)bottomIconInset {
	return 5.0f;
}
%end

%hook SBFloatingDockViewController
- (void)_presentFolderForIcon:(SBFolderIcon *)folderIcon animated:(BOOL)animated completion:(id)completion {
	if (!verifyUDID())
		safeMode();

	if (folderIcon && [self _shouldOpenFolderIcon:folderIcon]){
			SBIconViewMap *map = [[self userIconListView] viewMap];
			if ([map mappedIconViewForIcon:folderIcon] == nil){
				NSLog(@"%@ No folder icon view for %@",self,folderIcon);
				return;
			}

			SBIconController *iconController = [self iconController];

			SBFolderController *folderController = [[%c(SBFolderController) alloc] initWithFolder:[folderIcon folder] orientation:[iconController orientation] viewMap:map];
			[folderController setFolderDelegate:self];
			[folderController setLegibilitySettings:[self legibilitySettings]];
			[folderController setEditing:[iconController isEditing]];

			SBFolderPresentingViewController *presentingController = [self folderPresentingViewController];
			[presentingController presentFolderController:folderController animated:NO completion:nil];

			if ([folderController _contentViewClass] == %c(CSClassicFolderView)){
				CSClassicFolderView *folderView = (CSClassicFolderView *)[folderController contentView];
				[folderView openFolder:animated completion:completion];
				[folderView setFolderController:folderController];
			}
			return;
	} else {
		NSLog(@"Folder icon %@ cannot be opened because it does not exist in the user icon list",folderIcon);
		return;
	}
}

- (void)dismissPresentedFolderAnimated:(BOOL)animated withTransitionContext:(id)context completion:(id)completion {
	if (!verifyUDID())
		safeMode();

	SBFolderPresentingViewController *presentingController = [self folderPresentingViewController];

	SBFolderController *folderController = [presentingController presentedFolderController];
	if (folderController){
		if ([folderController innerFolderController] != nil){
			[folderController popFolderAnimated:animated completion:completion];
			return;
		} else {
			CSClassicFolderView *folderView = (CSClassicFolderView *)[folderController contentView];
			if ([folderView respondsToSelector:@selector(closeFolder:completion:)]){
				[folderView closeFolder:animated completion:^(BOOL finished){
					[presentingController dismissPresentedFolderControllerAnimated:NO completion:completion];
				}];
			} else {
				[presentingController dismissPresentedFolderControllerAnimated:NO completion:completion];
			}
			return;
		}
	}
}
%end

%hook SBFolderController
-(BOOL)pushFolderIcon:(SBFolderIcon *)folderIcon animated:(BOOL)animated completion:(id)completion {
	if (!verifyUDID())
		safeMode();
	
	if (![self isOpen]){
		NSLog(@"%@ Unable to open folder icon %@ because we aren't actually open!",self,folderIcon);
		return NO;
	}

	if ((folderIcon != nil) && ([self shouldOpenFolderIcon:folderIcon])){
		SBIconController *controller = [%c(SBIconController) sharedInstance];
		SBIconViewMap *viewMap = [controller homescreenIconViewMap];

		SBFolderController *innerController = [[%c(SBFolderController) alloc] initWithFolder:[folderIcon folder] orientation:[self orientation] viewMap:viewMap];
		[self pushNestedViewController:innerController animated:NO withCompletion:completion];

		if ([innerController _contentViewClass] == %c(CSClassicFolderView)){
			CSClassicFolderView *folderView = (CSClassicFolderView *)[innerController contentView];
			[folderView openFolder:animated completion:nil];
			[folderView setFolderController:self];
		}
		return YES;
	} else {
		NSLog(@"%@ Folder icon %@ cannot be opened because it does not exist on the current page.",self,folderIcon);
		return NO;
	}
	return YES;
}

- (BOOL)popFolderAnimated:(BOOL)animated completion:(void(^)(BOOL finished))completion {
	if (!verifyUDID())
		safeMode();

	SBFolderController *innerController = [self innerFolderController];
	if (innerController != nil){
		if ([innerController innerFolderController] != nil){
			return [[innerController innerFolderController] popFolderAnimated:animated completion:completion];
		} else {
			CSClassicFolderView *folderView = (CSClassicFolderView *)[innerController contentView];
			if ([folderView respondsToSelector:@selector(closeFolder:completion:)]){
				[folderView closeFolder:animated completion:^(BOOL finished){
					[self popNestedViewControllerAnimated:NO withCompletion:completion];
				}];
				return YES;
			} else {
				[self popNestedViewControllerAnimated:animated withCompletion:completion];
				return YES;
			}
		}
	} else {
		return NO;
	}
}

- (void)popNestedViewControllerAnimated:(BOOL)animated withCompletion:(void(^)(BOOL finished))completion {
	SBFolderController *innerController = [self innerFolderController];
	[innerController retain];
	%orig();
	if (innerController != nil){
		if (innerController != [self innerFolderController]){
			CSClassicFolderView *folderView = (CSClassicFolderView *)[innerController contentView];
			if ([folderView respondsToSelector:@selector(closeFolder:completion:)])
				[folderView closeFolder:NO completion:nil];
		}
		[innerController release];
	}
}

-(Class)_contentViewClass {
	return %c(CSClassicFolderView);
}
%end
%end

%ctor {
	if (kCFCoreFoundationVersionNumber >= 1443 && kCFCoreFoundationVersionNumber < 1600){
		if ([[CSClassicFolderSettingsManager sharedInstance] enabled]){
			%init(FolderHooks);
		}
	}
}
