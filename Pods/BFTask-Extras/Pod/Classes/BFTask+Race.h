//
//  BFTask+Race.h
//  Pods
//
//  Created by Felix Dumit on 3/31/15.
//
//

#import "Bolts.h"

@interface BFTask (Race)

/**
 *  Resolves when the first of the given tasks completes
 *
 *  @param tasks an array of tasks to race
 *
 *  @return a task that resolved when the first task on the array completes
 */
+ (BFTask *)raceForTasks:(NSArray *)tasks;

@end
