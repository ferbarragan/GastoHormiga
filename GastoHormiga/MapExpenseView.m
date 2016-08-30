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



static const NSUInteger kClusterItemCount = 10000;
static const double kCameraLatitude = 23.9079007;
static const double kCameraLongitude = -99.5448522;

@interface MapExpenseView ()

@property GMSMapView *mapView;
@property GMUClusterManager *clusterManager;
@property (nonatomic, strong) DBManager *dbManager;

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
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:kCameraLatitude
                                                            longitude:kCameraLongitude
                                                                 zoom:3.5];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    self.view = self.mapView;
    
    // Set up the cluster manager with a supplied icon generator and renderer.
    id<GMUClusterAlgorithm> algorithm =
    [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
    id<GMUClusterIconGenerator> iconGenerator =
    [[GMUDefaultClusterIconGenerator alloc] init];
    id<GMUClusterRenderer> renderer =
    [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView
                                  clusterIconGenerator:iconGenerator];
    self.clusterManager =
    [[GMUClusterManager alloc] initWithMap:_mapView
                                 algorithm:algorithm
                                  renderer:renderer];
    // Generate and add random items to the cluster manager.
    //[self generateClusterItems];
    
    [_clusterManager setDelegate:self mapDelegate:self];
    
    [self dataBaseInit];
    [self getExpenseMarkers];
    
    // Call cluster() after items have been added
    // to perform the clustering and rendering on map.
    //[_clusterManager cluster];
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

/*! \brief GoogleMaps SDK Specific Function:
 */
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    /* Create a new marker */
    id<GMUClusterItem> item = [[POIItem alloc] initWithPosition:coordinate
                                 name:@"Hola"];
    [_clusterManager addItem:item];
    [_clusterManager cluster];
    
#if 0
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coordinate; /* Set the marker at the touched coordinate. */
    marker.title = @"Hola";
    marker.map = self.mapView; /* Add marker to the MapView */
    
    /* Store the current marker's coordinates. */
    self.currLat = marker.position.latitude;
    self.currLon = marker.position.longitude;
    
    /* Set the recently created marked as selected. */
    [self.mapView setSelectedMarker:marker];
#endif
}

-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    [_clusterManager cluster];
}

// Randomly generates cluster items within some extent of the camera and
// adds them to the cluster manager.
#if 0
- (void)generateClusterItems {
    const double extent = 0.2;
    for (int index = 1; index <= kClusterItemCount; ++index) {
        double lat = kCameraLatitude + extent * [self randomScale];
        double lng = kCameraLongitude + extent * [self randomScale];
        NSString *name = [NSString stringWithFormat:@"Item %d", index];
        id<GMUClusterItem> item =
        [[POIItem alloc] initWithPosition:CLLocationCoordinate2DMake(lat, lng)
                                     name:name];
        [_clusterManager addItem:item];
    }
}

// Returns a random value between -1.0 and 1.0.
- (double)randomScale {
    return (double)arc4random() / UINT32_MAX * 2.0 - 1.0;
}
#endif

#pragma mark GMUClusterManagerDelegate

- (void)clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster {
    GMSCameraPosition *newCamera =
    [GMSCameraPosition cameraWithTarget:cluster.position zoom:_mapView.camera.zoom + 1];
    GMSCameraUpdate *update = [GMSCameraUpdate setCamera:newCamera];
    [_mapView moveCamera:update];
}

#pragma mark GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    POIItem *poiItem = marker.userData;
    if (poiItem != nil) {
        NSLog(@"Did tap marker for cluster item %@", poiItem.name);
    } else {
        NSLog(@"Did tap a normal marker");
    }
    return NO;
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

-(void)getExpenseMarkers {
    
    /* Form the query. */
    NSString *query = @"select amount, latitude, longitude from expense";
    float latitude;
    float longitude;
    int i;
    CLLocationCoordinate2D expenseCoordinate;
    //GMSMarker *marker;
    
    /* Get the results from the database. */
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    NSInteger indexOfAmount = [self.dbManager.arrColumnNames indexOfObject:@"amount"];
    NSInteger indexOfLatitude = [self.dbManager.arrColumnNames indexOfObject:@"latitude"];
    NSInteger indexOfLongitude = [self.dbManager.arrColumnNames indexOfObject:@"longitude"];
    
    for (i = 0; i < results.count; i++) {
        //marker = [[GMSMarker alloc] init];
        
        latitude  = [[[results objectAtIndex:i] objectAtIndex:indexOfLatitude] floatValue];
        longitude = [[[results objectAtIndex:i] objectAtIndex:indexOfLongitude] floatValue];
        expenseCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        /* Create a new marker */
        id<GMUClusterItem> item = [[POIItem alloc] initWithPosition:expenseCoordinate
                                                               name:@"Hola"];
        [_clusterManager addItem:item];
        [_clusterManager cluster];
        
        //marker.title = [[results objectAtIndex:i] objectAtIndex:indexOfAmount];
        
        
        //marker = [GMSMarker markerWithPosition:expenseCoordinate];
        //marker.position = expenseCoordinate;
        
        
    }
    [_clusterManager cluster];
}
/* ------------------------------------------------------------------------------------------------------------------ */
@end
