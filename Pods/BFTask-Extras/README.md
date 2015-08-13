# BFTask-Extras

[![CI Status](http://img.shields.io/travis/felix-dumit/BFTask-Extras.svg?style=flat)](https://travis-ci.org/felix-dumit/BFTask-Extras)
[![Version](https://img.shields.io/cocoapods/v/BFTask-Extras.svg?style=flat)](http://cocoapods.org/pods/BFTask-Extras)
[![License](https://img.shields.io/cocoapods/l/BFTask-Extras.svg?style=flat)](http://cocoapods.org/pods/BFTask-Extras)
[![Platform](https://img.shields.io/cocoapods/p/BFTask-Extras.svg?style=flat)](http://cocoapods.org/pods/BFTask-Extras)

A collection of useful extras to make working with BFTaks more pleasant.

##BFTaskImageView
An UIImageView subclass that allows you to set the image based on a task. When assigning the task it will execute and on completion update the image content.

```objc
BFTask* imageTask = [BFTask taskWithResult[UIImage imageNamed:@"name"];

BFTaskImageView* imageView;
imageView.task = imageTask;

```

##BFTask+Timeout
Allows you to create tasks that expire after a certain interval. Useful for network operations.
There are two ways to do this:
###BFTaskCompletionSource
Create a BFTaskCompletionSource that expires after a set interval:

```objc

BFTaskCompletionSource *tsk = [BFTaskCompletionSource taskCompletionSourceWithExpiration:1];

[self someAsyncMethodWithCompletion:^(id result){
	[tsk trySetResult:result];
}];

```
Now if you continue the task it will either complete or be cancelled after the specified timeout:

```objc 
[tsk.task continueWithBlock:^id(BFTask* task){
	if(task.cancelled){
		//timed out
	}
	else {
		// proceed as normal with error or result
	}
}];

```
###BFTask setTimeout
A faster way to do the above if you already have a *BFTask* is to use the setTimeout method then procceed with the continue block:


```objc 
BFTask* someTask;

[[someTask setTimeout:20] continueWithBlock: ^id (BFTask *task) {
        if (task.cancelled) {
            //timed out
        }
        else {
        	// proceed as normal with result or error
        }
        return nil;
}];
```

##BFTask+Result
If you are used to using blocks it can be cumbersome to typecast the result of a BFTask* everytime and can also lead to errors.
 If you need to check cancellation or exception or any other task properties then you should use the default methods, but if you are sure of the return type and want to quickly handle result and error cases this could be useful:

```objc
BFTask* someTask; // task that returns a string

[someTask continueWithResultBlock:^id(NSString* result, NSError *error) {
        //normal handling
        return nil;
 }];    
 
 //success block case:
 [someTask imageTask2 continueWithSuccessResultBlock:^id(NSString* result) {
        //normal handling
        return nil;
 }];

```
There are also methods that accept a BFExecutor parameter.	

##BFTask+Race
Creates a new task that is the result of the race between an array of tasks. Will complete when the first of the given tasks completes, faults or cancels.
Inspired by the *javascript* 
[Promise.race()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/race) feature.

```objc
BFTask* task1;
BFTask* task2;

BFTask* raceTask = [BFTask raceForTasks:@[task1, task2]];

```

## Usage

To view an example of all these *tasks* working together, view the sample application.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

##Feedback
New feature ideas, suggestions, or any general feedback is greatly appreciated.

## Requirements

## Installation

BFTask-Extras is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BFTask-Extras"
```

## Author

Felix Dumit, felix.dumit@gmail.com

## License

BFTask-Extras is available under the MIT license. See the LICENSE file for more info.
