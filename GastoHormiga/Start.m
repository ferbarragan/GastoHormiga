//
//  Start.m
//  GastoHormiga
//
//  Created by Christian Barragan on 23/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//
//  Disclaimer: The icons for this application where taken
//              from https://icons8.com/

#import "Start.h"
#import "BackgroundLayer.h"
#import "DBManager.h"

@interface Start ()

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) AddExpensesView *addExpensesView;
@property (nonatomic, strong) ExpensesView *expensesView;

@property float totalExpense;

@end

@implementation Start

#pragma mark - ViewController Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - ViewController Methods ----------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    /* Change the background. */
    [self setBackground];
    /* Initialize the database manager. */
    [self dataBaseInit];
    /* Calculate the total expenses value and show it in the assigned button. */
    [self calculateTotal];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)viewWillAppear:(BOOL)animated {
    /* Hide the NavigationController Toolbar in this View. */
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)viewDidDisappear:(BOOL)animated {

}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    /* Dispose of any resources that can be recreated. */
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief This settles a backgound layer with a gradient color.
 */
- (void)setBackground {
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"idSegueAddExpense"]){
        /*  Make this View a delegate of AddExpensesView */
        self.addExpensesView = [segue destinationViewController];
        self.addExpensesView.delegate = self;
        /* Set the AddExpensesView public property recordIdToEdit  */
        self.addExpensesView.recordIdToEdit = ADD_NEW_EXPENSE;
    } else if ([segue.identifier isEqualToString:@"idSegueViewExpense"]) {
        /* Make this View a delegate of ExpensesView */
        self.expensesView = [segue destinationViewController];
        self.expensesView.delegate = self;
        //self.expensesView.Data = 55;
    }
    
    /* Un-hide the NavigationController Toolbar when leaving this View. */
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewDidDisappear:YES];
}
/* ------------------------------------------------------------------------------------------------------------------ */

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

-(void)calculateTotal {
    
    NSArray *arrExpenses;
    int i;
    /* Form the query. */
    NSString *query = @"select amount from expense";
    NSString *strCurrExpense;
    NSString *strCurrExpenseFmt;
    NSNumber *numCurrExpense;
    
    NSNumberFormatter *decimalStyleFormatter = [[NSNumberFormatter alloc] init];
    [decimalStyleFormatter setMaximumFractionDigits:2];
    
    /* Initialize the array. */
    if (arrExpenses != nil) {
        arrExpenses = nil;
    }
    
    self.totalExpense = 0;
    
    /* Get the results from the database. */
    arrExpenses = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    for (i = 0; i < arrExpenses.count; i++) {
        strCurrExpense = [[arrExpenses objectAtIndex:i] objectAtIndex:0];
        numCurrExpense = @([strCurrExpense floatValue]);
        strCurrExpenseFmt = [decimalStyleFormatter stringFromNumber:numCurrExpense];
        self.totalExpense += [strCurrExpenseFmt floatValue];
    }
    
     [self.btnViewExpense setTitle:[NSString stringWithFormat:@"$%.1f", self.totalExpense] forState:UIControlStateNormal];
    
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - Action Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - Action Methods ------------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Action when the button btnAddExpense is pressed. This will change the view controller.
 */
- (IBAction)btnAddExpensePressed:(id)sender {
#if 0
    UIButton *addBtn = (UIButton *)sender;

    if ([[addBtn imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"add"]]) {
        [addBtn setImage:[UIImage imageNamed:@"addPressed"] forState:UIControlStateNormal];
    }
    else
    {
        [addBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    }
#endif
    [self performSegueWithIdentifier:@"idSegueAddExpense" sender:self];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Action when the button btnViewExpense is pressed. This will change the view controller.
 */
- (IBAction)btnViewExpensePressed:(id)sender {
    [self performSegueWithIdentifier:@"idSegueViewExpense" sender:self];
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - Other Views Delegate Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - Other Views Delegate Methods ----------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief 
 */
- (void)addNewExpenseWasFinished{
    /* Recalculate the total. */
    [self calculateTotal];
}

/*! \brief
 */
-(void)editExpenseWasFinished {
    /* Recalculate the total. */
    [self calculateTotal];
}

@end
