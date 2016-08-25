//
//  ViewController.m
//  GastoHormiga
//
//  Created by Christian Barragan on 23/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "ExpensesView.h"
#import "DBManager.h"

@interface ExpensesView ()

@property (nonatomic, strong) DBManager *dbManager;

@property (nonatomic, strong) NSArray *arrExpensesInfo;

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

#pragma mark - TableView Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - TableView Methods ---------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Make self the delegate of the textfields.
 */
- (void) tableViewSetDelegates {
    self.tblExpenses.delegate = self;
    self.tblExpenses.dataSource = self;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/* \brief Fill the TableView with data from the database.
 */
- (void) tableViewLoadData {
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
    return 60;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
#if 0
    cellExpenses *cell = (cellExpenses *)[tableView dequeueReusableCellWithIdentifier:@"cellExpenses"];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"cellExpenses" bundle:nil] forCellReuseIdentifier:@"cellExpenses"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellExpenses"];
    }
#endif
    /* Dequeue the cell. */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
    
    NSInteger indexOfAmount = [self.dbManager.arrColumnNames indexOfObject:@"amount"];
    NSInteger indexOfDescription = [self.dbManager.arrColumnNames indexOfObject:@"description"];
    NSInteger indexOfDate = [self.dbManager.arrColumnNames indexOfObject:@"date"];
    
#if 0
    /* Set the loaded data to the appropriate cell labels. */
    cell.lblAmount.text = [NSString stringWithFormat:@"%@", [[self.arrExpenseInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfAmount]];
    
    cell.lblDescription.text = [NSString stringWithFormat:@"%@", [[self.arrExpenseInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfDescription]];
    cell.lblDate.text = [NSString stringWithFormat:@"%@", [[self.arrExpenseInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfDate]];
#endif
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrExpensesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfAmount]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[self.arrExpensesInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfDescription]];
    return cell;
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

@end
