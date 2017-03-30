//
//  TangramContext.h
//  Tangram
//
//  Created by jiajun on 5/1/16.
//  Copyright © 2016 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TangramView;
@class TangramEvent;
@interface TangramContext : NSObject

@property   (nonatomic, weak)   id              poster;
@property   (nonatomic, weak)   TangramView     *tangram;
@property   (nonatomic, weak)   TangramEvent    *event;

@end
