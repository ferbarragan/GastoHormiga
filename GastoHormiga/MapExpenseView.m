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
#import "DBManager.h"
#import <Google-Maps-iOS-Utils/GMUMarkerClustering.h>
#import <GoogleMaps/GoogleMaps.h>

// Point of Interest Item which implements the GMUClusterItem protocol.
@interface POIItem : NSObject<GMUClusterItem>

@property(nonatomic, readonly) CLLocationCoordinate2D position;
@property(nonatomic, readonly) NSString *name;

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position name:(NSString *)name;

@end


@implementation POIItem

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position name:(NSString *)name {
    if ((self = [super init])) {
        _position = position;
        _name = [name copy];
    }
    return self;
}

@end

/* Custom Rendeder */
@interface MyClusterRenderer : GMUDefaultClusterRenderer
@end

@implementation MyClusterRenderer

- (NSString *)getCustomTitleItem:(id)userData {
    POIItem *item = userData;
    return item.name;
}

@end

@interface MapExpenseView ()

@property GMSMapView *mapView;
@property GMUClusterManager *clusterManager;
@property (nonatomic, strong) DBManager *dbManager;

/* Core Location Variables */
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic) float currLat;
@property (nonatomic) float currLon;

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
    
    /* Get users location to center the map's view. */
    [self initializeLocationService];

}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS Specific Function:
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma - mark MapView Methods
/* ------------------------------------------------------------------------------------------------------------------ */
/* - MapView Methods ------------------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief GoogleMaps SDK Specific Function:
 */
- (void)mapInit {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currLat
                                                            longitude:self.currLon
                                                                 zoom:10];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    self.view = self.mapView;
    
    /* Set up the cluster manager with a supplied icon generator and renderer. */
    id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
    id<GMUClusterIconGenerator> iconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
    id<GMUClusterRenderer> renderer = [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView
                                                                    clusterIconGenerator:iconGenerator];
    self.clusterManager = [[GMUClusterManager alloc] initWithMap:_mapView
                                                       algorithm:algorithm
                                                        renderer:renderer];
    
    [_clusterManager setDelegate:self mapDelegate:self];
    
    [self dataBaseInit];
    [self getExpenseMarkers];
}

#pragma - mark GoogleMaps Delegate Methods
/* ------------------------------------------------------------------------------------------------------------------ */
/* - GoogleMaps Delegate Methods ------------------------------------------------------------------------------------ */
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief GoogleMaps SDK Specific Function:
 */
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief
 */
-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark GMUClusterManagerDelegate

/*! \brief
 */
- (void)clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster {
    GMSCameraPosition *newCamera =
    [GMSCameraPosition cameraWithTarget:cluster.position zoom:_mapView.camera.zoom + 1];
    GMSCameraUpdate *update = [GMSCameraUpdate setCamera:newCamera];
    [_mapView moveCamera:update];
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark GMSMapViewDelegate

/*! \brief
 */
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    POIItem *poiItem = marker.userData;
    if (poiItem != nil) {
        NSLog(@"Did tap marker for cluster item %@", poiItem.name);
    } else {
        NSLog(@"Did tap a normal marker");
    }
    return NO;
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

/*! \brief Get the expense coordinates from the database.
 */
-(void)getExpenseMarkers {
    
    /* Form the query. */
    NSString *query = @"select amount, latitude, longitude from expense";
    float latitude;
    float longitude;
    int i;
    CLLocationCoordinate2D expenseCoordinate;
    
    /* Get the results from the database. */
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // NSInteger indexOfAmount = [self.dbManager.arrColumnNames indexOfObject:@"amount"]; // Not used yet...
    NSInteger indexOfLatitude = [self.dbManager.arrColumnNames indexOfObject:@"latitude"];
    NSInteger indexOfLongitude = [self.dbManager.arrColumnNames indexOfObject:@"longitude"];
    
    for (i = 0; i < results.count; i++) {
        latitude  = [[[results objectAtIndex:i] objectAtIndex:indexOfLatitude] floatValue];
        longitude = [[[results objectAtIndex:i] objectAtIndex:indexOfLongitude] floatValue];
        /* Check if the current expense has coordinates. */
        if ((0 != latitude) && (0 != longitude))
        {
            expenseCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
            /* Create a new marker */
            id<GMUClusterItem> item = [[POIItem alloc] initWithPosition:expenseCoordinate
                                                                   name:@"Hola"];
            [_clusterManager addItem:item];
        } else {
            /* Do no add the current expense to markers. */
        }
    }
    [_clusterManager cluster];
}
/* ------------------------------------------------------------------------------------------------------------------ */

#pragma mark - GeoLocation Methods.
/* ------------------------------------------------------------------------------------------------------------------ */
/* - GeoLocation Methods -------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */

-(void)initializeLocationService
{
    /* Initiate location services */
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}
/* ------------------------------------------------------------------------------------------------------------------ */

/*! \brief iOS specific.
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    /* ToDo: Remove warning: Warning: Attempt to present <UIAlertController: 0x1516a000>  on
     <AddNewExpense: 0x14596d30> which is already presenting <UIAlertController: 0x151a0000> */
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                             message:@"¡Hubo un error al obtener tu ubicación!"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    /* We add buttons to the alert controller by creating UIAlertActions: */
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil]; //You can use a block here to handle a press on this button
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
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
        
        /* After getting a valid user's location, initialize the map and the markers. */
        [self mapInit];
    }
}
/* ------------------------------------------------------------------------------------------------------------------ */

@end
