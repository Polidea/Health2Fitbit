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

#import "PLContextHolder.h"

@interface PLContextHolder() 

-(void) mergeChangesIntoMainContext:(NSNotification*)notification;

@end

@implementation PLContextHolder {
    NSThread * contextThread;
    NSManagedObjectContext * context;
    PLContextHolder * parentHolder;
}

+ (id)holderAsChild:(PLContextHolder *)aParentHolder {
    return [[[PLContextHolder alloc] initAsChild:aParentHolder] autorelease];
}

+ (id)holderInContext:(NSManagedObjectContext *)aContext {
    return [[[PLContextHolder alloc] initInContext:aContext] autorelease];
}

- (id)initAsChild:(PLContextHolder *)aParentHolder {
    self = [super init];
    if(self){
        if(aParentHolder == nil){
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"a parent holder must have been provided"
                                         userInfo:nil];
        }

        parentHolder = [aParentHolder retain];
    }
    return self;
}

- (id)initInContext:(NSManagedObjectContext *)aContext {
    self = [super init];
    if(self){
        if(aContext == nil){
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"a context must have been provided"
                                         userInfo:nil];
        }

        context = [aContext retain];
        contextThread = [[NSThread currentThread] retain];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [context release];
    [contextThread release];
    [parentHolder release];
    [super dealloc];
}

-(void)mergeChangesIntoMainContext:(NSNotification *)notification{
    if(notification == nil || notification.userInfo == nil){
        NSLog(@"PLContextHolder: merge notification is empty");
    }
    [parentHolder.context performSelector:@selector(mergeChangesFromContextDidSaveNotification:)
                                 onThread:parentHolder.contextThread
                               withObject:notification
                            waitUntilDone:YES];
}

- (NSThread *)contextThread {
    return contextThread;
}

-(NSManagedObjectContext *)context{
    if(![self isContextLoaded]){
        contextThread = [[NSThread currentThread] retain];

        context = [[NSManagedObjectContext alloc] init];
        [context setUndoManager:nil];
        [context setPersistentStoreCoordinator:[parentHolder.context persistentStoreCoordinator]];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
        [nc addObserver:self
               selector:@selector(mergeChangesIntoMainContext:)
                   name:NSManagedObjectContextDidSaveNotification
                 object:context];
    }
    
    return context;
}

- (BOOL)isContextLoaded {
    return context != nil;
}

@end
