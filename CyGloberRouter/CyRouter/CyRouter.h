//
//  CyRouter.h
//  TestAnyThing
//
//  Created by 刘新宁 on 2017/2/13.
//  Copyright © 2017年 刘新宁. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AbstractRouter<NSObject>

- (BOOL)routeUrl:(NSURL *__nonnull)url;

@end

typedef void(^RouterAction)(NSDictionary<NSString *, NSString *> *__nonnull params);

@interface CyRouter : NSObject

/**
 *  主 Router 的 Scheme
 */
@property(nonatomic, copy, readonly) NSString *__nonnull scheme;

/**
 * 初始化路由器
 * @param scheme  主scheme
 * @return CyRouter对象
 */
+ (instancetype __nonnull)routerWithScheme:(NSString * __nonnull)scheme;

/**
 * 初始化路由器
 * @param scheme 主scheme
 * @return CyRouter对象
 */
- (instancetype __nonnull)initWithScheme:(NSString *__nonnull)scheme;

/**
 * 为一个已经存在的路由器注册子路由器
 * @param router 子路由器
 * @param scheme 子scheme
 */
- (void)registerRouter:(id <AbstractRouter>__nonnull)router forScheme:(NSString * __nonnull )scheme;
/**
 * 传入一个完整的URL进行跳转
 * @param fullURLString  包括scheme，可以使用子路由
 * @return 路径正确进行对应action并返回YES
 */
- (BOOL)routeFullUrlString:(NSString *__nonnull)fullURLString;

/**
 * 传入一个路径不包括scheme，使用路由主scheme进行跳转
 * @param path 路径
 * @return 是否成功跳转
 */
- (BOOL)routePathWithoutScheme:(NSString *__nonnull)path;
/**
 * 传入一个路径不包括scheme，使用路由主scheme进行跳转
 * @param path 路径
 * @param params 参数
 * @return 是否成功跳转
 */
- (BOOL)routePath:(NSString *__nonnull)path params:(NSDictionary *__nullable)params;
/**
 * 传入一个路径不包括scheme，使用路由主scheme进行跳转
 * @param path  路径
 * @param buildBlock  参数block
 * @return 是否成功跳转
 */
- (BOOL)routePath:(NSString *__nonnull)path buildParams:(void (^ __nonnull)(NSMutableDictionary<NSString *, NSString *> *__nonnull params))buildBlock;
/**
 * 注册一个路径到主 scheme
 * @param path 路径
 * @param action 相应
 */
- (void)on:(NSString *__nonnull)path action:(RouterAction __nonnull)action;
/**
 * 给一个已存在的路径设置别名 （不存在注册此路径）
 * @param path    设置别名的路径
 * @param srcPath 别名
 */
- (void)alias:(NSString *__nonnull)path to:(NSString *__nonnull)srcPath;
@end
