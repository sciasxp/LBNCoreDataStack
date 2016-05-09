//
//  LBNPersistence.h
//  Pods
//
//  Created by Luciano Bastos Nunes on 10/03/16.
//
//

#import <Foundation/Foundation.h>

#define NIL_OR_OBJECT(x) (x == [NSNull null])?nil:x

typedef NS_ENUM(NSInteger, DMTagType) {
    
    DMNoType,
    DMArray,
    DMDictionary,
    DMString,
    DMNumber,
    DMDate,
    DMBlob,
    DMEntity
};

typedef id(^ DMOperation)(id);

@interface LBNPersistence : NSObject

- (void)removeObject:(id)object;

- (void)clearEntity:(NSString *)entity Save:(BOOL)save;

- (void)clearDB:(void (^)(void))block;

- (NSArray *)parseJSON:(id)json ForTags:(NSArray *)tags Error:(NSError **)error;

- (NSArray *)insertDataCollection:(NSArray *)collection CheckAttibutes:(NSArray *)attributes InEntity:(NSString *)entityName Saving:(BOOL)toSave;

- (NSArray *)fetchWithPredicate:(NSPredicate *)predicate EntityName:(NSString *)entityName SortDescriptors:(NSArray *)sortDescriptors;

- (bool)isDBEmpty;

- (void)save;

@end
