//
//  MapExpenseView.h
//  GastoHormiga
//
//  Created by Christian Barragan on 28/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google-Maps-iOS-Utils/GMUMarkerClustering.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MapExpenseView : UIViewController<GMUClusterManagerDelegate, GMSMapViewDelegate>

@end
