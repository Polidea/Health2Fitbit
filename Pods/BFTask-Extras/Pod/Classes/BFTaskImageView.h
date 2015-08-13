//
//  BFTaskImageView.h
//  Umwho
//
//  Created by Felix Dumit on 1/20/15.
//  Copyright (c) 2015 Umwho. All rights reserved.
//

#import <Bolts.h>
#import <UIKit/UIKit.h>

@interface BFTaskImageView : UIImageView

@property (strong, nonatomic) BFTask *task;

- (instancetype)initWithTask:(BFTask *)task;

@end
