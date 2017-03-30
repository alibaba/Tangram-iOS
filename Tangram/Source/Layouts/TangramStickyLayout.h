//
//  TangramStickyLayout.h
//  TmallClient4iOS-Tangram
//
//  Created by xiaoxia on 15/11/23.
//  Copyright © 2015年 tmall.com. All rights reserved.
//

#import "TangramItemModelProtocol.h"
#import "TangramLayoutProtocol.h"

@interface TangramStickyLayout : UIView<TangramLayoutProtocol>
// If its true, this layout will stickybottom
@property (nonatomic, assign) BOOL        stickyBottom;
// Record origin y position .
@property (nonatomic, assign) CGFloat     originalY;
// Whether enter sticky status .
@property (nonatomic, assign) BOOL        enterFloatStatus;
// Margin , the sequence of top, right, bottom, left, the class type in array can be NSNumber or NSString
@property (nonatomic, strong) NSArray     *margin;
// Models Array , as protocol request.
@property (nonatomic, strong) NSArray     *itemModels;
// Extra offset in vertial position.
@property (nonatomic, assign) CGFloat     extraOffset;

@property (nonatomic, weak)   TangramBus  *tangramBus;



@end
