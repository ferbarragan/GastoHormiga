//
//  AddExpensesView.m
//  GastoHormiga
//
//  Created by Christian Barragan on 23/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "AddExpensesView.h"
#import "DBManager.h"

@interface AddExpensesView ()

@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation AddExpensesView

#pragma mark - ViewController Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - ViewController Methods ----------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Set TextField delegates */
    [self textFieldSetDelegates];
    
    /* Set a ScrollView */
    [self scrollViewInit];
    
    /* Database initialization */
    [self dataBaseInit];
    
    
}
/* ------------------------------------------------------------------------------------------------------------------ */
/*! \brief iOS Specific Function:
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - ViewController Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - ViewController Methods ----------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Action when button btnSave is pressed. This will execute a SQL command to store the values in the database.
 */
- (IBAction)btnSavePressed:(id)sender {
    /* Prepare the query string. */
    /* Table scheme: id, amount, date, description, payMethod, category, latitude, longitude, imageUrl */
    NSString *query = [NSString stringWithFormat:@"insert into expense values(null, '%@', '%@', '%@', '%@', '%@', 'noLat', 'noLon', 'noUrl')",
                       self.txtAmount.text,
                       self.txtDate.text,
                       self.txtDescr.text,
                       self.txtPayMet.text,
                       self.txtCateg.text];
    
    /* Execute the query. */
    [self.dbManager executeQuery:query];
    
    /* If the query was successfully executed then pop the view controller. */
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        
        /* Pop the view controller. */
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - TextField Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - TextField Methods ---------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Make self the delegate of the textfields.
 */
- (void) textFieldSetDelegates {
    self.txtAmount.delegate = self;
    self.txtDate.delegate   = self;
    self.txtDescr.delegate  = self;
    self.txtPayMet.delegate = self;
    self.txtCateg.delegate  = self;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - ScrollView Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - ScrollView Methods --------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Add programatically a scroll view.
 */
- (void) scrollViewInit {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.contentSize = CGSizeMake(320, 800);
    scrollView.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:scrollView];
    /* Add the TextField and Button elements to the scroll view. */
    [scrollView addSubview:self.lblAmountSymbol];
    [scrollView addSubview:self.txtAmount];
    [scrollView addSubview:self.lblAmountLine];
    [scrollView addSubview:self.txtDate];
    [scrollView addSubview:self.lblDateLine];
    [scrollView addSubview:self.txtDescr];
    [scrollView addSubview:self.lblDescrLine];
    [scrollView addSubview:self.txtCateg];
    [scrollView addSubview:self.lblCategLine];
    [scrollView addSubview:self.txtPayMet];
    [scrollView addSubview:self.lblPayMetLine];
    [scrollView addSubview:self.btnSave];
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - DatePicker Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - DatePicker Methods --------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - PickerView Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - PickerView Methods --------------------------------------------------------------------------------------------- */
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

@end
