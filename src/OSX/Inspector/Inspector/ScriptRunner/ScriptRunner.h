//
//  ScriptRunner.h
//  Inspector
//
//  Created by Xinrong Guo on 13-5-5.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ScriptRunnerType_Script,
    ScriptRunnerType_Command,
}ScriptRunnerType;;

@protocol ScriptRunnerDelegate;

/** ScriptRunner 
 *  Once a SciptRunner is initialized, you should NOT set scriptURL/command again.
 *  In other words, ONE SciptRunner for ONE script/command, DO NOT reuse.
 */

@interface ScriptRunner : NSObject

@property (weak, nonatomic) id<ScriptRunnerDelegate> delegate;

@property (readonly, nonatomic) ScriptRunnerType type;

@property (readonly, nonatomic) NSURL *scriptURL;
@property (readonly, nonatomic) BOOL refreshScript;
@property (readonly, nonatomic) NSString *command;

@property (assign, nonatomic) NSTimeInterval timeInterval;

+ (void)clearCache;

- (id)initWithScriptPath:(NSString *)path refresh:(BOOL)refresh;
- (id)initWithCommand:(NSString *)command;

- (void)prepare;

- (void)runWithTimeInterval:(NSTimeInterval) timeInterval;
- (void)stop;

@end

@protocol ScriptRunnerDelegate <NSObject>

//- (void)scriptRunner:(ScriptRunner *)runner didFinishRunningScript:(NSURL *)scriptPath;
- (void)scriptRunner:(ScriptRunner *)runner didFailDownloadingScriptWithError:(NSError *)error;

@optional

- (void)scriptRunner:(ScriptRunner *)runner didGetScriptContent:(NSString *)content;
- (void)scriptRunner:(ScriptRunner *)runner didFinishExecutionWithStatusCode:(int)statusCode result:(NSString *)result;

@end
