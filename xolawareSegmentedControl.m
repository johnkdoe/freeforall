//
//  xolawareSegmentedControl.m
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

#import "xolawareSegmentedControl.h"

@interface xolawareSegmentedControl ()
@property (strong, nonatomic)	NSMutableArray* buttons;
@property (strong, nonatomic)	NSMutableArray* dividers;
@end

@implementation xolawareSegmentedControl

- (void)setSelectedSegment:(NSNumber*)selectedSegment {
	NSUInteger newSelectedSegment = selectedSegment.unsignedIntegerValue;
	assert(newSelectedSegment < _segmentCount.unsignedIntegerValue);
	if (!_selectedSegment || ![selectedSegment isEqualToNumber:_selectedSegment])
	{
		if (newSelectedSegment < _buttons.count)
		{
			[_buttons[newSelectedSegment] setSelected:YES];
			[self dimAllButtonsExcept:_buttons[newSelectedSegment]];
		}

		_selectedSegment = selectedSegment;
	}
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex {
	self.selectedSegment = [NSNumber numberWithUnsignedInteger:selectedSegmentIndex];
}

#pragma mark - UIView init method implementation override

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		// Initalize the array we use to store our buttons
		NSUInteger segmentCount = [_segmentCount unsignedIntegerValue];
		assert(segmentCount);
		self.buttons = [[NSMutableArray alloc] initWithCapacity:segmentCount];
		self.dividers = [[NSMutableArray alloc] initWithCapacity:segmentCount-1];
	}

	return self;
}

#pragma mark - private method implementation

- (void)dimAllButtonsExcept:(UIButton*)selectedButton
{
	for (UIButton* button in _buttons)
	{
		if (button == selectedButton)
		{
			button.highlighted = button.isSelected ? NO : YES;
			button.selected = YES;
		}
		else
		{
			button.highlighted = NO;
			button.selected = NO;
		}
	}
}

- (void)otherTouchesAction:(UIButton*)button
{
	[self dimAllButtonsExcept:button];
}

- (void)setButtons {
	// collect and initialize buttons
	if (_delegate)
	{
		NSUInteger segmentCount = _segmentCount.unsignedIntegerValue;
		assert(segmentCount);
		_buttons = [NSMutableArray arrayWithCapacity:_segmentCount.unsignedIntegerValue];
		for (NSUInteger i = 0 ; i < _segmentCount.unsignedIntegerValue ; ++i)
		{
			// Ask the delegate to create a button
			UIButton* button = [_buttonSource buttonFor:self atIndex:i];
			// Register for touch events
			[button addTarget:self action:@selector(touchDownAction:)
			 forControlEvents:UIControlEventTouchDown];
			[button addTarget:self action:@selector(touchUpInsideAction:)
			 forControlEvents:UIControlEventTouchUpInside];
			[button addTarget:self action:@selector(otherTouchesAction:)
			 forControlEvents:UIControlEventTouchUpOutside];
			[button addTarget:self action:@selector(otherTouchesAction:)
			 forControlEvents:UIControlEventTouchDragOutside];
			[button addTarget:self action:@selector(otherTouchesAction:)
			 forControlEvents:UIControlEventTouchDragInside];
			// Add the button to our buttons array
			[_buttons addObject:button];

			// Add the button as our subview
			[self addSubview:button];
			if (_selectedSegment.unsignedIntegerValue == i)
				button.selected = YES;
		}
	}
}

- (void)setDividers {
	if (_dividerImageName)
	{
		UIImage* dividerImage = [UIImage imageNamed:_dividerImageName];
		for (NSUInteger i = 0 ; i < _segmentCount.unsignedIntegerValue - 1 ; ++i )
		{
			UIImageView* dividerImageView = [[UIImageView alloc] initWithImage:dividerImage];
			[_dividers addObject:dividerImageView];
			[self addSubview:dividerImageView];
		}
	}
}

- (void)touchDownAction:(UIButton*)button
{
	[self dimAllButtonsExcept:button];

	if ([_delegate respondsToSelector:@selector(touchDownAtSegmentIndex:)])
		[_delegate touchDownAtSegmentIndex:[_buttons indexOfObject:button]];
}

- (void)touchUpInsideAction:(UIButton*)button
{
	[self dimAllButtonsExcept:button];

	if ([_delegate respondsToSelector:@selector(touchUpInsideSegmentIndex:)])
		[_delegate touchUpInsideSegmentIndex:[_buttons indexOfObject:button]];
}

#pragma mark - UIView life cycle implementation overrides

- (void)layoutSubviews {
	[super layoutSubviews];

	if (!_buttons)
	{
		[self setButtons];
		[self setDividers];
		if (!_segmentSize.width)
			_segmentSize = [_buttons[0] size];
	}

	CGSize frameSize = self.frame.size;
	CGPoint frameCenter = CGPointMake(frameSize.width / 2.0, frameSize.height / 2.0);
	NSUInteger segmentCount = [_segmentCount unsignedIntegerValue];
	NSUInteger dividerCount = segmentCount - 1;
	UIImage* dividerImage;
	if (_dividerImageName)
		dividerImage = [UIImage imageNamed:_dividerImageName];
	CGFloat segmentWidth = _segmentSize.width, dividerWidth = dividerImage.size.width;
	if (!segmentWidth)
		segmentWidth = (frameSize.width + dividerCount*dividerWidth) / segmentCount;
	CGPoint currentCenter = CGPointMake(frameCenter.x - (dividerCount/2.0)*segmentWidth
										- (dividerCount/2.0)*dividerWidth,
										frameCenter.y);
	for (UIButton* button in _buttons)
	{
		button.center = currentCenter;
		currentCenter.x += segmentWidth + dividerWidth;
	}

	if (dividerWidth)
	{
		currentCenter = [_buttons[0] center];
		currentCenter.x += segmentWidth/2.0 + dividerWidth/2.0;
		for (UIImageView* divider in _dividers)
		{
			divider.center = currentCenter;
			currentCenter.x += segmentWidth;
		}
	}

	[self dimAllButtonsExcept:_buttons[_selectedSegment.unsignedIntegerValue]];
}

@end
