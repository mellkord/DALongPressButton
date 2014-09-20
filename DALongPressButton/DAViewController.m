//
//  DAViewController.m
//  DALongPressButton
//
//  Created by Dmitrii Aitov on 19/09/14.
//  Copyright (c) 2014 Cocoatouch.ru. All rights reserved.
//

#import "DAViewController.h"
#import "DALongPressButtonView.h"

@interface DAViewController ()<DALongPressButtonDelegate>
{
    DALongPressButtonView *_longPressButton;
    UITableView *_tableView;
}

@property (nonatomic, assign) IBOutlet UIView *containerView;

@end

@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_longPressButton = [[DALongPressButtonView alloc] init];
    _longPressButton.delegate = self;
    _longPressButton.backgroundColor = [UIColor colorWithRed:214.0f/255.0f green:214.0f/255.0f blue:214.0f/255.0f alpha:1.0];
    _longPressButton.normalTintColor = [UIColor whiteColor];
    _longPressButton.higlitedTintColor = [UIColor colorWithRed:103.0f/255.0f green:103.0f/255.0f blue:103.0f/255.0f alpha:1.0];
//    _longPressButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [_longPressButton setImage:[[UIImage imageNamed:@"undo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    _longPressButton.imageEdgeInsets = UIEdgeInsetsMake(7, 10, 7, 10);
    _longPressButton.collapsedFrame = CGRectMake(10, 80, 40, 40);
    _longPressButton.expandedFrame = CGRectMake(10, 80, 40, 200);
    _longPressButton.longPressButtonState = DALongPressButtonStateExpanded;
    [_longPressButton addTarget:self action:@selector(handleTapOnButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_longPressButton initializeControl];
    [self.view addSubview:_longPressButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onButtonCliked {
    
}

- (void)onExpanded {
    
}

- (void)onCollapsed {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    _tableView = tableView;
    _tableView.separatorColor = [UIColor colorWithRed:103.0f/255.0f green:103.0f/255.0f blue:103.0f/255.0f alpha:1.0];
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon1.png"]];
    iconView.frame = CGRectMake(10, 8, 20, 20);
    iconView.contentMode = UIViewContentModeScaleToFill;
    [cell addSubview:iconView];
    
    cell.separatorInset = UIEdgeInsetsZero;
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = bgColorView;
    
    cell.backgroundColor = [UIColor colorWithRed:rand() % 210 / 255.0f green:rand() % 210 / 255.0f blue:rand() % 210 / 255.0f alpha:1.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.containerView.backgroundColor = [UIColor colorWithRed:rand() % 210 / 255.0f green:rand() % 210 / 255.0f blue:rand() % 210 / 255.0f alpha:1.0f];
    //[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath *firstVisibleIndexPath = [_tableView indexPathsForVisibleRows][0];
    if (![[_tableView indexPathForSelectedRow] isEqual:firstVisibleIndexPath])
    {
        [_tableView selectRowAtIndexPath:firstVisibleIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        if ([_tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        {
            [_tableView.delegate tableView:_tableView didSelectRowAtIndexPath:firstVisibleIndexPath];
        }
    }
}

- (IBAction)handleTapOnButton:(id)sender
{
    self.containerView.backgroundColor = [UIColor colorWithRed:rand() % 210 / 255.0f green:rand() % 210 / 255.0f blue:rand() % 210 / 255.0f alpha:1.0f];
}

- (IBAction)handleTap:(id)sender
{
    [_longPressButton collapseAnimated:YES];
}

@end
