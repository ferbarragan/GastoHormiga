//
//  AddExpensesView.h
//  GastoHormiga
//
//  Created by Christian Barragan on 23/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol AddExpensesViewDelegate

-(void) addNewExpenseWasFinished;

@end

@interface AddExpensesView : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

/* Delegates */
@property (nonatomic, strong) id<AddExpensesViewDelegate> delegate;

/* UI Outlets */
@property (weak, nonatomic) IBOutlet UITextField *txtAmount;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (weak, nonatomic) IBOutlet UITextField *txtDescr;
@property (weak, nonatomic) IBOutlet UITextField *txtPayMet;
@property (weak, nonatomic) IBOutlet UITextField *txtCateg;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UILabel *lblAmountSymbol;
@property (weak, nonatomic) IBOutlet UILabel *lblAmountLine;
@property (weak, nonatomic) IBOutlet UILabel *lblDateLine;
@property (weak, nonatomic) IBOutlet UILabel *lblDescrLine;
@property (weak, nonatomic) IBOutlet UILabel *lblPayMetLine;
@property (weak, nonatomic) IBOutlet UILabel *lblCategLine;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnLocation;

/* Actions */
- (IBAction)btnSavePressed:(id)sender;
- (IBAction)btnAddPicturePressed:(id)sender;
- (IBAction)btnAddLocationPressed:(id)sender;


/* Public properties */
@property (nonatomic) int recordIdToEdit;

/* Defines/Macros */
#define ADD_NEW_EXPENSE (-1)

@end
