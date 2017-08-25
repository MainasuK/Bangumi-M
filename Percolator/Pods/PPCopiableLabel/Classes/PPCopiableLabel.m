//
//  PPCopiableLabel.m
//
//  Created by Vikram Kriplaney on 27/05/14.
//  Copyright (c) 2014 iPhonso GmbH. All rights reserved.
//

#import "PPCopiableLabel.h"
@implementation PPCopiableLabel
- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;

    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)]];
    self.userInteractionEnabled = YES;
    if (!self.highlightedTextColor) {
        self.highlightedTextColor = self.tintColor; // Use tint color to highlight by default
    }
}

- (void)didLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) return;

    [self becomeFirstResponder];
    self.highlighted = YES;
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.bounds inView:self];
    [menu setMenuVisible:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideMenu) name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)didHideMenu
{
    self.highlighted = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}


#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:)) return YES;
    return [super canPerformAction:action withSender:sender];
}

- (void)copy:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.text];
}

@end
