//
//  ViewController.h
//  GastoHormiga
//
//  Created by Christian Barragan on 23/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddExpensesView.h"
#import "cellExpenses.h"
#import "ExpenseImageView.h"

@protocol ExpensesViewDelegate

-(void) editExpenseWasFinished;

@end

@interface ExpensesView : UIViewController <UITableViewDelegate, UITableViewDataSource, AddExpensesViewDelegate, cellDelegate>

/* Delegates */
@property (nonatomic, weak) id<ExpensesViewDelegate> delegate;

/* UI Outlets */
@property (weak, nonatomic) IBOutlet UITableView *tblExpenses;

@end

