/*
 Copyright (c) 2012, Antoni Kędracki, Polidea
 All rights reserved.

 mailto: akedracki@gmail.com

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the Polidea nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY ANTONI KĘDRACKI, POLIDEA ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL ANTONI KĘDRACKI, POLIDEA BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+PLCoreDataUtils.h"

@implementation NSManagedObjectContext (PLCoreDataUtils)

-(NSManagedObject*)fetchObjectWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate{
    return [self fetchObjectWithEntityName:entityName predicate:predicate significantValue:nil greatest:YES];
}

-(NSArray*)fetchObjectsWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate{
    return [self fetchObjectsWithEntityName:entityName predicate:predicate orderKey:nil];
}

-(NSArray*)fetchObjectsWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate orderKey:(NSString *)orderKey{
    return [self fetchObjectsWithEntityName:entityName predicate:predicate orderKey:orderKey orderDirection:YES];
}

-(NSArray*)fetchObjectsWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate orderKey:(NSString *)orderKey orderDirection:(BOOL)ascending{
    NSEntityDescription * description = [self entityDescriptionForName:entityName];
    NSFetchRequest * fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:description];

    if(predicate != nil){
        [fetchRequest setPredicate:predicate];
    }

    if(orderKey != nil){
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:[[[NSSortDescriptor alloc] initWithKey:orderKey ascending:ascending] autorelease], nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
    }

    NSError * error = NULL;
    NSArray * results = [self executeFetchRequest:fetchRequest error:&error];
    if(error != nil){
        NSLog(@"error fetching: %@", [error localizedDescription]);
        return nil;
    } else {
        return results;
    }
}

-(NSManagedObject*)fetchObjectWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate significantValue:(NSString *)valueKey greatest:(BOOL)greatest{
    NSEntityDescription * description = [self entityDescriptionForName:entityName];
    NSFetchRequest * fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:description];

    if(predicate != nil){
        [fetchRequest setPredicate:predicate];
    }

    if(valueKey != nil){
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:[[[NSSortDescriptor alloc] initWithKey:valueKey ascending:!greatest] autorelease], nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptors release];
    }

    [fetchRequest setFetchLimit:1];

    NSError * error = NULL;
    NSArray * results = [self executeFetchRequest:fetchRequest error:&error];
    if(error != nil){
        NSLog(@"error fetching: %@", [error localizedDescription]);
        return nil;
    } else {
        return [results count] > 0 ? [results objectAtIndex:0] : nil;
    }
}

-(NSManagedObject*) fetchCopyOfObject:(NSManagedObject*)object{
    if(object == nil){
        return nil;
    }
    return [self existingObjectWithID:[object objectID] error:NULL];
}

-(NSManagedObject*) insertNewEntityWithName:(NSString*)entityName{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
}

-(NSManagedObject*)insertOrFetchEntityWithName:(NSString *)entityName predicate:(NSPredicate *)predicate {
    NSFetchRequest * fetchRequest = [[[NSFetchRequest alloc] initWithEntityName:entityName] autorelease];
    [fetchRequest setPredicate:predicate];

    NSError * error = NULL;
    NSArray * results = [self executeFetchRequest:fetchRequest error:&error];
    if(results != nil){
        if([results count] >= 1){
            return [results objectAtIndex:0];
        }
    }

    return [self insertNewEntityWithName:entityName];
}

-(NSInteger)removeEntitiesWithName:(NSString *)entityName predicate:(NSPredicate *)predicate{
    NSEntityDescription * description = [self entityDescriptionForName:entityName];
    NSFetchRequest * fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:description];
    [fetchRequest setPredicate:predicate];

    NSError * error = NULL;
    NSArray * results = [self executeFetchRequest:fetchRequest error:&error];
    if(error != NULL){
        NSLog(@"error removing: %@", [error localizedDescription]);
    }
    if(results == nil){
        return 0;
    }

    for(NSManagedObject* object in results){
        [self deleteObject:object];
    }
    return [results count];
}

-(NSInteger) removeEntities:(NSSet*)set{
    for(NSManagedObject * obj in [NSSet setWithSet:set]){
        [self deleteObject:obj];
    }
    return [set count];
}

-(BOOL) saveChangesErrorDescription:(NSString**)description{
    @try {
        NSError *error = nil;
        if (![self save:&error]) {
            if(description != nil){
                (*description) = ([[[error localizedDescription] copy] autorelease]);
            }
            NSLog(@"save operation failed: %@", [error localizedDescription]);
            return NO;
        }
    } @catch (NSException *exception){
        NSLog(@"save operation failed: %@", [exception description]);
        return NO;
    }
    return YES;
}

-(NSEntityDescription*) entityDescriptionForName:(NSString*)entityName{
    return [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
}

@end