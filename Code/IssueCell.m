//
//  IssueCell.m
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <MJPCheckMark/MJPCheckMark.h>

#import "IssueCell.h"
#import "UIView+Geometry.h"

@interface IssueCell ()

@property (nonatomic) MJPCheckMark* checkMark;

@end

#pragma mark -

@implementation IssueCell

-(BOOL)checked {
    return self.checkMark.isOn;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.checkMark = [[MJPCheckMark alloc] initWithFrame:CGRectMake(5.0, 7.0, 30.0, 30.0)];
        [self.contentView addSubview:self.checkMark];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];

    self.detailTextLabel.x = CGRectGetMaxX(self.checkMark.frame) + 10.0;
    self.detailTextLabel.width = self.width - self.detailTextLabel.x;
    self.textLabel.x = self.detailTextLabel.x;
    self.textLabel.width = self.detailTextLabel.width;
}

-(void)setChecked:(BOOL)checked {
    [self.checkMark setCheckMarkOn:checked animated:YES];
}

@end
