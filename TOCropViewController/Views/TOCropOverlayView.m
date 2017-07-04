//
//  TOCropOverlayView.m
//
//  Copyright 2015-2017 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropOverlayView.h"

static const CGFloat kLineWidth = 2.0f;
static const CGFloat kHalfLineWidth = kLineWidth / 2.0f;
static const CGFloat kCircleSize = 14.0f;

@interface TOCropOverlayView ()

@property (nonatomic, strong) NSArray *horizontalGridLines;
@property (nonatomic, strong) NSArray *verticalGridLines;

@property (nonatomic, strong) NSArray *outerLineViews;   //top, right, bottom, left
@property (nonatomic, strong) NSArray<UIView *> *outerDots;   //top, right, bottom, left

- (void)setup;
- (void)layoutLines;

@end

@implementation TOCropOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        self.gridColor = [UIColor redColor];
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    UIView *(^newLineView)(void) = ^UIView *(void){
        return [self createNewLineView];
    };
    _outerLineViews = @[newLineView(), newLineView(), newLineView(), newLineView()];
    _outerDots = @[[self createDotView], [self createDotView], [self createDotView], [self createDotView]];
    self.displayHorizontalGridLines = YES;
    self.displayVerticalGridLines = YES;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_outerLineViews)
        [self layoutLines];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (_outerLineViews)
        [self layoutLines];
}

- (void)layoutLines
{
    CGSize boundsSize = self.bounds.size;

    //border lines
    for (NSInteger i = 0; i < 4; i++) {
        UIView *lineView = self.outerLineViews[i];
        CGRect frame = CGRectZero;
        switch (i) {
            case 0: frame = (CGRect){-kHalfLineWidth, -kHalfLineWidth, boundsSize.width + kHalfLineWidth, kLineWidth}; break; //top
            case 1: frame = (CGRect){boundsSize.width - kHalfLineWidth, 0, kLineWidth, boundsSize.height}; break; //right
            case 2: frame = (CGRect){-kHalfLineWidth, boundsSize.height - kHalfLineWidth, boundsSize.width + kHalfLineWidth, kLineWidth}; break; //bottom
            case 3: frame = (CGRect){-kHalfLineWidth, 0, kLineWidth, boundsSize.height}; break; //left
        }
        lineView.frame = frame;
    }

    CGFloat circleRadius = kCircleSize / 2.0;
    // draw circle
    for (NSInteger i = 0; i < 4; i++) {
        UIView *dotView = self.outerDots[i];
        CGRect frame = CGRectZero;
        switch (i) {
            case 0: frame = (CGRect){-circleRadius, -circleRadius, kCircleSize, kCircleSize}; break; //top
            case 1: frame = (CGRect){boundsSize.width - circleRadius, -circleRadius, kCircleSize, kCircleSize}; break; //right
            case 2: frame = (CGRect){boundsSize.width - circleRadius, boundsSize.height - circleRadius, kCircleSize, kCircleSize}; break; //bottom
            case 3: frame = (CGRect){-circleRadius, boundsSize.height - circleRadius, kCircleSize, kCircleSize}; break; //left
        }
        dotView.frame = frame;
    }
    //grid lines - horizontal
    CGFloat thickness = 1.0f / [[UIScreen mainScreen] scale];
    NSInteger numberOfLines = self.horizontalGridLines.count;
    CGFloat padding = (CGRectGetHeight(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.height = thickness;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.origin.y = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
    
    //grid lines - vertical
    numberOfLines = self.verticalGridLines.count;
    padding = (CGRectGetWidth(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.width = thickness;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
}

- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated
{
    _gridHidden = hidden;
    
    if (animated == NO) {
        for (UIView *lineView in self.horizontalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        
        for (UIView *lineView in self.verticalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
    
        return;
    }
    
    [UIView animateWithDuration:hidden?0.35f:0.2f animations:^{
        for (UIView *lineView in self.horizontalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
        
        for (UIView *lineView in self.verticalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
    }];
}

#pragma mark - Property methods

- (void)setDisplayHorizontalGridLines:(BOOL)displayHorizontalGridLines
{
    _displayHorizontalGridLines = displayHorizontalGridLines;
    
    [self.horizontalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayHorizontalGridLines) {
        self.horizontalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.horizontalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setDisplayVerticalGridLines:(BOOL)displayVerticalGridLines
{
    _displayVerticalGridLines = displayVerticalGridLines;
    
    [self.verticalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayVerticalGridLines) {
        self.verticalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.verticalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setGridHidden:(BOOL)gridHidden
{
    [self setGridHidden:gridHidden animated:NO];
}

#pragma mark - Private methods

- (nonnull UIView *)createNewLineView
{
    UIView *newLine = [[UIView alloc] initWithFrame:CGRectZero];
    newLine.backgroundColor = self.gridColor;
    [self addSubview:newLine];
    return newLine;
}

- (nonnull UIView *)createDotView
{
    UIView *dot = [[UIView alloc] initWithFrame:CGRectZero];
    dot.layer.masksToBounds = YES;
    dot.layer.cornerRadius = kCircleSize / 2.0f;
    dot.backgroundColor = self.gridColor;
    [self addSubview:dot];
    return dot;
}

@end
