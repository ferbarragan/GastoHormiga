//
//  ExpensesView.m
//  GastoHormiga
//
//  Created by Christian Barragan on 23/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//
//  Disclaimer: The icons for this application where taken
//              from https://icons8.com/

#import "ExpensesView.h"
#import "DBManager.h"
#import "BackgroundLayer.h"

@interface ExpensesView ()

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrExpensesInfo;
@property (nonatomic) int recordIdToEdit;
@property (nonatomic, strong) NSString *currRowImagePath;

@end

@implementation ExpensesView

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
    
    /* Set TableView delegates */
    [self tableViewSetDelegates];
    
    /* Database initialization */
    [self dataBaseInit];
    
    /* Load data to TableView */
    [self tableViewLoadData];
    
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"idSegueEditExpense"]){
        /*  Make this View a delegate of AddExpensesView */
        AddExpensesView *addExpenseView = [segue destinationViewController];
        addExpenseView.delegate = self;
        /* Set the AddExpensesView public property recordIdToEdit  */
        addExpenseView.recordIdToEdit = self.recordIdToEdit;
    } else if ([segue.identifier isEqualToString:@"idSegueViewImage"]){
        ExpenseImageView *expensesImageView = [segue destinationViewController];
        expensesImageView.imagePath = self.currRowImagePath;
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief This settles a backgound layer with a gradient color.
 */
- (void)setBackground {
    CAGradientLayer *bgLayer = [BackgroundLayer redGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    self.tblExpenses.backgroundColor = [UIColor clearColor];
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - TableView Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - TableView Methods ---------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Make self the delegate of the textfields.
 */
- (void)tableViewSetDelegates {
    self.tblExpenses.delegate = self;
    self.tblExpenses.dataSource = self;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/* \brief Fill the TableView with data from the database.
 */
- (void)tableViewLoadData {
    /* Form the query. */
    NSString *query = @"select * from expense";
    
    /* Initialize the array. */
    if (self.arrExpensesInfo != nil) {
        self.arrExpensesInfo = nil;
    }
    /* Get the results. */
    self.arrExpensesInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    /* Reload the table view. */
    [self.tblExpenses reloadData];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrExpensesInfo.count;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /* Dequeue the cell. */
    cellExpenses *cell = (cellExpenses *)[tableView dequeueReusableCellWithIdentifier:@"cellExpenses"];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"cellExpenses" bundle:nil] forCellReuseIdentifier:@"cellExpenses"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellExpenses"];
    }
    
    cell.delegate = self;
    cell.cellIndex = indexPath.row;
    
    NSInteger indexOfAmount = [self.dbManager.arrColumnNames indexOfObject:@"amount"];
    NSInteger indexOfDescription = [self.dbManager.arrColumnNames indexOfObject:@"description"];
    NSInteger indexOfDate = [self.dbManager.arrColumnNames indexOfObject:@"date"];
    NSInteger indexOfType = [self.dbManager.arrColumnNames indexOfObject:@"payMethod"];
    NSInteger indexOfCateg = [self.dbManager.arrColumnNames indexOfObject:@"category"];
    //NSInteger indexOfImageUrl = [self.dbManager.arrColumnNames indexOfObject:@"imageUrl"];
    
    /* Set the loaded data to the appropriate cell labels. */
    cell.lblAmount.text = [NSString stringWithFormat:@"%@", [[self.arrExpensesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfAmount]];
    cell.lblDescription.text = [NSString stringWithFormat:@"%@", [[self.arrExpensesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfDescription]];
    cell.lblDate.text = [NSString stringWithFormat:@"%@", [[self.arrExpensesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfDate]];
    cell.lblType.text = [NSString stringWithFormat:@"%@", [[self.arrExpensesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfType]];
    cell.lblCateg.text = [NSString stringWithFormat:@"%@", [[self.arrExpensesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfCateg]];
    //cell.lblImagePath.text = [NSString stringWithFormat:@"%@", [[self.arrExpensesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfImageUrl]];
    
    return cell;
}
/* ------------------------------------------------------------------------------------------------------------------ */


/*! \brief iOS Specific Function:
 */
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /* Delete the selected record. */
        /* Find the record ID. */
        int recordIDToDelete = [[[self.arrExpensesInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        /* Prepare the query. */
        NSString *query = [NSString stringWithFormat:@"delete from expense where id=%d", recordIDToDelete];
        
        /* Execute the query. */
        [self.dbManager executeQuery:query];
        
        /* Reload the table view. */
        [self tableViewLoadData];
        
        /* Update notify the delagates to take the required actions. */
        [self.delegate editExpenseWasFinished];
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - Custom Cell Delegates.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - Custom Cell Delegates ------------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------------------------------------ */
- (void)didClickOnEditButtonAtIndex:(NSInteger)cellIndex withData:(id)data {
    /* Store in the local variable, the row that was selected to edit. */
    self.recordIdToEdit = [[[self.arrExpensesInfo objectAtIndex:cellIndex] objectAtIndex:0] intValue];
    /* Trigger the segue. */
    [self performSegueWithIdentifier:@"idSegueEditExpense" sender:self];
}
/* ------------------------------------------------------------------------------------------------------------------ */

- (void)didClickOnImageButtonAtIndex:(NSInteger)cellIndex withData:(id)data {
    //NSInteger indexOfImgUrl = [self.dbManager.arrColumnNames indexOfObject:@"imageUrl"];
    
    /* Get the image path */
    //self.currRowImagePath = [NSString stringWithFormat:@"%@", [[self.arrExpensesInfo objectAtIndex:cellIndex] objectAtIndex:indexOfImgUrl]];
    
    /* Trigger the segue. */
    //[self performSegueWithIdentifier:@"idSegueViewImage" sender:self];
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

#pragma mark - Other Views Delegate Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - Other Views Delegate Methods ----------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief In this view controller, this delagates means that an existent record was edited.
 */
- (void)addNewExpenseWasFinished{
    [self tableViewLoadData];
    [self.delegate editExpenseWasFinished];
}
@end
