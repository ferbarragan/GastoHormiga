//
//  ChartExpenseView.m
//  GastoHormiga
//
//  Created by Christian Barragan on 29/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "ChartExpenseView.h"
#import "DBManager.h"

@interface ChartExpenseView ()

@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation ChartExpenseView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Database Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - Database Methods ----------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief This initializes the database manager.
 */
- (void)dataBaseInit {
    /* Initialize the dbManager property. */
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:DATABASE_NAME];
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(float)calculateTotalOfCategory: (NSString*) category {
    
    NSArray *arrExpenses;
    int i;
    /* Form the query. */
    NSString *query = [[NSString alloc]initWithFormat:@"select amount from expense where category='%@'",category];
    NSString *strCurrExpense;
    NSString *strCurrExpenseFmt;
    NSNumber *numCurrExpense;
    float totalExpense = 0;
    
    NSNumberFormatter *decimalStyleFormatter = [[NSNumberFormatter alloc] init];
    [decimalStyleFormatter setMaximumFractionDigits:2];
    
    /* Initialize the array. */
    if (arrExpenses != nil) {
        arrExpenses = nil;
    }
    
    totalExpense = 0;
    
    /* Get the results from the database. */
    arrExpenses = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    for (i = 0; i < arrExpenses.count; i++) {
        strCurrExpense = [[arrExpenses objectAtIndex:i] objectAtIndex:0];
        numCurrExpense = @([strCurrExpense floatValue]);
        strCurrExpenseFmt = [decimalStyleFormatter stringFromNumber:numCurrExpense];
        totalExpense += [strCurrExpenseFmt floatValue];
    }
    
    return totalExpense;
}
/* ------------------------------------------------------------------------------------------------------------------ */

@end
