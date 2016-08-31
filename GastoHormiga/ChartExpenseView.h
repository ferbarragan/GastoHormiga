//
//  ChartExpenseView.h
//  GastoHormiga
//
//  Created by Christian Barragan on 29/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartExpenseView : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblPayCash;
@property (weak, nonatomic) IBOutlet UILabel *lblPayTC;
@property (weak, nonatomic) IBOutlet UILabel *lblPayTD;
@property (weak, nonatomic) IBOutlet UILabel *lblCatFood;
@property (weak, nonatomic) IBOutlet UILabel *lblCatGas;
@property (weak, nonatomic) IBOutlet UILabel *lblCatTrans;
@property (weak, nonatomic) IBOutlet UILabel *lblCatEntr;
@property (weak, nonatomic) IBOutlet UILabel *lblCatLikes;
@property (weak, nonatomic) IBOutlet UILabel *lblCatOther;


@end
