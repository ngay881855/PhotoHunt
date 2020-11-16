//
//  AppDelegate.h
//  Photo Hunt
//
//  Created by Ngay Vong on 11/13/20.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

