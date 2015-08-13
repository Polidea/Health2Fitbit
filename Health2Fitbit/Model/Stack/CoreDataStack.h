#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"

@interface CoreDataStack : NSObject

@property(nonatomic, readonly) BOOL unmigratableDatabaseSchemaVersionChangeDetected;

- (instancetype)init;

- (NSManagedObjectContext *)mainThreadContext;
- (NSManagedObjectContext *)backgroundThreadContext;

- (NSError *)removeAllPersistentStoreFiles;

@end
