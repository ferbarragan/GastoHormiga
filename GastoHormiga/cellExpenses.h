//
//  cellExpenses.h
//  ControlDeGastos
//
//  Created by Christian Barragan on 22/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol cellDelegate <NSObject>
- (void)didClickOnEditButtonAtIndex:(NSInteger)cellIndex withData:(id)data;
@end

@interface cellExpenses : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UILabel *lblCateg;

- (IBAction)btnEditPressed:(UIButton *)sender;


@property (weak, nonatomic) id<cellDelegate>delegate;
@property (assign, nonatomic) NSInteger cellIndex;

@end
