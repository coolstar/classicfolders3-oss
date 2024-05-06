#import "CSClassicFolderTextField.h"

@implementation CSClassicFolderTextField
- (CGRect)textRectForBounds:(CGRect)bounds 
{
    return CGRectMake(bounds.origin.x + 10, bounds.origin.y, bounds.size.width - 20, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds 
{
    return [self textRectForBounds:bounds];
}
@end