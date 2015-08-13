# PLCoreDataUtils

A set of helper classes for CoreData.

## Installation

* Add the files to your project (each class can be used separately)
* (optional) If your project uses ARC, disable it for the added files (-fno-objc-arc)

## Usage

### NSManagedObjectContext+PLCoreDataUtils category

Methods for common tasks on NSManagedObjectContext:

* different types of fetch (single/multiple objects, sorting, etc)
* fetch or insert if not pressent
* entity cloning

### PLContextHolder

Simplifies the creation of NSManagedObjectContext used on different threads. 

* wraps NSManagedObjectContext instances
* child holder context merge into parent context

### PLEntityObservatory

Allows for observing of changes on registered (by entityId) CoraData entities.

---

Copyright (c) 2012 Polidea. This software is licensed under the BSD License.
