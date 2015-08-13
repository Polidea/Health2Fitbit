//
//  BFTaskImageView.m
//  Umwho
//
//  Created by Felix Dumit on 1/20/15.
//  Copyright (c) 2015 Umwho. All rights reserved.
//

#import "BFTaskImageView.h"

@implementation BFTaskImageView

- (instancetype)initWithTask:(BFTask *)task {
    if (self = [super init]) {
        self.task = task;
    }
    return self;
}

- (BFTask *)task {
    return [BFTask taskWithResult:self.image];
}

- (void)setTask:(BFTask *)task {
    [task continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock: ^id (BFTask *imageTask) {
        UIImage *img = nil;
        if ([imageTask.result isKindOfClass:[UIImage class]]) {
            img = (UIImage *)imageTask.result;
        }
        else if ([imageTask.result isKindOfClass:[NSData class]]) {
            img = [UIImage imageWithData:imageTask.result];
        }
        if (img) {
            self.image = img;
        }
        return img;
    }];
}

@end
