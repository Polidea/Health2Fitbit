//
//  BFTask+PromiseLike.m
//  Pods
//
//  Created by Felix Dumit on 4/11/15.
//
//
//
// BFTask+PromiseLike.m
// BFTaskPromise
//
// Copyright (c) 2014,2015 Hironori Ichimiya <hiron@hironytic.com>
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Bolts/BFExecutor.h>
#import "BFTask+PromiseLike.h"


@implementation BFTask (PromiseLikeResult)

- (BFTask *)thenWithExecutor:(BFExecutor *)executor withBlock:(BFSuccessResultBlock)block {
    return [self continueWithExecutor:executor withBlock: ^id (BFTask *task) {
        if ([task isFaulted] || [task isCancelled]) {
            return task;
        }
        else {
            return block(task.result ? : nil);
        }
    }];
}

- (BFTask *)catchWithExecutor:(BFExecutor *)executor withBlock:(BFErrorResultBlock)block {
    return [self continueWithExecutor:executor withBlock: ^id (BFTask *task) {
        if (task.error) {
            return block(task.error);
        }
        else if (task.exception) {
            NSMutableDictionary *dict = [task.exception.userInfo mutableCopy] ? : [NSMutableDictionary dictionary];
            [dict setObject:task.exception.reason forKey:NSLocalizedDescriptionKey];
            return block([NSError errorWithDomain:task.exception.name code:998 userInfo:dict]);
        }
        else {
            return task;
        }
    }];
}

- (BFTask *)finallyWithExecutor:(BFExecutor *)executor withBlock:(BFPFinallyBlock)block {
    return [self continueWithExecutor:executor withBlock: ^id (BFTask *task) {
        return block(task) ? : task;
    }];
}

- (BFTask *(^)(BFSuccessResultBlock))then {
    return ^BFTask *(BFSuccessResultBlock block) {
        return [self thenWithExecutor:[BFExecutor defaultExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFErrorResultBlock))catch {
    return ^BFTask *(BFErrorResultBlock block) {
        return [self catchWithExecutor:[BFExecutor defaultExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFPFinallyBlock))finally; {
    return ^BFTask *(BFPFinallyBlock block) {
        return [self finallyWithExecutor:[BFExecutor defaultExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFExecutor *, BFSuccessResultBlock))thenOn {
    return ^BFTask *(BFExecutor *executor, BFSuccessResultBlock block) {
        return [self thenWithExecutor:executor withBlock:block];
    };
}

- (BFTask *(^)(BFExecutor *, BFErrorResultBlock))catchOn {
    return ^BFTask *(BFExecutor *executor, BFErrorResultBlock block) {
        return [self catchWithExecutor:executor withBlock:block];
    };
}

- (BFTask *(^)(BFExecutor *, BFPFinallyBlock))finallyOn {
    return ^BFTask *(BFExecutor *executor, BFPFinallyBlock block) {
        return [self finallyWithExecutor:executor withBlock:block];
    };
}

- (BFTask *(^)(BFSuccessResultBlock))thenOnMain {
    return ^BFTask *(BFSuccessResultBlock block) {
        return [self thenWithExecutor:[BFExecutor mainThreadExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFErrorResultBlock))catchOnMain {
    return ^BFTask *(BFErrorResultBlock block) {
        return [self catchWithExecutor:[BFExecutor mainThreadExecutor] withBlock:block];
    };
}

- (BFTask *(^)(BFPFinallyBlock))finallyOnMain {
    return ^BFTask *(BFPFinallyBlock block) {
        return [self finallyWithExecutor:[BFExecutor mainThreadExecutor] withBlock:block];
    };
}

@end
