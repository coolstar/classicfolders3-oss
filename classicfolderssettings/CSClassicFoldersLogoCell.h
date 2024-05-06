#import <UIKit/UIKit.h>

@interface PSTableCell : UITableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(id)arg3;
@end

@interface CSClassicFoldersLogoCell : PSTableCell {
	UIImageView *_logo;
}

@end