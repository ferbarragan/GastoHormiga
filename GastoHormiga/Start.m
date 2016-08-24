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

@end

@implementation Start

/*! \brief iOS Specific Function:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    /* Change the background. */
    [self setBackground];
    /* Initialize the database manager. */
    [self dataBaseInit];
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

/*! \brief This settles a backgound layer with a gradient color.
 */
- (void)setBackground {
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief This initializes the database manager.
 */
- (void)dataBaseInit {
    /* Initialize the dbManager property. */
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:DATABASE_NAME];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    /* Dispose of any resources that can be recreated. */
}
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
}
/* ------------------------------------------------------------------------------------------------------------------ */
@end
