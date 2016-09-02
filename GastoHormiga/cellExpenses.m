//
//  cellExpenses.m
//  ControlDeGastos
//
//  Created by Christian Barragan on 22/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "cellExpenses.h"

@implementation cellExpenses

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnEditPressed:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOnEditButtonAtIndex:withData:)]) {
        [self.delegate didClickOnEditButtonAtIndex:self.cellIndex withData:@"Not used"];
    }
}

- (IBAction)btnImagePressed:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOnImageButtonAtIndex:withData:)]) {
        [self.delegate didClickOnImageButtonAtIndex:self.cellIndex withData:@"Not used"];
    }
}
@end
