//
//  ExpenseImageView.h
//  GastoHormiga
//
//  Created by Christian Barragan on 31/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpenseImageView : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imgExpense;

@property (nonatomic, strong) NSString * imagePath;

@end
