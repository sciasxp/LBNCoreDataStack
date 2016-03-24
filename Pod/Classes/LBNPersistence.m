//
//  LBNPersistence.m
//  Pods
//
//  Created by Luciano Bastos Nunes on 10/03/16.
//
//

#import "LBNPersistence.h"

#import "LBNCoreDataStack.h"

@implementation LBNPersistence

- (id)parseContent:(id)content ForTag:(NSDictionary *)tag Error:(NSError **)error {
    
    id object = NIL_OR_OBJECT(content);
    if (object) {
        
        switch ([tag[@"type"] unsignedIntegerValue]) {
                
            case DMArray:
                
                break;
            case DMDictionary:
                
                break;
            case DMString:
            {
                if (![object isKindOfClass:[NSString class]]) {
                    
                    if ([object isKindOfClass:[NSArray class]]) {
                        
                        object = [object firstObject];
                        
                    } else {
                        
                        return nil;
                    }
                }
                
                DMOperation op = tag[@"operation"];
                if (op) {
                    
                    object = op(object);
                }
                
                return object;
            }
                break;
            case DMNumber:
            {
                DMOperation op = tag[@"operation"];
                if (op) {
                    
                    object = op(object);
                }
                
                return object;
            }
                break;
            case DMDate:
            {
                DMOperation op = tag[@"operation"];
                if (op) {
                    
                    object = op(object);
                }
                
                return object;
            }
                break;
            case DMBlob:
                
                break;
            case DMEntity:
            {
                DMOperation op = tag[@"operation"];
                if (op) {
                    
                    object = op(object);
                }
                NSError *error = nil;
                NSArray *tags = tag[@"tags"];
                NSArray *entities = [self parseJSON:object ForTags:tags Error:&error];
                
                return entities;
            }
                break;
                
            default:
                break;
        }
        
    }
    
    return nil;
}

- (NSArray *)parseJSON:(id)json ForTags:(NSArray *)tags Error:(NSError **)error {
    
    if ([json isKindOfClass:[NSArray class]]) {
        
        __block NSMutableArray *collection = [[NSMutableArray alloc] init];
        
        [json enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *jsonItem = obj;
            
            __block NSMutableDictionary *parsedItem = [[NSMutableDictionary alloc] init];
            
            [tags enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSDictionary *tag = obj;
                
                id content = [jsonItem valueForKeyPath:tag[@"name"]];
                
                NSError *error = nil;
                id parsedContent = [self parseContent:content ForTag:tag Error:&error];
                if (parsedContent) {
                    
                    [parsedItem setObject:parsedContent forKey:tag[@"toName"]];
                }
            }];
            
            [collection addObject:parsedItem];
        }];
        
        return collection.count?collection:nil;
        
    } else {
        
        NSString *message = [NSString stringWithFormat:@"Dados estão em padrão inesperado: %@", [json class]];
        
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:message  forKey:NSLocalizedDescriptionKey];
        NSError *localError = [NSError errorWithDomain:@"myDomain" code:100 userInfo:errorDetail];
        
        *error = localError;
    }
    
    return nil;
}

- (void)removeObject:(id)object {
    
    NSManagedObjectContext *context = [[LBNCoreDataStack defaultStack] managedObjectContext];
    [context deleteObject:object];
}

- (void)clearEntity:(NSString *)entity {
    
    NSManagedObjectContext *context = [[LBNCoreDataStack defaultStack] managedObjectContext];
    
    NSArray *fetchedObjects = [self fetchWithPredicate:nil EntityName:entity SortDescriptors:nil];
    
    [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [context deleteObject:obj];
    }];
}

- (void)clearDB:(void (^)(void))block {
    
    NSDictionary *entities = [[LBNCoreDataStack defaultStack] managedObjectModel].entitiesByName;
    
    [[entities allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *key = obj;
        
        [self clearEntity:key];
    }];
    
    if (block) {
        
        block();
    }
}

- (NSArray *)insertDataCollection:(NSArray *)collection CheckAttibutes:(NSArray *)attributes InEntity:(NSString *)entityName Saving:(BOOL)toSave {
    
    NSManagedObjectContext *context = [[LBNCoreDataStack defaultStack] managedObjectContext];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [collection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        id entity = nil;
        id fetchedObject = nil;
        
        if (attributes) {
            
            __block NSMutableArray *valuesArray = [[NSMutableArray alloc] init];
            [attributes enumerateObjectsUsingBlock:^(id  _Nonnull attribute, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (obj[attribute]) {
                    
                    [valuesArray addObject:obj[attribute]];
                }
            }];
            
            fetchedObject = [self fetchForAttributes:attributes withValues:valuesArray ForEntityName:entityName];
        }
        
        if (fetchedObject) {
            
            entity = fetchedObject;
            
        } else {
            
            entity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        }
        
        if (entity) {
            
            for (NSString *key in [(NSDictionary *)obj keyEnumerator]) {
                
                if ([[(NSDictionary *)obj valueForKey:key] isKindOfClass:[NSArray class]]) {
                    
                    NSArray *dataCollection = [self insertDataCollection:[(NSDictionary *)obj valueForKey:key] CheckAttibutes:nil InEntity:key Saving:YES];
                    //[self insertDataCollection:[(NSDictionary *)obj valueForKey:key] InEntity:key Saving:NO];
                    [entity setValue:[NSSet setWithArray:dataCollection] forKey:key];
                    
                } else {
                    
                    id object = NIL_OR_OBJECT([(NSDictionary *)obj objectForKey:key]);
                    if (object == nil) {
                        
                        object = @"";
                    }
                    
                    [entity setValue:object forKeyPath:key];
                }
            }
            
            [result addObject:entity];

        } else {
            
            NSLog(@"NO ENTITY");
        }
    }];
    
    if (toSave) {
        
        NSError *error = nil;
        
        if (![context save:&error]) {
            
            NSLog(@"Error saving context: %@", error.localizedDescription);
            return nil;
        }
    }
    
    return result;
}

- (id)fetchForAttributes:(NSArray *)attributes withValues:(NSArray *)values ForEntityName:(NSString *)entityName
{
    __block NSMutableArray *compoundPredicateArray = [[NSMutableArray alloc] init];
    [attributes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", obj, values[idx]];
        [compoundPredicateArray addObject:predicate];
    }];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:
                              compoundPredicateArray ];
    NSArray *fetchedObjects = [self fetchWithPredicate:predicate EntityName:entityName SortDescriptors:nil];
    
    return [fetchedObjects firstObject];
}

/*
- (id)fetchForAttribute:(NSString *)attribute withValue:(NSString *)value ForEntityName:(NSString *)entityName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attribute, value];
    NSArray *fetchedObjects = [self fetchWithPredicate:predicate EntityName:entityName SortDescriptors:nil];
    
    return [fetchedObjects firstObject];
}
*/

- (NSArray *)fetchWithPredicate:(NSPredicate *)predicate EntityName:(NSString *)entityName SortDescriptors:(NSArray *)sortDescriptors {
    
    NSManagedObjectContext *context = [[LBNCoreDataStack defaultStack] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = sortDescriptors;
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    
    return fetchedObjects;
}

- (bool)isDBEmpty {
    
    NSDictionary *entities = [[LBNCoreDataStack defaultStack] managedObjectModel].entitiesByName;
    NSManagedObjectContext *context = [[LBNCoreDataStack defaultStack] managedObjectContext];
    
    __block BOOL isEmpty = YES;
    [[entities allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *key = obj;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:key
                                                  inManagedObjectContext:context];
        
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if ([fetchedObjects count]) {
            
            isEmpty = NO;
            *stop = YES;
        }
    }];
    
    return isEmpty;
}

- (void) save {
    
    NSManagedObjectContext *context = [[LBNCoreDataStack defaultStack] managedObjectContext];
    NSError *error = nil;
    
    if (![context save:&error]) {
        
        NSLog(@"Error saving context: %@", error.localizedDescription);
    }
}

@end
