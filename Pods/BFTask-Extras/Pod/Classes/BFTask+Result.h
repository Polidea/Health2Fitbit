//
//  BFTask+Result.h
//  Umwho
//
//  Created by Felix Dumit on 2/14/15.
//  Copyright (c) 2015 Umwho. All rights reserved.
//

#import "BFTask-blocks.h"
#import <Bolts/Bolts.h>

@interface BFTask (Result)

- (instancetype)continueWithResultBlock:(BFResultBlock)block;

- (instancetype)continueWithExecutor:(BFExecutor *)executor
                     withResultBlock:(BFResultBlock)block;

- (instancetype)continueWithSuccessResultBlock:(BFSuccessResultBlock)block;

- (instancetype)continueWithExecutor:(BFExecutor *)executor
              withSuccessResultBlock:(BFSuccessResultBlock)block;

@end
