//
// Created by TBetts on 10/14/13.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DALongPressButtonState)
{
    DALongPressButtonStateCollapsed,
    DALongPressButtonStateExpanded
};

@protocol DALongPressButtonDelegate <UITableViewDataSource, UITableViewDelegate>
- (void)onButtonCliked;
- (void)onExpanded;
- (void)onCollapsed;
@end

@interface DALongPressButtonView : UIButton

@property (nonatomic, assign) BOOL on;

@property (nonatomic, assign) DALongPressButtonState longPressButtonState;

@property (nonatomic, assign) CGRect collapsedFrame;
@property (nonatomic, assign) CGRect expandedFrame;

@property (nonatomic, strong) UIColor *normalTintColor;
@property (nonatomic, strong) UIColor *higlitedTintColor;
@property (nonatomic, strong) UIColor *longPressIndicatorColor;


@property (nonatomic, assign) id<DALongPressButtonDelegate> delegate;


- (void)expandAnimated:(BOOL)animated;
- (void)collapseAnimated:(BOOL)animated;

- (void)initializeControl;

@end