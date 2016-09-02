//
//  ExpenseImageView.m
//  GastoHormiga
//
//  Created by Christian Barragan on 31/08/16.
//  Copyright © 2016 Christian Barragan. All rights reserved.
//

#import "ExpenseImageView.h"

@interface ExpenseImageView ()

@end

@implementation ExpenseImageView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSData *imgData = [NSData dataWithContentsOfFile:self.imagePath];
    
    //NSString *fullPath = [[NSString alloc] initWithFormat:@"file:/%@",self.imagePath];
    
    //NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:fullPath]];
    
    //UIImage *expenseImage = [[UIImage alloc] initWithData:imgData];
    
    //UIImage *thumbNail=[UIImage imageWithContentsOfFile:self.imagePath];
    //[self.imgExpense setImage:thumbNail];
    
    //self.imgExpense.image = expenseImage;
    
    //UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100,100,200,200)];
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.imagePath]];
    if (imgData != nil)
    {
        UIImage *thumbNail = [[UIImage alloc] initWithData:imgData];
        self.imgExpense.image = thumbNail;
    }
    //[self.view addSubView:imageView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
