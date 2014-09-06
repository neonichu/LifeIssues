//
//  TextFieldCell.m
//  LifeIssues
//
//  Created by Boris Bügling on 06/09/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "TextFieldCell.h"
#import "UIView+Geometry.h"

@interface TextFieldCell ()

@property (nonatomic) UITextField* textField;

@end

#pragma mark -

@implementation TextFieldCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                       self.width / 2, self.height)];
        self.accessoryView = self.textField;
    }
    return self;
}

@end
