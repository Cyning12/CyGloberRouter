//
//  LocalGloberRouter.m
//  TestAnyThing
//
//  Created by 刘新宁 on 2017/2/14.
//  Copyright © 2017年 刘新宁. All rights reserved.
//

#import "LocalGloberRouter.h"

#define LocalScheme @"test"

static LocalGloberRouter *globerRouter = nil;

@interface LocalGloberRouter ()

@end

@implementation LocalGloberRouter

- (instancetype)init{
  if (self = [super initWithScheme:LocalScheme]) {
    [self registerRouter];
  }
  return self;
}


- (BOOL)routePathWithoutScheme:(NSString *__nonnull)path {
  NSLog(@"Route path: %@", path);
  return [super routePathWithoutScheme:path];
}

- (void)registerRouter{
    
    [self on:@"/rootID/:id" action:^(NSDictionary<NSString *, NSString *> *params) {
        NSLog(@"%@", params[@"id"]);
    }];
    
    [self on:@"/中文/test" action:^(NSDictionary<NSString *,NSString *> * _Nonnull params) {
          
        NSLog(@"%@", params);
    }];
    
    [self on:@"/root/test" action:^(NSDictionary<NSString *,NSString *> * _Nonnull params) {
        NSLog(@"测试页面");
    }];
    
    [self on:@"/test" action:^(NSDictionary<NSString *, NSString *> *params) {
        NSLog(@"test root, params:%@", params);
    }];
    
    [self alias:@"/root/test" to:@"/root/1"];

}

+ (instancetype)shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    globerRouter = [[LocalGloberRouter alloc] init];
  });
  return globerRouter;
}


@end
