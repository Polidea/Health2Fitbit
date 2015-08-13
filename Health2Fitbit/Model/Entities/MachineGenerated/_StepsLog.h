// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StepsLog.h instead.

@import CoreData;

extern const struct StepsLogAttributes {
	__unsafe_unretained NSString *duration;
	__unsafe_unretained NSString *logId;
	__unsafe_unretained NSString *startDate;
	__unsafe_unretained NSString *startTime;
	__unsafe_unretained NSString *stepsCount;
} StepsLogAttributes;

@interface StepsLogID : NSManagedObjectID {}
@end

@interface _StepsLog : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) StepsLogID* objectID;

@property (nonatomic, strong) NSNumber* duration;

@property (atomic) int32_t durationValue;
- (int32_t)durationValue;
- (void)setDurationValue:(int32_t)value_;

//- (BOOL)validateDuration:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* logId;

@property (atomic) int64_t logIdValue;
- (int64_t)logIdValue;
- (void)setLogIdValue:(int64_t)value_;

//- (BOOL)validateLogId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* startDate;

//- (BOOL)validateStartDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* startTime;

//- (BOOL)validateStartTime:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* stepsCount;

@property (atomic) int32_t stepsCountValue;
- (int32_t)stepsCountValue;
- (void)setStepsCountValue:(int32_t)value_;

//- (BOOL)validateStepsCount:(id*)value_ error:(NSError**)error_;

@end

@interface _StepsLog (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveDuration;
- (void)setPrimitiveDuration:(NSNumber*)value;

- (int32_t)primitiveDurationValue;
- (void)setPrimitiveDurationValue:(int32_t)value_;

- (NSNumber*)primitiveLogId;
- (void)setPrimitiveLogId:(NSNumber*)value;

- (int64_t)primitiveLogIdValue;
- (void)setPrimitiveLogIdValue:(int64_t)value_;

- (NSString*)primitiveStartDate;
- (void)setPrimitiveStartDate:(NSString*)value;

- (NSString*)primitiveStartTime;
- (void)setPrimitiveStartTime:(NSString*)value;

- (NSNumber*)primitiveStepsCount;
- (void)setPrimitiveStepsCount:(NSNumber*)value;

- (int32_t)primitiveStepsCountValue;
- (void)setPrimitiveStepsCountValue:(int32_t)value_;

@end
