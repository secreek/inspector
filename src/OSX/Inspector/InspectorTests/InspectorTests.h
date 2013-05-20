//
//  InspectorTests.h
//  InspectorTests
//
//  Created by Xinrong Guo on 13-5-20.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "LogGetter.h"
#import "ScriptRunner.h"

@interface InspectorTests : SenTestCase
<
ScriptRunnerDelegate,
LogGetterDelegate
>

@end
