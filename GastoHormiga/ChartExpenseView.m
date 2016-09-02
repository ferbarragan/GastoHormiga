//
//  ChartExpenseView.m
//  GastoHormiga
//
//  Created by Christian Barragan on 29/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "ChartExpenseView.h"
#import "DBManager.h"
#import "BackgroundLayer.h"

#define Percentage(x) ((x*100)/_totalExpense)

@interface ChartExpenseView ()

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic) float totalExpense;

@end

@implementation ChartExpenseView

#pragma mark - ViewController Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - ViewController Methods ----------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Change the background. */
    [self setBackground];
    
    /* Initialize the database manager. */
    [self dataBaseInit];
    
    [self calculateTotal];
    
    float fPayCash  = [self calculateTotalOfCategory:@"payMethod='Efectivo'"];
    float fPayTC    = [self calculateTotalOfCategory:@"payMethod='Tarjeta de Crédito'"];
    float fPayTD    = [self calculateTotalOfCategory:@"payMethod='Tarjeta de Débito'"];
    float fCatFood  = [self calculateTotalOfCategory:@"category='Comida'"];
    float fCatGas   = [self calculateTotalOfCategory:@"category='Gasolina'"];
    float fCatTrans = [self calculateTotalOfCategory:@"category='Transporte'"];
    float fCatEntr  = [self calculateTotalOfCategory:@"category='Entretenimiento'"];
    float fCatLikes = [self calculateTotalOfCategory:@"category='Gustos'"];
    float fCatOther = [self calculateTotalOfCategory:@"category='Otros'"];
    
    self.lblPayCash.text = [NSString stringWithFormat:@"$%.1f/%.1f%%",fPayCash, Percentage(fPayCash)];
    self.lblPayTC.text   = [NSString stringWithFormat:@"$%.1f/%.1f%%",fPayTC, Percentage(fPayTC)];
    self.lblPayTD.text   = [NSString stringWithFormat:@"$%.1f/%.1f%%",fPayTD, Percentage(fPayTD)];
    
    self.lblCatFood.text  = [NSString stringWithFormat:@"$%.1f/%.1f%%",fCatFood, Percentage(fCatFood)];
    self.lblCatGas.text   = [NSString stringWithFormat:@"$%.1f/%.1f%%",fCatGas, Percentage(fCatGas)];
    self.lblCatTrans.text = [NSString stringWithFormat:@"$%.1f/%.1f%%",fCatTrans, Percentage(fCatTrans)];
    self.lblCatEntr.text  = [NSString stringWithFormat:@"$%.1f/%.1f%%",fCatEntr, Percentage(fCatEntr)];
    self.lblCatLikes.text = [NSString stringWithFormat:@"$%.1f/%.1f%%",fCatLikes, Percentage(fCatLikes)];
    self.lblCatOther.text = [NSString stringWithFormat:@"$%.1f/%.1f%%",fCatOther, Percentage(fCatOther)];
    
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief This settles a backgound layer with a gradient color.
 */
- (void)setBackground {
    CAGradientLayer *bgLayer = [BackgroundLayer redGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
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

-(float)calculateTotalOfCategory: (NSString*) category {
    
    NSArray *arrExpenses;
    int i;
    /* Form the query. */
    NSString *query = [[NSString alloc]initWithFormat:@"select amount from expense where %@",category];
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

/*! \brief Calculates the total expense.
 */
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
}
/* ------------------------------------------------------------------------------------------------------------------ */

@end
