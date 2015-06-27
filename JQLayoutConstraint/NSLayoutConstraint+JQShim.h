//
//  NSLayoutConstraint+JQShim.h
//  JQLayoutConstraint
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (JQUIKitFacade)

@property (nonatomic, getter=isActive) BOOL active;

+ (void)activateConstraints:(NSArray *)constraints;
+ (void)deactivateConstraints:(NSArray *)constraints;

@end

@interface NSLayoutConstraint (JQShim)

- (void)jq_setActive:(BOOL)active;
- (BOOL)jq_isActive;

+ (void)jq_activateConstraints:(NSArray *)constraints;
+ (void)jq_deactivateConstraints:(NSArray *)constraints;

@end
