//
//  LBNCoreDataStack.h
//
//  Created by Luciano Bastos Nunes on 21/07/15.
//  Copyright © 2015 Tap4Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface LBNCoreDataStack : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSString *resourceName;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (instancetype)defaultStack;

@end
