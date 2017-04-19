//
//  TWICPlatformClient.h
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 18/04/2017.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface TWICPlatformClient : AFHTTPSessionManager
+ (TWICPlatformClient *)sharedInstance;

/*Error convenience method*/
- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message;

-(void)handgoutDataWithCompletionBlock:(void(^)(NSDictionary *data))completionBlock
                          failureBlock:(void (^)(NSError *error))failureBlock;

@end
