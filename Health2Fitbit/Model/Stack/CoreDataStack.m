#import "CoreDataStack.h"
#import "ManagedObjectContext.h"
#import "DDLog.h"
#import "H2FLogger.h"
#import "H2FMacros.h"


@interface CoreDataStack ()
@end

@implementation CoreDataStack {
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectContext *_mainThreadContext;
    NSManagedObjectContext *_backgroundThreadContext;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
        if (!storeCoordinator) {
            _unmigratableDatabaseSchemaVersionChangeDetected = YES;
            return self;
        }

        ManagedObjectContext *mainThreadContext = [self createMainThreadContextWithPersistentStoreCoordinator:storeCoordinator];
        _mainThreadContext = mainThreadContext;

        ManagedObjectContext *backgroundContext = [self createBackgroundContextWithParentMainThreadContext:mainThreadContext];
        _backgroundThreadContext = backgroundContext;

        _unmigratableDatabaseSchemaVersionChangeDetected = NO;
    }
    return self;
}

- (ManagedObjectContext *)createBackgroundContextWithParentMainThreadContext:(NSManagedObjectContext *)mainContext {
    ManagedObjectContext *backgroundContext = [[ManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    backgroundContext.parentContext = mainContext;
    return backgroundContext;
}

- (ManagedObjectContext *)createMainThreadContextWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator {
    NSParameterAssert(coordinator);
    ManagedObjectContext *mainContext = [[ManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [mainContext setPersistentStoreCoordinator:coordinator];
    [mainContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    return mainContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSAssert(_managedObjectModel, @"Failed to load CoreData model.");
    }
    return _managedObjectModel;
}

#pragma mark - Paths ---------------------------------------------------------------------------------------------------

- (NSURL *)persistentStoreSQLiteFileURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"health2fitbitCoreData.sqlite"];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Store coordinator ---------------------------------------------------------------------------------------

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

        NSError *persistentStoreCreatingError = nil;
        [_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                  configuration:nil
                                                            URL:nil
                                                        options:nil
                                                          error:nil];
        if (persistentStoreCreatingError) {
            DDLogError(@"%s: failed to create persistent store (%@)", __PRETTY_FUNCTION__, persistentStoreCreatingError);
            return nil;
        }
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Contexts ------------------------------------------------------------------------------------------------

- (NSManagedObjectContext *)mainThreadContext {
    return _mainThreadContext;
}

- (NSManagedObjectContext *)backgroundThreadContext {
    return _backgroundThreadContext;
}

#pragma mark - Wiping-out tools ----------------------------------------------------------------------------------------

- (NSError *)removeAllPersistentStoreFiles {
    NSError *removingError = nil;
    [[NSFileManager defaultManager] removeItemAtURL:[self persistentStoreSQLiteFileURL] error:&removingError];
    if (removingError) {
        DDLogError(@"%@: couldn't remove SQL store file: %@", _sfc(self.class), removingError);
    }
    return removingError;
}

@end
