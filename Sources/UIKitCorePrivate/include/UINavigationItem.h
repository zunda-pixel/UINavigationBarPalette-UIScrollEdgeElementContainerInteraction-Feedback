#include "_UINavigationBarPalette.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN API_AVAILABLE(ios(13.4))
@interface UINavigationItem (_UINavigationBarPaletteAdditions)

@property (nonatomic, strong, nullable, getter=_topPalette,    setter=_setTopPalette:)    _UINavigationBarPalette *_topPalette;
@property (nonatomic, strong, nullable, getter=_bottomPalette, setter=_setBottomPalette:) _UINavigationBarPalette *_bottomPalette;

@end

NS_ASSUME_NONNULL_END
