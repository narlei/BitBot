//
//  BRCommand.h
//  BitBot
//
//  Created by Deszip on 18/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRMacro.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BRCommandResult)(BOOL result, NSError * _Nullable error);

@interface BRCommand : NSObject

- (void)execute:(_Nullable BRCommandResult)callback;

@end

NS_ASSUME_NONNULL_END
