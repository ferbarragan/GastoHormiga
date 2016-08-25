//
//  Start.m
//  GastoHormiga
//
//  Created by Christian Barragan on 23/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "Start.h"
#import "BackgroundLayer.h"
#import "DBManager.h"

@interface Start ()

@property (nonatomic, strong) DBManager *dbManager;

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
    /* Un-hide the NavigationController Toolbar when leaving this View. */
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewDidDisappear:animated];
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
        AddExpensesView *addExpenseView = [segue destinationViewController];
        addExpenseView.delegate = self;
    } else if ([segue.identifier isEqualToString:@"idSegueViewExpense"]) {
        
    }
    
    
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
    
     [self.btnViewExpense setTitle:[NSString stringWithFormat:@"$%.2f", self.totalExpense] forState:UIControlStateNormal];
    
}

#pragma mark - Action Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - Action Methods ------------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Action when the button btnAddExpense is pressed. This will change the view controller.
 */
- (IBAction)btnAddExpensePressed:(id)sender {
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

- (void)addNewExpenseWasFinished{
    /* Recalculate the total. */
    [self calculateTotal];
}
@end
