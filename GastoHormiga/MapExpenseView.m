//
//  MapExpenseView.m
//  GastoHormiga
//
//  Created by Christian Barragan on 28/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//
//  Disclaimer: The icons for this application where taken
//              from https://icons8.com/

#import "MapExpenseView.h"

@interface MapExpenseView ()

@property GMSMapView *mapView;
@property float currLat;
@property float currLon;

@end

@implementation MapExpenseView

#pragma - mark ViewController Methods
/* ------------------------------------------------------------------------------------------------------------------ */
/* - ViewController Methods ----------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:23.9079007
                                                            longitude:-99.5448522
                                                                 zoom:3.5];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    self.view = self.mapView;
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma - mark GoogleMaps Delegate Methods
/* ------------------------------------------------------------------------------------------------------------------ */
/* - GoogleMaps Methods --------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

@end
