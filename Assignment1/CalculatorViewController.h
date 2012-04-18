//
//  CalculatorViewController.h
//  Assignment1
//
//  Created by Kaneshige Koichi on 12/04/01.
//  Copyright (c) 2012年 P&W Solutions Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SplitViewBarButtonItemPresenter.h"
#import "LabelWithPadding.h"

@interface CalculatorViewController : UIViewController <UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet LabelWithPadding *display;
@property (weak, nonatomic) IBOutlet LabelWithPadding *subDisplay;

@end
