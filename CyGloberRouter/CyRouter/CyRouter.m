//
//  CyRouter.m
//  TestAnyThing
//
//  Created by 刘新宁 on 2017/2/13.
//  Copyright © 2017年 刘新宁. All rights reserved.
//

#import "CyRouter.h"
#import "CMDQueryStringSerialization.h"

/**
 *  RouteEntryComponent
 */

@interface RouteEntryComponent: NSObject
/**
 *  是否是通配浮 : 为前缀的
 */
@property(nonatomic, assign) BOOL isWildcard;
/**
 * 路径值
 */
@property(nonatomic, copy) NSString *value;

@end

@implementation RouteEntryComponent
@end

/**
 *  RouteEntry 路由入口
 *
 */

@interface RouteEntry: NSObject
/**
 * 路由成员
 */
@property(nonatomic, strong) NSMutableArray<RouteEntryComponent *> *components;
/**
 * 路由事件
 */
@property(nonatomic, copy) RouterAction action;

@end

@implementation RouteEntry

static NSCharacterSet *RouteEntryComponentWildcardMarkSet = nil;

+ (void)initialize {
  [super initialize];
  if (self == [RouteEntry class]) {
    RouteEntryComponentWildcardMarkSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
  }
}
/**
 * 初始化
 * @param pattern 无scheme的路径
 *                e.g.:  /root/:id   :id为通配符R
 */
- (id)initWithPattern:(NSString *__nonnull)pattern {
  if (self = [super init]) {
    _components = [[NSMutableArray alloc] init];
    
    [[pattern pathComponents] enumerateObjectsUsingBlock:^(NSString *_Nonnull obj,
                                                           NSUInteger idx,
                                                           BOOL *_Nonnull stop) {
      //  Bypass "//"
      if (obj.length) {
        RouteEntryComponent *comp = [[RouteEntryComponent alloc] init];
        if ([obj hasPrefix:@":"]) {
          comp.isWildcard = YES;
          comp.value = [obj stringByTrimmingCharactersInSet:RouteEntryComponentWildcardMarkSet];
        } else {
          comp.isWildcard = NO;
          comp.value = obj;
        }
        [_components addObject:comp];
      }
    }];
    
    NSParameterAssert(_components.count != 0);
  }
  return self;
}
/**
 * 匹配路径并更换路径中的通配符
 * @param components 被检查的路径
 */
- (NSDictionary<NSString *, NSString *> *__nullable)match:(NSArray<NSString *> *__nonnull)components {
  if (_components.count != components.count) {
    
    return nil;
  }
  
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
  
  __block BOOL failed = NO;

  [_components enumerateObjectsUsingBlock:^(RouteEntryComponent *obj, NSUInteger idx, BOOL *stop) {
      NSString *src = components[idx];
      if (obj.isWildcard){
        dict[obj.value] = src;
      } else{
        if (![obj.value isEqualToString:src]) {
          *stop  =
          failed = YES;
        }
      }
  }];

  if (failed) {
    return nil;
  } else {
    return dict;
  }
}

@end

/**
 *  Router
 */

@interface CyRouter ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *alias;

@property(nonatomic, strong) NSMutableArray<RouteEntry *> *routes;

@property(nonatomic, strong) NSMutableDictionary<NSString *, id<AbstractRouter>> *subRouters;

@end

@implementation CyRouter


- (id)init {
  NSAssert(NO, @"call initWithScheme instead");
  return nil;
}

+ (instancetype)routerWithScheme:(NSString *__nonnull)scheme {
  return [[[self class] alloc] initWithScheme:scheme];
}

- (instancetype)initWithScheme:(NSString *)scheme {
  if (self = [super init]) {
    _scheme = scheme;
    _routes = [[NSMutableArray alloc] init];
    _alias  =  [[NSMutableDictionary alloc] init];
    _subRouters = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)on:(NSString *__nonnull)path action:(RouterAction __nonnull)action {
  RouteEntry * entry = [[RouteEntry alloc] initWithPattern:path];
  entry.action = action;
  [_routes addObject:entry];
}

- (void)alias:(NSString *__nonnull)path to:(NSString *__nonnull)srcPath {
  _alias[srcPath] = path;
}

- (void)registerRouter:(id<AbstractRouter>)router forScheme:(NSString *)scheme {
  _subRouters[scheme] = router;
}

- (BOOL)routePathWithoutScheme:(NSString *)path {
  NSURLComponents * urlComponents = [[NSURLComponents alloc] initWithString:[path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
  urlComponents.scheme = _scheme;
  return [self routeUrl:urlComponents.URL];
}

- (BOOL)routePath:(NSString *__nonnull)path params:(NSDictionary *__nullable)params {
  NSURLComponents * urlComponents = [[NSURLComponents alloc] initWithString:[path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
  urlComponents.query = [CMDQueryStringSerialization queryStringWithDictionary:params];
  return [self routePathWithoutScheme:urlComponents.URL.absoluteString];
}

- (BOOL)routePath:(NSString *__nonnull)path buildParams:(void (^ __nonnull)(NSMutableDictionary<NSString *, NSString *> *__nonnull params))buildBlock {
  NSMutableDictionary <NSString *, NSString *>* params = [[NSMutableDictionary alloc] init];
  buildBlock(params);
  return [self routePath:path params:params];
}


- (BOOL)routeFullUrlString:(NSString *__nonnull)fullURLString {
  if (fullURLString.length == 0) return  NO;
  NSURL * url = [[NSURL alloc] initWithString:[fullURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

  return [self routeUrl:url];
}

- (BOOL)routeUrl:(NSURL *__nonnull)url {
  if (url.scheme == nil) return NO;

  if ([url.scheme isEqualToString:_scheme]){
    return [self routeURL:[self fixURL:url]];
  }

  id<AbstractRouter> subRouter = _subRouters[url.scheme];
  if (subRouter == nil) {
    NSLog(@"Cannot find scheme: %@ in routers", url.scheme);
    return NO;
  }
  return [subRouter routeUrl:url];
}

- (NSURL * __nonnull)fixURL:(NSURL * __nonnull)url{
  /**
   * 路径标准: host:///value1/value2
   */
  NSURL * fixedURL = url;
  NSString * falsePre = [NSString stringWithFormat:@"%@://", _scheme];
  NSString * rightPre = [NSString stringWithFormat:@"%@:///",_scheme];
  if ([fixedURL.absoluteString hasPrefix:falsePre]){
    fixedURL = [NSURL URLWithString:[fixedURL.absoluteString stringByReplacingOccurrencesOfString:falsePre
                                                                                       withString:rightPre]];
  }
  return fixedURL;
}
/**
 * 对符合标准的路径进行对应的操作
 * @param url 符合标注的路径
 */
- (BOOL)routeURL:(NSURL *)url{
  NSString *path = url.path;
  NSString *alisaPath = _alias[path];
  path = alisaPath?:path;

  NSArray <NSString *> * components = [path pathComponents];
  if (components.count == 0) return NO;

  for (RouteEntry * entry in _routes){
      NSDictionary * matchEntry = [entry match:components];
      if (matchEntry){
        NSDictionary * queryParams = [CMDQueryStringSerialization dictionaryWithQueryString:url.query];
        if (queryParams.count == 0){
          entry.action(matchEntry);
        } else{
          NSMutableDictionary * finalQueryParams = [NSMutableDictionary dictionaryWithDictionary:queryParams];
          [finalQueryParams addEntriesFromDictionary:matchEntry];
          entry.action(finalQueryParams);
        }
        return YES;
      }
  }
  return NO;
}

@end
