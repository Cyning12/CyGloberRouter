//
//  LocalGloberRouter.h
//  TestAnyThing
//
//  Created by 刘新宁 on 2017/2/14.
//  Copyright © 2017年 刘新宁. All rights reserved.
//

#import "CyRouter.h"

#define LGR ([LocalGloberRouter shared])

@interface LocalGloberRouter : CyRouter

+ (instancetype)shared;

@end
