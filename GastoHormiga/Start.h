//
//  Start.h
//  GastoHormiga
//
//  Created by Christian Barragan on 23/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddExpensesView.h"

@interface Start : UIViewController <AddExpensesViewDelegate>

/* UI Outlets */
@property (weak, nonatomic) IBOutlet UIButton *btnViewExpense;

/* Action buttons. */
- (IBAction)btnAddExpensePressed:(id)sender;
- (IBAction)btnViewExpensePressed:(id)sender;

@end
