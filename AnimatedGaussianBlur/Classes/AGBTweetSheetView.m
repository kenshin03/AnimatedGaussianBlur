//
//  AGBTweetSheetView.m
//  AnimatedGaussianBlur
//
//  Created by Kenny Tang on 4/7/13.
//  Copyright (c) 2013 corgitoergosum. All rights reserved.
//

#import "AGBTweetSheetView.h"

@implementation AGBTweetSheetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tweet_sheet_background"]];
        [self addSubview:imageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
