//
//  AddExpensesView.m
//  GastoHormiga
//
//  Created by Christian Barragan on 23/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//
//  Disclaimer: The icons for this application where taken
//              from https://icons8.com/

#import "AddExpensesView.h"
#import "DBManager.h"
#import "BackgroundLayer.h"



@interface AddExpensesView ()

#define SCROLLVIEWOFFSET 70

@property (nonatomic, strong) DBManager *dbManager;

/* Information pickers */
@property (nonatomic, strong) UIPickerView *pickerPayMethod; /* Payment Method PickerView */
@property (nonatomic, strong) UIPickerView *pickerCategory;  /* Category PickerView */
@property (nonatomic, strong) UIDatePicker *datePicker;      /* Date PickerView */
@property (nonatomic, strong) NSArray *arrPickerPayMethod;
@property (nonatomic, strong) NSArray *arrPickerCategory;
@property (nonatomic) int lastPickerPayMethodRow;
@property (nonatomic) int lastPickerCategoryRow;


/* Arrays to hold the picker's information */
#define PICKERPAYMETHODVALUES @"Efectivo", @"Tarjeta de Crédito", @"Tarjeta de Débito"
#define PICKERCATEGORYVALUES  @"Comida", @"Transporte", @"Gasolina", @"Entretenimiento", @"Gustos", @"Otros"





/* Core Location Variables */
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic) float currLat;
@property (nonatomic) float currLon;
@property (nonatomic) BOOL locationActivated;

/* Global variable to store the image path. */
@property (nonatomic, strong) NSString * imagePath;

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
    
    /* Set the background color. */
    [self setBackground];
    
    /* Set TextField delegates. */
    [self textFieldSetDelegates];
    
    /* Set a ScrollView. */
    [self scrollViewInit];
    
    /* Database initialization. */
    [self dataBaseInit];
    
    /* Configure PickerViews. */
    [self configurePickerView];
    [self configureDatePicker];
    
    /* Configure Numeric Keyboard. */
    [self configureNumericPad];
    
    /* Check if we are going to add a new expense or to modify an existent one. */
    if (ADD_NEW_EXPENSE != self.recordIdToEdit) {
        /* Load the TextViews with the desired information from the database. */
        [self loadInfoToEdit];
    } else {
        /* It seems that we are going to add a new expense. */
    }
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
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - Action Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - Action Methods ------------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Action when button btnSave is pressed. This will execute a SQL command to store the values in the database.
 */
- (IBAction)btnSavePressed:(id)sender {
    
    /* Check that all the TextFields are filled. */
    if ([self someTextFieldIsEmpty])
    {
        /* ToDo: Remove warning: Warning: Attempt to present <UIAlertController: 0x1516a000>  on
         <AddNewExpense: 0x14596d30> which is already presenting <UIAlertController: 0x151a0000> */
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:@"¡Todos los campos deben estar llenos!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        /* We add buttons to the alert controller by creating UIAlertActions: */
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        /* Prepare the query string. If the recordIDToEdit property has value other than -1, then create an update query,
         * otherwie create an insert query */
        NSString *query;
        if (ADD_NEW_EXPENSE == self.recordIdToEdit) {
            /* Table scheme: id, amount, date, description, payMethod, category, latitude, longitude, imageUrl */
            query = [NSString stringWithFormat:
                     @"insert into expense values(null, '%@', '%@', '%@', '%@', '%@', '%.6f', '%.6f', '%@')",
                     self.txtAmount.text,
                     self.txtDate.text,
                     self.txtDescr.text,
                     self.txtPayMet.text,
                     self.txtCateg.text,
                     self.currLat,
                     self.currLon,
                     self.imagePath];
        } else {
            query = [NSString stringWithFormat:
                     @"update expense set amount='%@', date='%@', description='%@', payMethod='%@', category='%@', latitude='%.6f', longitude='%.6f', imageUrl='%@' where id=%d",
                     self.txtAmount.text,
                     self.txtDate.text,
                     self.txtDescr.text,
                     self.txtPayMet.text,
                     self.txtCateg.text,
                     self.currLat,
                     self.currLon,
                     self.imagePath,
                     self.recordIdToEdit];
        }
        
        /* Execute the query. */
        [self.dbManager executeQuery:query];
        
        /* If the query was successfully executed then pop the view controller. */
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
            
            /* Call the delegate method. */
            [self.delegate addNewExpenseWasFinished];
            
            /* Pop the view controller. */
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            NSLog(@"Could not execute the query.");
        }
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Action when button btnAddPicture is pressed.
 */
- (IBAction)btnAddPicturePressed:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Action when button btnAddPicture is pressed.
 */
- (IBAction)btnAddLocationPressed:(id)sender {

    if (NO == self.locationActivated) {
        /* Configure Location Services */
        [self initializeLocationService];
        self.locationActivated = YES;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    } else {
        self.locationActivated = NO;
        /* Erase the location variables */
        self.currLon = 0;
        self.currLat = 0;
        /* Return the button icon to the original image. */
        [self.btnLocation setImage:[UIImage imageNamed:@"location"]];
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - TextField Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - TextField Methods ---------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Make self the delegate of the textfields.
 */
- (void) configureNumericPad {
    
    /* Set the keyboard type to decimal one. */
    self.txtAmount.keyboardType = UIKeyboardTypeDecimalPad;
    
    
    /* Amount Text Field tool bar and tool bar button configuration. */
    UIToolbar *txtFieldAmountToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [txtFieldAmountToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *txtFieldAmountToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(textFieldAmountEntered)];
    UIBarButtonItem *txtFieldAmountToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                target:nil
                                                                                                action:nil];
    [txtFieldAmountToolBar setItems:[NSArray arrayWithObjects:txtFieldAmountToolBarSpace,
                                                              txtFieldAmountToolBarDoneBtn,
                                                              nil]];
    [self.txtAmount setInputAccessoryView:txtFieldAmountToolBar];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Function called when Tool Bar Button of Numeric Pad was pressed.
 */
- (void) textFieldAmountEntered {
    [self.txtAmount resignFirstResponder];
}
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
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.txtPayMet == textField) {
        [self.pickerPayMethod selectRow:self.lastPickerPayMethodRow inComponent:0 animated:YES];
        self.txtPayMet.text = [self.arrPickerPayMethod objectAtIndex:self.lastPickerPayMethodRow];
    } else if (self.txtCateg == textField) {
        [self.pickerCategory selectRow:self.lastPickerCategoryRow inComponent:0 animated:YES];
        self.txtCateg.text = [self.arrPickerCategory objectAtIndex:self.lastPickerCategoryRow];
    } else {
        
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/* This method is called when the user touches outside of the keyboard zone. */
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    BOOL retVal = NO;
    NSString *txtFieldContent = textField.text;
    
    if ([txtFieldContent isEqualToString:@""]) {
        /* ToDo: Remove warning: Warning: Attempt to present <UIAlertController: 0x1516a000>  on
         <AddNewExpense: 0x14596d30> which is already presenting <UIAlertController: 0x151a0000> */
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:@"¡Este campo no puede estar vacío!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        /* We add buttons to the alert controller by creating UIAlertActions: */
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        retVal = YES;
    }
    return retVal;
}
/* ------------------------------------------------------------------------------------------------------------------ */

-(BOOL)someTextFieldIsEmpty {
    if ([self.txtAmount.text isEqualToString:@""]||
        [self.txtDate.text isEqualToString:@""]  ||
        [self.txtDescr.text isEqualToString:@""] ||
        [self.txtPayMet.text isEqualToString:@""]||
        [self.txtCateg.text isEqualToString:@""])
    {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - ScrollView Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - ScrollView Methods --------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief Add programatically a scroll view.
 */
- (void) scrollViewInit {
    /* Note: About Y axis location of the scroll view... I had to set this to '-SCROLLVIEWOFFSET' to avoid the big ugly 
     * gap between the navigation toolbar and the first TextField.
     */
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                              -SCROLLVIEWOFFSET,
                                                                              self.view.frame.size.width,
                                                                              self.view.frame.size.height
                                                                              + SCROLLVIEWOFFSET)];
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

/*! \brief This initializes the PickerView elements.
 */
-(void)ShowSelectedDate
{
#if 0
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    /* First, store in the variable which will be used in the SQL query, the date in SQL supported format. */
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //self.sqlExpDat = [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.datePicker.date]];
    //self.u8InputDataVality |= DATE_BIT_MASK;
    /* Second, format the selected date into a 'more natural' format and put it in the text field. */
    [formatter setDateFormat:@"dd-MM-yyyy"];
    self.txtDate.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.datePicker.date]];
    [self.txtDate resignFirstResponder];
#endif
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.txtDate.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:self.datePicker.date]];
    [self.txtDate resignFirstResponder];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief This initializes the Date Picker element.
 */
-(void) configureDatePicker {
    /* Date picket configuration */
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.txtDate setInputView:self.datePicker];
    /* Tool bar for the Date Picker. */
    UIToolbar *datePickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [datePickerToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *datePickerToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo" style:UIBarButtonItemStyleDone target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *datePickerToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [datePickerToolBar setItems:[NSArray arrayWithObjects:datePickerToolBarSpace,datePickerToolBarDoneBtn, nil]];
    [self.txtDate setInputAccessoryView:datePickerToolBar];
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - PickerView Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - PickerView Methods --------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief This initializes the PickerView elements.
 */
-(void) configurePickerView {
    /* Pay method Picker configuration. */
    [self loadPickerData];
    
    /********************************************************/
    /**** Configure the PickerView for Pay Method types. ****/
    /********************************************************/
    self.pickerPayMethod = [[UIPickerView alloc]init];
    self.pickerPayMethod.dataSource = self;
    self.pickerPayMethod.delegate = self;
    
    [self.pickerPayMethod setShowsSelectionIndicator:YES];
    [self.pickerPayMethod selectRow:0 inComponent:0 animated:NO];
    
    [self.txtPayMet setInputView:self.pickerPayMethod];
    
    /* Tool bar for the Pay method PickerView. */
    UIToolbar *pickerPayMethodToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [pickerPayMethodToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *pickerPayMethodToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo"
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(closePayMethodPickerView)];
    UIBarButtonItem *pickerPayMethodToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                 target:nil
                                                                                                 action:nil];
    [pickerPayMethodToolBar setItems:[NSArray arrayWithObjects:pickerPayMethodToolBarSpace, pickerPayMethodToolBarDoneBtn, nil]];
    [self.txtPayMet setInputAccessoryView:pickerPayMethodToolBar];
    
    /********************************************************/
    /**** Configure the PickerView for Category types. ******/
    /********************************************************/
    self.pickerCategory = [[UIPickerView alloc] init];
    self.pickerCategory.dataSource = self;
    self.pickerCategory.delegate = self;
    
    [self.pickerCategory setShowsSelectionIndicator:YES];
    [self.pickerCategory selectRow:0 inComponent:0 animated:NO];
    
    [self.txtCateg setInputView:self.pickerCategory];
    
    /* Tool bar for the Category PickerView. */
    UIToolbar *pickerCategoryToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [pickerCategoryToolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *pickerCategoryToolBarDoneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Listo"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(closeCategoryPickerView)];
    UIBarButtonItem *pickerCategoryToolBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                target:nil
                                                                                                action:nil];
    [pickerCategoryToolBar setItems:[NSArray arrayWithObjects:pickerCategoryToolBarSpace, pickerCategoryToolBarDoneBtn, nil]];
    [self.txtCateg setInputAccessoryView:pickerCategoryToolBar];
    
    /* Set the default picker selected row */
    self.lastPickerPayMethodRow = 0;
    self.lastPickerCategoryRow = 0;
    
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief
 */
-(void)loadPickerData{
    
    self.arrPickerPayMethod = @[PICKERPAYMETHODVALUES];
    self.arrPickerCategory  = @[PICKERCATEGORYVALUES];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief
 */
-(void)closePayMethodPickerView {
    [self.txtPayMet resignFirstResponder];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief
 */
-(void)closeCategoryPickerView {
    [self.txtCateg resignFirstResponder];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.pickerPayMethod) {
        return [self.arrPickerPayMethod count];
    }
    else if (pickerView == self.pickerCategory) {
        return [self.arrPickerCategory count];
    }
    else {
        return 0;
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.pickerPayMethod) {
        return [self.arrPickerPayMethod objectAtIndex:row];
    }
    else if (pickerView == self.pickerCategory) {
        return [self.arrPickerCategory objectAtIndex:row];
    }
    else {
        return @"";
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.pickerPayMethod) {
        self.txtPayMet.text = [self.arrPickerPayMethod objectAtIndex:row];
        self.lastPickerPayMethodRow = row;
        
        //self.sqlExpPay = row;
        //self.u8InputDataVality |= PAYMET_BIT_MASK;
        //self.lastPayMethodArrayIndex = row;
    }
    else if (pickerView == self.pickerCategory) {
        self.txtCateg.text = [self.arrPickerCategory objectAtIndex:row];
        self.lastPickerCategoryRow = row;
        //self.sqlExpCat = row;
        //self.u8InputDataVality |= CATEG_BIT_MASK;
        //self.lastCategoryArrayIndex = row;
    }
    else {
        /* Nothing to do... */
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

/*! \brief This initializes the database manager.
 */
- (void)loadInfoToEdit {
    /* Create the query. */
    NSString *query = [NSString stringWithFormat:@"select * from expense where id=%d", self.recordIdToEdit];
    
    /* Load the relevant data. */
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    /* Set the loaded data to the textfields */
    self.txtAmount.text = [[results objectAtIndex:0]
                           objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"amount"]];
    self.txtDate.text   = [[results objectAtIndex:0]
                           objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"date"]];
    self.txtDescr.text  = [[results objectAtIndex:0]
                           objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"description"]];
    self.txtPayMet.text = [[results objectAtIndex:0]
                           objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"payMethod"]];
    self.txtCateg.text  = [[results objectAtIndex:0]
                           objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"category"]];
    self.currLon = [[[results objectAtIndex:0]
                    objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"longitude"]] floatValue];
    self.currLat = [[[results objectAtIndex:0]
                    objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"latitude"]] floatValue];
    
    /* If last coordinates where not equal than zero, we should put the locationSelected icon. */
    if ((0 != self.currLon) && (0 != self.currLat)) {
        [self.btnLocation setImage:[UIImage imageNamed:@"locationSelected"]];
    } else {
        /* Keep the default icon. */
    }
    
}
/* ------------------------------------------------------------------------------------------------------------------ */

#if 0
#pragma mark - ImagePicker Methods (Camera).
/* ------------------------------------------------------------------------------------------------------------------ */
/* - ImagePicker Methods -------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS specific.
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS specific.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;
    
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    self.imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",@"cached"]];
    
    NSLog((@"pre writing to file"));
    
    if (![imageData writeToFile:self.imagePath atomically:NO])
    {
        NSLog((@"Failed to cache image data to disk"));
    }
    else
    {
        NSLog((@"the cachedImagedPath is %@",self.imagePath));
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
/* ------------------------------------------------------------------------------------------------------------------ */
#endif
#pragma mark - GeoLocation Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - GeoLocation Methods -------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)initializeLocationService
{
    /* Initiate location services */
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationActivated = NO;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS specific.
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                             message:@"¡Hubo un error al obtener tu ubicación!"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    /* We add buttons to the alert controller by creating UIAlertActions: */
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil]; //You can use a block here to handle a press on this button
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
    
    NSLog(@"Error: %@",error.description);
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS specific.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.currLat = currentLocation.coordinate.latitude;
        self.currLon = currentLocation.coordinate.longitude;
        [self.locationManager stopUpdatingHeading];
        self.locationManager = nil; /* Destroy the location Manager. */
        /* Set the button icon to the pressed image. */
        [self.btnLocation setImage:[UIImage imageNamed:@"locationSelected"]];
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

@end
