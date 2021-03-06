//
//  BRAccountsMenuController.h
//  BitBot
//
//  Created by Deszip on 29/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "BRBitriseAPI.h"
#import "BRStorage.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRAppMenuAction) {
    BRAppMenuActionUndefined = 0,
    BRAppMenuActionAddKey,
    BRAppMenuActionRemoveAccount
};

@interface BRAccountsMenuController : NSObject

@property (copy, nonatomic) void (^actionCallback)(BRAppMenuAction action, NSString *slug);

- (instancetype)initWithAPI:(BRBitriseAPI *)api storage:(BRStorage *)storage;
- (void)bind:(NSMenu *)menu toOutline:(NSOutlineView *)outline;

@end

NS_ASSUME_NONNULL_END
