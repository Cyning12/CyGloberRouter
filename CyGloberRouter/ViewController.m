//
//  ViewController.m
//  CyGloberRouter
//
//  Created by 刘新宁 on 2017/2/16.
//  Copyright © 2017年 刘新宁. All rights reserved.
//

#import "ViewController.h"
#import "LocalGloberRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  去测试页面
     */
    [LGR routePathWithoutScheme:@"/test"];
    /**
     *  二级地址可替换
     */
    [LGR routePathWithoutScheme:@"/rootID/去第一个页面"];
    [LGR routePathWithoutScheme:@"/rootID/2"];
    
    /**
     *  两个路径等价
     */
    [LGR routePathWithoutScheme:@"/root/1"];
    [LGR routePathWithoutScheme:@"/root/test"];
    /**
     *  path支持中文
     */
    [LGR routePathWithoutScheme:@"/中文/test"];
    /**
     *  包含scheme的url
     */
    [LGR routeFullUrlString:@"test://root/特"];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
