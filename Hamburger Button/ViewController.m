//
//  ViewController.m
//  Hamburger Button
//
//  Created by Bryce Hammond on 7/9/14.
//  Copyright (c) 2014 Robert Böhnke. All rights reserved.
//

#import "ViewController.h"
#import "HamburgerButton.h"

@interface ViewController ()

@property (nonatomic, strong) HamburgerButton *button;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:38.0 / 255 green:151.0 / 255 blue:68.0 / 255 alpha:1];
    
    self.button = [[HamburgerButton alloc] initWithFrame:CGRectMake(133, 133, 54, 54)];
    [self.button addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.button];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)toggle:(UIButton *)button
{
    self.button.showsMenu = !self.button.showsMenu;
}


@end
