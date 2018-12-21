//
//  BRMainController.m
//  Bitrise
//
//  Created by Deszip on 04/07/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import "BRMainController.h"

#import "BRContainerBuilder.h"
#import "BRAppsDataSource.h"
#import "BRAccountsViewController.h"

#import "BRSyncCommand.h"
#import "BRBuildStateInfo.h"

typedef NS_ENUM(NSUInteger, BRBuildMenuItem) {
    BRBuildMenuItemUndefined = 0,
    BRBuildMenuItemRebuild,
    BRBuildMenuItemAbort,
    BRBuildMenuItemDownload,
    BRBuildMenuItemOpenBuild
};

@interface BRMainController () <NSMenuDelegate>

@property (strong, nonatomic) BRBitriseAPI *api;
@property (strong, nonatomic) BRStorage *storage;
@property (strong, nonatomic) BRSyncEngine *syncEngine;

@property (strong, nonatomic) BRAppsDataSource *dataSource;

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSMenu *buildMenu;

@end

@implementation BRMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.syncEngine = [self.dependencyContainer syncEngine];
    
    self.dataSource = [self.dependencyContainer appsDataSource];
    [self.dataSource bind:self.outlineView];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self.dataSource fetch];
}

#pragma mark - NSMenuDelegate -

- (void)menuWillOpen:(NSMenu *)menu {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if (![selectedItem isKindOfClass:[BRBuild class]]) {
        [menu cancelTrackingWithoutAnimation];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        BRBuildInfo *buildInfo = [[BRBuildInfo alloc] initWithBuild:selectedItem];
        BOOL buildInProgress = buildInfo.stateInfo.state == BRBuildStateInProgress;
        switch (menuItem.tag) {
            case BRBuildMenuItemRebuild: return !buildInProgress;
            case BRBuildMenuItemAbort: return buildInProgress;
            case BRBuildMenuItemDownload: return !buildInProgress;
            case BRBuildMenuItemOpenBuild: return YES;
            default: return NO;
        }
    }
    
    return NO;
}

#pragma mark - Actions -

- (IBAction)presentationChanged:(NSSegmentedControl *)sender {
    switch (sender.selectedSegment) {
        case 0: [self.dataSource setPresentationStyle:BRPresentationStyleList]; break;
        case 1: [self.dataSource setPresentationStyle:BRPresentationStyleTree]; break;
    }
}

- (IBAction)rebuild:(id)sender {
    //id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
}

- (IBAction)abort:(id)sender {
    //id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
}

- (IBAction)downloadLog:(id)sender {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        NSString *downloadPath = [NSString stringWithFormat:@"https://app.bitrise.io/api/build/%@/logs.json?&download=log", [(BRBuild *)selectedItem slug]];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadPath]];
    }
}

- (IBAction)openBuild:(id)sender {
    id selectedItem = [self.outlineView itemAtRow:[self.outlineView clickedRow]];
    if ([selectedItem isKindOfClass:[BRBuild class]]) {
        NSString *downloadPath = [NSString stringWithFormat:@"https://app.bitrise.io/build/%@", [(BRBuild *)selectedItem slug]];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:downloadPath]];
    }
}

@end
