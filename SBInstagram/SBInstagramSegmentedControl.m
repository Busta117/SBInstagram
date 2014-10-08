//
//  SBInstagramSegmentedControl.m
//  SBInstagramExample
//
//  Created by Santiago Bustamante on 10/8/14.
//  Copyright (c) 2014 Busta. All rights reserved.
//

#import "SBInstagramSegmentedControl.h"

@interface SBInstagramSegmentedControl()

@property NSMutableArray *itemsDeselected;
@property NSMutableArray *buttons;
@property NSMutableArray *lines;

@end

@implementation SBInstagramSegmentedControl


- (instancetype)initWithItems:(NSArray *)items{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth(screenRect), [items[0] size].height + 20)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.items = items;
        self.itemsDeselected = [NSMutableArray array];
        self.buttons = [NSMutableArray array];
        self.lines = [NSMutableArray array];
        self.borderColor = [UIColor colorWithWhite:0.8 alpha:1];
        [self.items enumerateObjectsUsingBlock:^(UIImage *obj, NSUInteger idx, BOOL *stop) {
            [self.itemsDeselected addObject:[obj tintedImageWithColor:[UIColor lightGrayColor]]];
        }];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        
    }
    return self;
}


-(void)didMoveToSuperview{
    
    
    [self.items enumerateObjectsUsingBlock:^(UIImage *obj, NSUInteger idx, BOOL *stop) {
        
        UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
        [but setImage:self.itemsDeselected[idx] forState:UIControlStateNormal];
        but.tag = idx;
        [but addTarget:self action:@selector(sectionPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect frame = but.frame;
        frame.size = obj.size;
        frame.size.width += 50;
        frame.origin.x = ((CGRectGetWidth(self.frame)/self.items.count)) - ((CGRectGetWidth(frame))*(self.items.count/2)) + ((CGRectGetWidth(frame))*idx);
        frame.origin.y = 10;
        but.frame = frame;
        
        [self.buttons addObject:but];
        [self addSubview:but];
        but.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        if (idx < self.items.count-1) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(frame), 8, 1, CGRectGetHeight(frame) + 4)];
            line.backgroundColor = self.borderColor;
            [self addSubview:line];
            line.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [self.lines addObject:line];
        }

        
    }];
    
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
    line1.backgroundColor = self.borderColor;
    [self addSubview:line1];
    line1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self.lines addObject:line1];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame), 1)];
    line2.backgroundColor = self.borderColor;
    [self addSubview:line2];
    line2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self.lines addObject:line2];
    
}

- (void) setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    [self.lines enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        obj.backgroundColor = borderColor;
    }];
}

-(void) setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex{
    if (selectedSegmentIndex > self.items.count-1) {
        selectedSegmentIndex = 0;
    }
    
    _selectedSegmentIndex = selectedSegmentIndex;
    
    UIButton *but = self.buttons[selectedSegmentIndex];
    [but setImage:self.items[selectedSegmentIndex] forState:UIControlStateNormal];
    
    
}


-(void) sectionPressed:(UIButton *) sender{
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *but, NSUInteger idx, BOOL *stop) {
        [but setImage:self.itemsDeselected[idx] forState:UIControlStateNormal];
    }];
    
    [sender setImage:self.items[sender.tag] forState:UIControlStateNormal];
    
    self.selectedSegmentIndex = sender.tag;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}


@end


@implementation UIImage (tint)

- (instancetype)tintedImageWithColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = (CGRect){ CGPointZero, self.size };
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [self drawInRect:rect];
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end