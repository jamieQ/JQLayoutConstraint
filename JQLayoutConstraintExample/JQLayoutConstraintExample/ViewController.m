//
//  ViewController.m
//  JQLayoutConstraint
//

#import "ViewController.h"

#import "NSLayoutConstraint+JQShim.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *horizontalConstraints;
@property (nonatomic, strong) NSArray *verticalConstraints;
@property (nonatomic, strong) NSArray *currentLayoutAxisConstraints;

@property (nonatomic, strong) NSArray *originConstraints;

@property (nonatomic, copy) NSArray *testViews;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  UIView *v1 = [UIView new];
  UIView *v2 = [UIView new];

  NSArray *views = @[v1, v2];
  self.testViews = views;
  for (UIView *v in views) {
    v.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:v];
    v.backgroundColor = [UIColor purpleColor];

    NSLayoutConstraint *w =
    [NSLayoutConstraint constraintWithItem:v
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1
                                  constant:50];

    NSLayoutConstraint *h =
    [NSLayoutConstraint constraintWithItem:v
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1
                                  constant:50];

    [NSLayoutConstraint activateConstraints:@[w, h]];
  }

  NSLayoutConstraint *x =
  [NSLayoutConstraint constraintWithItem:v1
                               attribute:NSLayoutAttributeLeft
                               relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                               attribute:NSLayoutAttributeLeft
                              multiplier:1
                                constant:20];

  NSLayoutConstraint *y =
  [NSLayoutConstraint constraintWithItem:v1
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                               attribute:NSLayoutAttributeTop
                              multiplier:1
                                constant:50];
  self.originConstraints = @[x, y];

  [NSLayoutConstraint activateConstraints:self.originConstraints];

  NSDictionary *viewsMap = NSDictionaryOfVariableBindings(v1, v2);

  self.horizontalConstraints =
  [NSLayoutConstraint constraintsWithVisualFormat:@"[v1]-20-[v2]"
                                          options:NSLayoutFormatAlignAllCenterY
                                          metrics:nil
                                            views:viewsMap];

  [NSLayoutConstraint activateConstraints:self.horizontalConstraints];
  self.currentLayoutAxisConstraints = self.horizontalConstraints;

  self.verticalConstraints =
  [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v1]-20-[v2]"
                                          options:NSLayoutFormatAlignAllLeading
                                          metrics:nil
                                            views:viewsMap];

  UIButton *layoutAxisButton = [UIButton buttonWithType:UIButtonTypeCustom];
  layoutAxisButton.backgroundColor = [UIColor redColor];
  [layoutAxisButton setTitle:@"Vertical"
     forState:UIControlStateNormal];
  [layoutAxisButton addTarget:self
        action:@selector(toggleActive:)
forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:layoutAxisButton];
  layoutAxisButton.frame = CGRectMake(200, 50, 100, 44);

  UIButton *addRemoveButton = [UIButton buttonWithType:UIButtonTypeCustom];
  addRemoveButton.backgroundColor = [UIColor redColor];
  [addRemoveButton setTitle:@"Remove"
          forState:UIControlStateNormal];
  [addRemoveButton addTarget:self
             action:@selector(remove:)
   forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:addRemoveButton];
  addRemoveButton.frame = CGRectOffset(layoutAxisButton.frame, 0, 54);
}

- (void)remove:(UIButton *)sender
{
  BOOL shouldRemove = sender.tag == 0;

  for (UIView *v in self.testViews) {
    if (shouldRemove) {// remove
      [v removeFromSuperview];
    } else {
      [self.view addSubview:v];
    }
  }

  if (shouldRemove) {
    [sender setTitle:@"Add"
            forState:UIControlStateNormal];
    sender.tag = 1;
  } else {
    [NSLayoutConstraint activateConstraints:self.originConstraints];
    [NSLayoutConstraint activateConstraints:self.currentLayoutAxisConstraints];

    [sender setTitle:@"Remove"
            forState:UIControlStateNormal];
    sender.tag = 0;
  }
}

- (void)toggleActive:(UIButton *)sender
{
  if (sender.tag == YES) {
    [NSLayoutConstraint deactivateConstraints:self.verticalConstraints];
    [NSLayoutConstraint activateConstraints:self.horizontalConstraints];
    self.currentLayoutAxisConstraints = self.horizontalConstraints;

    [sender setTitle:@"Vertical"
            forState:UIControlStateNormal];

    sender.tag = NO;
  } else {
    [NSLayoutConstraint deactivateConstraints:self.horizontalConstraints];
    [NSLayoutConstraint activateConstraints:self.verticalConstraints];
    self.currentLayoutAxisConstraints = self.verticalConstraints;

    [sender setTitle:@"Horizontal"
            forState:UIControlStateNormal];
    
    sender.tag = YES;
  }
}

@end
