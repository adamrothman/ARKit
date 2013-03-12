//
//  NSManagedObjectContext+ARKit.h
//  ARKit
//
//  Created by Adam Rothman on 2/10/13.
//
//  Saving a context is just way too complicated.
//

#import "NSManagedObjectContext+ARKit.h"

@implementation NSManagedObjectContext (ARKit)

- (void)saveWithSuccess:(void(^)())block {
  if (!self.hasChanges) {
    if (block) block();
    return;
  }
  NSError *error = nil;
  if ([self save:&error]) {
    if (block) block();
  } else {
    NSDictionary *userInfo = @{NSUnderlyingErrorKey : error};
    NSString *reason = [NSString stringWithFormat:@"Error saving context %@", self];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:userInfo];
  }
}

@end
