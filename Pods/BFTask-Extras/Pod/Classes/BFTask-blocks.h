//
//  BFTask-blocks.h
//  Pods
//
//  Created by Felix Dumit on 4/11/15.
//
//

#ifndef Pods_BFTask_blocks_h
#define Pods_BFTask_blocks_h

@class BFTask;

typedef id (^BFResultBlock)(id result, NSError *error);
typedef id (^BFSuccessResultBlock)(id result);
typedef id (^BFErrorResultBlock)(NSError *error);
typedef BFTask *(^BFPFinallyBlock)(BFTask *task);


#endif
