//
//  BRBuildMenuController.m
//  BitBot
//
//  Created by Deszip on 25/12/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRBuildMenuController.h"

#import "BRBuild+CoreDataClass.h"
#import "BRBuildInfo.h"
#import "BRAbortCommand.h"
#import "BRRebuildCommand.h"
#import "BRSyncCommand.h"
#import "BRDownloadLogsCommand.h"
#import "BROpenBuildCommand.h"

static const NSUInteger kMenuItemsCount = 5;
typedef NS_ENUM(NSUInteger, BRBuildMenuItem) {
    BRBuildMenuItemRebuild = 0,
    BRBuildMenuItemAbort,
    BRBuildMenuItemShowLog,
    BRBuildMenuItemDownload,
    BRBuildMenuItemOpenBuild
};

@interface BRBuildMenuController ()

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRSyncEngine *syncEngine;
@property (strong, nonatomic) BRLogObserver *logObserver;
@property (strong, nonatomic) BREnvironment *environment;

@property (weak, nonatomic) NSMenu *menu;
@property (weak, nonatomic) NSOutlineView *outlineView;

@end

@implementation BRBuildMenuController

- (instancetype)initWithAPI:(BRBitriseAPI *)api
                 syncEngine:(BRSyncEngine *)syncEngine
                logObserver:(BRLogObserver *)logObserver
                environment:(BREnvironment *)environment {
    if (self = [super init]) {
        _api = api;
        _syncEngine = syncEngine;
        _logObserver = logObserver;
        _environment = environment;
    }
    
    return self;
}

- (void)bind:(NSMenu *)menu toOutline:(NSOutlineView *)outline {
    self.menu = menu;
    self.outlineView = outline;
    self.outlineView.menu = self.menu;
    
    if (self.menu.itemArray.count == kMenuItemsCount) {
        [self.menu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
            [item setTag:idx];
            [item setTarget:self];
        }];
        
        [self.menu.itemArray[BRBuildMenuItemRebuild]   setAction:@selector(rebuild)];
        [self.menu.itemArray[BRBuildMenuItemAbort]     setAction:@selector(abort)];
        [self.menu.itemArray[BRBuildMenuItemShowLog]   setAction:@selector(showLog)];
        [self.menu.itemArray[BRBuildMenuItemDownload]  setAction:@selector(downloadLog)];
        [self.menu.itemArray[BRBuildMenuItemOpenBuild] setAction:@selector(openBuild)];
    }
}

#pragma mark - Actions -

- (void)rebuild {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRRebuildCommand *command = [[BRRebuildCommand alloc] initWithAPI:self.api build:(BRBuild *)selectedItem];
        [command execute:^(BOOL result, NSError *error) {
            if (result) {
                BRSyncCommand *syncCommand = [[BRSyncCommand alloc] initSyncEngine:self.syncEngine
                                                                       logObserver:self.logObserver
                                                                       environment:self.environment];
                [syncCommand execute:nil];
            }
        }];
    }
}

- (void)abort {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRAbortCommand *command = [[BRAbortCommand alloc] initWithAPI:self.api build:(BRBuild *)selectedItem];
        [command execute:^(BOOL result, NSError *error) {
            if (result) {
                BRSyncCommand *syncCommand = [[BRSyncCommand alloc] initSyncEngine:self.syncEngine
                                                                       logObserver:self.logObserver
                                                                       environment:self.environment];
                [syncCommand execute:nil];
            }
        }];
    }
}

- (void)showLog {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRBuildInfo *buildInfo = [[BRBuildInfo alloc] initWithBuild:(BRBuild *)selectedItem];
        BR_SAFE_CALL(self.actionCallback, BRBuildMenuActionShowLog, buildInfo);
    }
}

- (void)downloadLog {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRDownloadLogsCommand *command = [[BRDownloadLogsCommand alloc] initWithBuildSlug:[(BRBuild *)selectedItem slug]];
        [command execute:nil];
    }
}

- (void)openBuild {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BROpenBuildCommand *command = [[BROpenBuildCommand alloc] initWithBuildSlug:[(BRBuild *)selectedItem slug]];
        [command execute:nil];
    }
}

#pragma mark - NSMenuItemValidation -

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRBuildInfo *buildInfo = [[BRBuildInfo alloc] initWithBuild:selectedItem];
        
        BOOL buildInProgress = buildInfo.stateInfo.state == BRBuildStateInProgress;
        BOOL buildCouldBeAborted = buildInfo.stateInfo.state == BRBuildStateInProgress ||
                                   buildInfo.stateInfo.state == BRBuildStateHold;
        BOOL buildLogAvailable = buildInfo.stateInfo.state != BRBuildStateHold && !buildInProgress;
        
        switch (menuItem.tag) {
            case BRBuildMenuItemRebuild: return !buildInProgress;
            case BRBuildMenuItemAbort: return buildCouldBeAborted;
            case BRBuildMenuItemShowLog: return buildLogAvailable;
            case BRBuildMenuItemDownload: return buildLogAvailable;
            case BRBuildMenuItemOpenBuild: return YES;
            default: return NO;
        }
    }
    
    return NO;
}

@end
