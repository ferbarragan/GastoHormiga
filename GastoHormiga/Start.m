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

/*! \brief iOS Specific Function: Make this View a delegate of AddExpensesView
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    AddExpensesView *addExpenseView = [segue destinationViewController];
    addExpenseView.delegate = self;
    
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
    //float fltCurrExpense;
    
    NSNumberFormatter *decimalStyleFormatter = [[NSNumberFormatter alloc] init];
    [decimalStyleFormatter setMaximumFractionDigits:2];
    
    /* Initialize the array. */
    if (arrExpenses != nil) {
        arrExpenses = nil;
    }
    
    self.totalExpense = 0;
    
    /* Get the results. */
    arrExpenses = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    /* Get the results from the database */
    //arrPayMethodsFromDb = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    //self.arrPickerPayMethod = [[NSMutableArray alloc] initWithCapacity:arrPayMethodsFromDb.count];
    
    //NSString *value = @"553637.90";
    //NSNumber *num = @([value floatValue]); // 1. This is the problem. num is set to 553637.875000
    
    
    //NSString *resultString = [decimalStyleFormatter stringFromNumber:num]; // 2. string is assigned with rounded value like 553637.88
    //float originalValue = [resultString floatValue]; // 3. Hence, originalValue turns out to be 553637.88 which wrong.
    
    for (i = 0; i < arrExpenses.count; i++) {
        strCurrExpense = [[arrExpenses objectAtIndex:i] objectAtIndex:0];
        numCurrExpense = @([strCurrExpense floatValue]);
        strCurrExpenseFmt = [decimalStyleFormatter stringFromNumber:numCurrExpense];
        self.totalExpense += [strCurrExpenseFmt floatValue];
        
        
        
        //self.totalExpense = self.totalExpense + [NSDecimalNumber decimalNumberWithString:currExpense];
        
        //[self.arrPickerPayMethod addObject:[[arrPayMethodsFromDb objectAtIndex:i] objectAtIndex:0]];
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
