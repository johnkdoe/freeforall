//
//  xolawareSegmentedControl.h
//  xolawareUI
//
//  Based on an CustomSegmentedControl by Created by Peter Boctor on 12/10/10.
//	He deserves credit for the idea, the initial implementation, and the member implementations
//	of touchDownAction:, touchUpInsideAction:, otherTouchesAction: and most of
//	dimAllButtonsExcept:
//
//	This variant introduces
//	- removal of the complex init in favor of initWithFrame: and properties that can be
//	  initialized separately using plain init or the key-value fields of IB/Storyboard
//	  - segmentCount
//	  - segmentSize
//	  - selectedSegment
//	  - dividerImageName
//	- separated buttonSource and delegate protocols, and both now IBOutlet, so connection can
//	  be hooked up in IB/Storyboard
//	- some re-factoring, so the appropriate things can be done at each of the folloinwg times:
//	  - awakeFromNib
//	  - layoutSubviews
//	  - setSelectedSegment:

#import "xolawareOpenSourceCopyright.h"

#import <UIKit/UIKit.h>

@class xolawareSegmentedControl;
@protocol xolawareSegmentedControlButtonSource
- (UIButton*)buttonFor:(xolawareSegmentedControl*)segmentedControl
			   atIndex:(NSUInteger)segmentIndex;
@end

@protocol xolawareSegmentedControlDelegate
@optional
- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex;
- (void) touchDownAtSegmentIndex:(NSUInteger)segmentIndex;
@end

@interface xolawareSegmentedControl : UIView

@property (strong, nonatomic) IBOutlet NSObject<xolawareSegmentedControlButtonSource>* buttonSource;
@property (strong, nonatomic) IBOutlet NSObject<xolawareSegmentedControlDelegate>* delegate;

@property (strong, nonatomic)	NSString*	dividerImageName;
@property (strong, nonatomic)	NSNumber*	segmentCount;
@property (nonatomic)			CGSize		segmentSize;
@property (strong, nonatomic)	NSNumber*	selectedSegment;

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex;

@end
