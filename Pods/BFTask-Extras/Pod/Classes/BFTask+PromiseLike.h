//
//  BFTask+PromiseLike.h
//  Pods
//
//  Created by Felix Dumit on 4/11/15.
//
//

#import "BFTask.h"
#import "BFTask-blocks.h"

@interface BFTask (PromiseLikeResult)

- (BFTask *)thenWithExecutor:(BFExecutor *)executor withBlock:(BFSuccessResultBlock)block;
- (BFTask *)catchWithExecutor:(BFExecutor *)executor withBlock:(BFErrorResultBlock)block;
- (BFTask *)finallyWithExecutor:(BFExecutor *)executor withBlock:(BFPFinallyBlock)block;


- (BFTask *(^)(BFSuccessResultBlock))then;
- (BFTask *(^)(BFErrorResultBlock))catch;
- (BFTask *(^)(BFPFinallyBlock))finally;

- (BFTask *(^)(BFExecutor *, BFSuccessResultBlock))thenOn;
- (BFTask *(^)(BFExecutor *, BFErrorResultBlock))catchOn;
- (BFTask *(^)(BFExecutor *, BFPFinallyBlock))finallyOn;

- (BFTask *(^)(BFSuccessResultBlock))thenOnMain;
- (BFTask *(^)(BFErrorResultBlock))catchOnMain;
- (BFTask *(^)(BFPFinallyBlock))finallyOnMain;

@end
