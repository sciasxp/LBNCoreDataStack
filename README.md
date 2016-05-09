# LBNCoreDataStack

[![CI Status](http://img.shields.io/travis/Luciano Bastos Nunes/LBNCoreDataStack.svg?style=flat)](https://travis-ci.org/Luciano Bastos Nunes/LBNCoreDataStack)
[![Version](https://img.shields.io/cocoapods/v/LBNCoreDataStack.svg?style=flat)](http://cocoapods.org/pods/LBNCoreDataStack)
[![License](https://img.shields.io/cocoapods/l/LBNCoreDataStack.svg?style=flat)](http://cocoapods.org/pods/LBNCoreDataStack)
[![Platform](https://img.shields.io/cocoapods/p/LBNCoreDataStack.svg?style=flat)](http://cocoapods.org/pods/LBNCoreDataStack)

## Installation

LBNCoreDataStack is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "LBNCoreDataStack"
```

## Requirements

iOS 7.1 or greater.

## First Things

You can remove everything related to CoreData that were put in your AppDelegate.m and AppDelegate.h.

In AppDelegate.m it will be after the line:
```objective-c
#pragma mark - Core Data stack
```
and this line:
```objective-c
#pragma mark - Core Data Saving support
```

From AppDelegate.h you remove the lines: 
```objective-c
#import <CoreData/CoreData.h>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
```
Those lines of code will be now handled by LBNCoreDataStack you don't need to be concerned about then anymore.

## Usage

### LBNCoreDataStack

To use LBNCoreDataStack you have to include it in the class file you will be using it.

```objective-c
#import "LBNCoreDataStack.h"
```

Then you will be needing to cofigure your CoreDataStack with the name of your Core Data object. It is usualy the name of your project so if your project is named MyBigProject you can use:

```objective-c
[[LBNCoreDataStack defaultStack] setResourceName:@"MyBigProject"];
```

It is recommended to do this in your AppDelegate class.

OK, thats pretty much all you have to do with LBNCoreDataStack to start using it.

### LBNPersistence

To facilitate its usage you can use the CoreData with the methods from *LBNCoreDataStack* as you would from *AppDelegate* before, or you can use *LBNPersistence* class with its facilitators methods that include easy ways to include, exclude and modify your Core Data Entity content.

To use it, first import the header,
```objective-c
#import "LBNPersistence.h"
```
instantiate the class,
```objective-c
LBNPersistence = [[LBNPersistence alloc] init];
```
and use those methods:
#### removeObject
```objective-c
- (void)removeObject:(id)object
```
##### Summary
This method will delete an object of your Entity and will save your context to disk.
##### Parameter
- **object**: Its the entity object you want to remove from your Entity.

#### clearEntity
```objective-c
- (void)clearEntity:(NSString *)entity Save:(BOOL)save
```
##### Summary
This method will delete all objects from a given Entity.
##### Parameter
- **entity**: The Entity name you want to clear.
- **save**: Boolean to define if after the objects of your entity are deleted the context will be saved on disk. If the conext is not saved yours changes will have no effect next time you enter your app. This has the same effect as call save method afeter clearEntity.

#### clearDB
```objective-c
- (void)clearDB:(void (^)(void))block
```
##### Summary
Call this method to clear all Enties in your CoreData.
##### Parameter
- **block**: It is a callback for when the cleanning is finished.

#### parseJSON
```objective-c
- (NSArray *)parseJSON:(id)json ForTags:(NSArray *)tags Error:(NSError **)error
```
##### Summary
This method will parse a given JSON formatted as a *NSArray* of *NSDictionary*. It get the json and parse in acordanse to the tags rules and return the *NSArray* formatted to be included in an Entity.
##### Parameter
- **json**: *NSArray* containing *NSDictionary* formatted content. For future versions it will be able to also receive a single *NSDictionary* instead of a *NSArray* if necessary.
- **tags**: An array will rules that will help to parse the JSON to a format that will be able to be passed to insertDataCollection Method.
- **error**:Reference to a *NSError* object that after execution will have an *NSError* error or *nil* as value.
##### Example: 
This is content for **tags**:
```objective-c
@{@"name":@"title",
@"type":[NSNumber numberWithUnsignedInteger:DMString],
@"operation":self.plainText,
@"toName":@"title"}
```
- **name**: key name in the json
- **type**: type of the content you want to be in parsed array. This key must be complaint to *DMTagType*
- **operation**: This is a optional key. It is a block to receive your data and do any kind of processing you want to it and then return it
- **toName**: will be the name you want your key to have after the data is parsed. To be used with insert on CoreData is recommended to have the same name as the attribute in your Entity.

#### insertDataCollection
```objective-c
- (NSArray *)insertDataCollection:(NSArray *)collection CheckAttibutes:(NSArray *)attributes InEntity:(NSString *)entityName Saving:(BOOL)toSave
```
##### Summary
This will get a array of dictionary formatted with your keys having the same name as your Entity attibute and checking for the attributes to know if you have the same object already.
##### Parameter
- **collection**: A *NSArray* of *NSDictionary* containing the data to be inserted in your CoreData Entity. This *NSDictiorary* must have its keys with the same name as the *attibutes* and *relationship* in your Entity. You can omit a key if the attribute in your entity is optional.
- **attributes**: This can be an *NSArray* with the names of attributes you want to check for the existence of same value. If the values you are trying to include in an Entity already exists the method will update the existing object instead of creating a new one.
- **inEntity**: The Entity name you want to include your collection.
- **toSave**: A boolean that will define if after including the data on CoreData you want to save on disk or leave only on memory. Same as commit on Data Base.
##### Return
Returns an *NSArray* containing Entity instances to your inserted collection.

#### fetchWithPredicate
```objective-c
- (NSArray *)fetchWithPredicate:(NSPredicate *)predicate EntityName:(NSString *)entityName SortDescriptors:(NSArray *)sortDescriptors;
```
##### Summary
This method is used to get an instance of desired entity. You can use predicate and sortDescriptor to filter and sort your fetch, or pass nil to those parameters to fetch all objects in an Entity.
##### Parameter
- **predicate**: Predicate to filter your Entity fetch.
- **entityName**: Name the Entity you are trying to fetch data.
- **sortDescriptors**: You can pass an *NSArray* of *NSSortDescriptors to arrange your fetched data as you want.
##### Return
Returns an *NSArray* containing the fetched Entity instances or nil if no instance were found.

#### isDBEmpty
```objective-c
- (bool)isDBEmpty;
```
##### Summary
Check all CoreData Entities for object.
##### Return
If there is no object in DB return YES else return NO.

#### save
```objective-c
- (void)save;
```
##### Summary
Same as commit on Data Base. It will save on disk all changes you made on memory.

## Author

Luciano Bastos Nunes, sciasxp@gmail.com

## License

LBNCoreDataStack is available under the MIT license. See the LICENSE file for more info.
