//
//  BRBuildStateInfo.m
//  BitBot
//
//  Created by Deszip on 05/08/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRBuildStateInfo.h"

@implementation BRBuildStateInfo

- (instancetype)initWithBuildStatus:(NSUInteger)buildStatus holdStatus:(BOOL)holdStatus waiting:(BOOL)isWaiting {
    if (self = [super init]) {
        [self applyStatus:buildStatus isOnHold:holdStatus waiting:isWaiting];
    }
    
    return self;
}

- (void)applyStatus:(NSUInteger)buildStatus isOnHold:(BOOL)isOnHold waiting:(BOOL)isWaiting {
    switch (buildStatus) {
        case 0:
            if (isOnHold) {
                _statusImageName = @"hold-status";
                _statusTitle = @"On hold";
                _state = BRBuildStateHold;
            } else {
                _statusImageName = @"progress-status";
                if (isWaiting) {
                    _statusTitle = @"Waiting for worker...";
                    _state = BRBuildStateWaitingForWorker;
                } else {
                    _statusTitle = @"In progress...";
                    _state = BRBuildStateInProgress;
                }
            }
            break;
            
        case 1:
            _statusImageName = @"success-status";
            _statusTitle = @"Success";
            _state = BRBuildStateSuccess;
            break;
            
        case 2:
            _statusImageName = @"failed-status";
            _statusTitle = @"Failed";
            _state = BRBuildStateFailed;
            break;
            
        case 3:
        case 4:
            _statusImageName = @"abort-status";
            _statusTitle = @"Aborted";
            _state = BRBuildStateAborted;
            break;
    }
}

@end
