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


#import "PLEntityObservatory.h"

@interface PLEntityObservatory ()

-(void)managedObjectContextObjectsChanged:(NSNotification *)notification;

@end

@implementation PLEntityObservatory {
    NSMutableDictionary * observedEntitiesIds;
}

- (id)initInManagedObjectContext:(NSManagedObjectContext*)context {
    self = [super init];
    if (self) {
        observedEntitiesIds = [[NSMutableDictionary alloc] init];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(managedObjectContextObjectsChanged:)
                   name:NSManagedObjectContextObjectsDidChangeNotification
                 object:context];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [observedEntitiesIds release];
    [super dealloc];
}

-(void)managedObjectContextObjectsChanged:(NSNotification *)notification{
    NSSet * changedObjects = [notification.userInfo objectForKey:@"refreshed"];

    //fast way out if we don't listen for anything
    if ([observedEntitiesIds count] == 0){
        return;
    }

    for (NSManagedObject * entity in changedObjects) {
        NSManagedObjectID * changedId = entity.objectID;

        NSSet * observers = [observedEntitiesIds objectForKey:changedId];
        if(observers == nil){
            continue;
        }

        for (NSValue * observer in observers) {
            [[observer nonretainedObjectValue] entityWithIdDidChange:changedId];
        }
    }
}

-(void) addEntityObserver:(id<PLEntityObserver>)observer onId:(NSManagedObjectID*)entityId{
    NSMutableSet * observers = [observedEntitiesIds objectForKey:entityId];
    if(observers == nil){
        observers = [[NSMutableSet alloc] init];
        [observedEntitiesIds setObject:observers forKey:entityId];
        [observers release];
    }

    [observers addObject:[NSValue valueWithNonretainedObject:observer]];
}

-(void) removeEntityObserver:(id<PLEntityObserver>) observer{
    NSMutableSet * observedIds = [NSMutableSet set];
    NSValue * idValue = [NSValue valueWithNonretainedObject:observer];

    for (NSManagedObjectID * entityId in [observedEntitiesIds keyEnumerator]) {
        NSMutableSet * observers = [observedEntitiesIds objectForKey:entityId];
        if(observers == nil){
            continue;
        }

        if([observers containsObject:idValue]){
            [observedIds addObject:entityId];
        }
    }

    for(NSManagedObjectID * entityId in observedIds){
        [self removeEntityObserver:observer onId:entityId];
    }
}

-(void) removeEntityObserver:(id<PLEntityObserver>) observer onId:(NSManagedObjectID*)entityId{
    NSMutableSet * observers = [observedEntitiesIds objectForKey:entityId];
    if(observers == nil){
        return;
    }

    NSValue * idValue = [NSValue valueWithNonretainedObject:observer];
    if([observers containsObject:idValue]){
        [observers removeObject:idValue];
    }

    if([observers count] == 0){
        [observedEntitiesIds removeObjectForKey:entityId];
    }
}

@end
