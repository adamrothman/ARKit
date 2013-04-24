//
//  NSManagedObjectContext+ARKit.h
//  ARKit
//
//  Created by Adam Rothman on 2/10/13.
//
//  Saving a context is just way too complicated.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (ARKit)

// Save this context with optional completion block
- (void)saveWithSuccess:(void(^)())block;

@end
