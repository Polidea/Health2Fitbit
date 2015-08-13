#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Bolts/Bolts.h>

@interface NSManagedObjectContext (Helpers)
- (BFTask *)h2f_performBlockAndSave:(NSError *(^)(void))block;

- (void)h2f_performBlockAndWaitAndSave:(NSError *(^)(void))block;

- (BFTask *)h2f_performBlock:(NSError *(^)(void))block;

- (BOOL)propagatedSave:(NSError **)error;
@end