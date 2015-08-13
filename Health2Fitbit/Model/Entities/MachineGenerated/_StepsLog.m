// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StepsLog.m instead.

#import "_StepsLog.h"

const struct StepsLogAttributes StepsLogAttributes = {
	.duration = @"duration",
	.logId = @"logId",
	.startDate = @"startDate",
	.startTime = @"startTime",
	.stepsCount = @"stepsCount",
};

@implementation StepsLogID
@end

@implementation _StepsLog

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StepsLog" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StepsLog";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StepsLog" inManagedObjectContext:moc_];
}

- (StepsLogID*)objectID {
	return (StepsLogID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"durationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"duration"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"logIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"logId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"stepsCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"stepsCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic duration;

- (int32_t)durationValue {
	NSNumber *result = [self duration];
	return [result intValue];
}

- (void)setDurationValue:(int32_t)value_ {
	[self setDuration:@(value_)];
}

- (int32_t)primitiveDurationValue {
	NSNumber *result = [self primitiveDuration];
	return [result intValue];
}

- (void)setPrimitiveDurationValue:(int32_t)value_ {
	[self setPrimitiveDuration:@(value_)];
}

@dynamic logId;

- (int64_t)logIdValue {
	NSNumber *result = [self logId];
	return [result longLongValue];
}

- (void)setLogIdValue:(int64_t)value_ {
	[self setLogId:@(value_)];
}

- (int64_t)primitiveLogIdValue {
	NSNumber *result = [self primitiveLogId];
	return [result longLongValue];
}

- (void)setPrimitiveLogIdValue:(int64_t)value_ {
	[self setPrimitiveLogId:@(value_)];
}

@dynamic startDate;

@dynamic startTime;

@dynamic stepsCount;

- (int32_t)stepsCountValue {
	NSNumber *result = [self stepsCount];
	return [result intValue];
}

- (void)setStepsCountValue:(int32_t)value_ {
	[self setStepsCount:@(value_)];
}

- (int32_t)primitiveStepsCountValue {
	NSNumber *result = [self primitiveStepsCount];
	return [result intValue];
}

- (void)setPrimitiveStepsCountValue:(int32_t)value_ {
	[self setPrimitiveStepsCount:@(value_)];
}

@end

