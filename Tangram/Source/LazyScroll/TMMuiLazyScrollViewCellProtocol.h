//
//  TMMuiLazyScrollViewCellProtocol.h
//  LazyScrollView
//
//  Copyright (c) 2017 tmall. All rights reserved.
//


/**
 If the view in LazyScrollView implement this protocol,
 view can do something in its lifecycle.
 */
@protocol  TMMuiLazyScrollViewCellProtocol<NSObject>

@optional
// Will be called if call dequeueReusableItemWithIdentifier
// to get a reuseable view, the same as "prepareForReuse"
// in UITableViewCell.
- (void)mui_prepareForReuse;
// When view enter the visible area of LazyScrollView,
// call this method.
// First 'times' is 0.
- (void)mui_didEnterWithTimes:(NSUInteger)times;
// When we need render the view, call this method.
// The difference between this method and
// 'mui_didEnterWithTimes' is there is a buffer area
// in LazyScrollView(RenderBufferWindow).
- (void)mui_afterGetView;
// When the view is out of screen, this method will be
// called.
- (void)mui_didLeave;

@end
