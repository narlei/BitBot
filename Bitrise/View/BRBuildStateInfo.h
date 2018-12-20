//
//  BRBuildStateInfo.h
//  Bitrise
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 Bitrise. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRBuildInfo.h"
#import "BRApp+CoreDataClass.h"
#import "BRBuild+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BRBuildState) {
    BRBuildStateUndefined = 0,
    BRBuildStateHold,
    BRBuildStateInProgress,
    BRBuildStateSuccess,
    BRBuildStateFailed,
    BRBuildStateAborted
};

@interface BRBuildStateInfo : NSObject

@property (assign, nonatomic) BRBuildState state;
@property (strong, nonatomic) NSString *statusImageName;
@property (strong, nonatomic) NSString *statusTitle;

- (instancetype)initWithBuild:(BRBuild *)build;
- (instancetype)initWithBuildInfo:(BRBuildInfo *)buildInfo;

@end

NS_ASSUME_NONNULL_END
