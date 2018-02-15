//
//  CreateCustomRouteViewController.h
//  Porsche
//
//  Created by Aryaman Sharda on 2/10/18.
//  Copyright © 2018 Aryaman Sharda. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CreateCustomRouteViewController : UIViewController <MKLocalSearchCompleterDelegate, UISearchBarDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDestinationsLabel;

@end
