//
//  NSLayoutConstraint+JQShim.m
//  JQLayoutConstraint
//

#import "NSLayoutConstraint+JQShim.h"

#import <objc/runtime.h>

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_iOS_8_0 1140.11
#endif

#pragma mark - NSLayoutItem Protocol Hooks

@protocol JQLayoutItem

- (id<JQLayoutItem>)nsli_superitem;

- (id)nsli_layoutEngine;

@end

#pragma mark - NSLayoutConstraint Private Hooks

@interface NSLayoutConstraint (JQShimPrivateHooks)

@property (nonatomic, unsafe_unretained, readonly) id container;// UIView

@end

#pragma mark - NSISEngine Private Hooks

@interface NSObject (JQShimAutoLayoutInternals);

- (void)withAutomaticOptimizationDisabled:(void(^)())performBlock;// NSISEngine

@end

#pragma mark - NSLayoutConstraint Internal Methods

@interface NSLayoutConstraint (JQShimInternals)

- (id)jq_layoutEngine;

@end

@implementation NSLayoutConstraint (JQShimInternals)

- (id)jq_layoutEngine
{
  id engine = [self.firstItem nsli_layoutEngine];
  return engine ?: [self.secondItem nsli_layoutEngine];
}

@end

#pragma mark - NSLayoutConstraint Shim

@implementation NSLayoutConstraint (JQShim)

static BOOL _JQAddMethodForClass(NSString *targetMethodName,
                                 Class class,
                                 BOOL isClassMethod)
{
  Class c = isClassMethod ? objc_getMetaClass(NSStringFromClass(class).UTF8String) : class;
  SEL targetSelector = NSSelectorFromString(targetMethodName);
  SEL shimSelector = NSSelectorFromString([@"jq_" stringByAppendingString:targetMethodName]);
  Method m = class_getClassMethod(c, shimSelector);
  IMP imp = class_getMethodImplementation(c, shimSelector);

  return class_addMethod(c,
                         targetSelector,
                         imp,
                         method_getTypeEncoding(m));
}

+ (void)load
{
  if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
    return;
  }

  NSArray *classMethods = @[@"activateConstraints:", @"deactivateConstraints:"];
  NSArray *instanceMethods = @[@"isActive", @"setActive:"];

  for (NSString *s in classMethods) {
    _JQAddMethodForClass(s, self, YES);
  }

  for (NSString *s in instanceMethods) {
    _JQAddMethodForClass(s, self, NO);
  }
}

#pragma mark - Public

- (BOOL)jq_isActive
{
  return self.container ? YES : NO;
}

- (void)jq_setActive:(BOOL)active
{
  if (active && (self.isActive == active)) { return; }

  if (!active) {
    [self.container removeConstraint:self];
    return;
  }

  id ancestor = [NSLayoutConstraint jq_findCommonAncestorOfItem:self.firstItem
                                                        andItem:self.secondItem];

  if (!ancestor) {
    [NSException raise:NSGenericException
                format:@"Unable to activate constraint with items %@ and %@ because they have no common ancestor.  Does the constraint reference items in different view hierarchies?  That's illegal.",
     self.firstItem,
     self.secondItem];
  }

  [ancestor addConstraint:self];
}

+ (void)jq_activateConstraints:(NSArray *)constraints
{
  [self jq_addOrRemoveConstraints:constraints
                         activate:YES];
}

+ (void)jq_deactivateConstraints:(NSArray *)constraints
{
  [self jq_addOrRemoveConstraints:constraints
                         activate:NO];
}

#pragma mark - Internal

+ (id)jq_findCommonAncestorOfItem:(id<JQLayoutItem>)firstItem
                          andItem:(id<JQLayoutItem>)secondItem
{
  if (firstItem && !secondItem) {
    return firstItem;
  } else if (!firstItem && secondItem) {
    return secondItem;
  } else if (firstItem == secondItem) {
    return firstItem;
  }

  id<JQLayoutItem> firstAncestor = firstItem;
  id<JQLayoutItem> secondAncestor = secondItem;

  while (firstAncestor) {
    while (secondAncestor) {
      if (firstAncestor == secondAncestor) {
        break;
      }

      secondAncestor = [secondAncestor nsli_superitem];
    }

    if (firstAncestor == secondAncestor) {
      break;
    } else {
      secondAncestor = secondItem;
    }

    firstAncestor = [firstAncestor nsli_superitem];
  }

  return firstAncestor;
}

+ (void)jq_addOrRemoveConstraints:(NSArray *)constraints
                         activate:(BOOL)activate
{
  if (constraints.count == 0) { return; }

  for (NSLayoutConstraint *c in constraints) {
    id engine = [c jq_layoutEngine];
    if (engine) {
      [engine withAutomaticOptimizationDisabled:^{
        c.active = activate;
      }];
    } else {
      c.active = activate;
    }
  }
}

@end
