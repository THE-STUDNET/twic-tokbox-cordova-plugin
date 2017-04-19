//
//  TWICPlatformClient.m
//  TWICDemoApp
//
//  Created by Emmanuel Castellani on 18/04/2017.
//
//

#import "TWICPlatformClient.h"
#import "TWICConstants.h"
#import "TWICSettingsManager.h"

#define TWICTimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]


static NSString *TWICConversationGetPath = @"conversation.get";
static NSString *TWICConversationGetTokenPath = @"conversation.getToken";
static NSString *TWICUserGetPath = @"user.get";

@implementation TWICPlatformClient

+ (TWICPlatformClient *)sharedInstance
{
    static TWICPlatformClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@""];
        _sharedClient = [[TWICPlatformClient alloc] initWithBaseURL:baseURL];
        
        //queue count
        _sharedClient.operationQueue.maxConcurrentOperationCount = 3;
        
        //allow invalid certificates :)
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.validatesDomainName = NO;
        securityPolicy.allowInvalidCertificates = YES;
        _sharedClient.securityPolicy = securityPolicy;
        
        //response serializer
        AFCompoundResponseSerializer *compoundSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[AFJSONResponseSerializer serializer], [AFImageResponseSerializer serializer]]];
        _sharedClient.responseSerializer = compoundSerializer;
        
        //request serializer
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sharedClient.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    });
    return _sharedClient;
}

#pragma mark - Private API
-(NSString *)localeString
{
    if([[[NSLocale currentLocale] localeIdentifier] length] > 2)
    {
        NSString *locale = [[[NSLocale currentLocale] localeIdentifier] substringToIndex:2];
        if([locale isEqualToString:@"fr"])
            return locale;
    }
    return @"en";
}

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message
{
    return [NSError errorWithDomain:ERROR_DOMAIN code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}

-(void)processError:(NSError*)error failureBlock:(void(^)(NSError *error))failureBlock
{
    if(error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]){
        NSData *responseBinaryData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        //try json decoding
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseBinaryData options:0 error:nil];
        if(responseData){
            NSDictionary *errorData = responseData[@"err"];
            if(failureBlock)
                failureBlock([self errorWithCode:(int)errorData[@"code"] message:errorData[@"message"]]);
            return;
        }
    }
    if(failureBlock)
        failureBlock(error);
}

-(void)processResponse:(id)responseObject failureBlock:(void(^)(NSError *error))failureBlock{
    
}

-(void)buildHeaders
{
    //authorization
    NSDictionary *settingsAPI = [[TWICSettingsManager sharedInstance]settingsForKey:SettingsApiKey];
    [self.requestSerializer setValue:settingsAPI[SettingsAuthTokenKey]
                  forHTTPHeaderField:settingsAPI[SettingsAuthorizationHeaderKey]];
}

-(NSString *)hostName
{
    NSDictionary *settingsAPI = [[TWICSettingsManager sharedInstance]settingsForKey:SettingsApiKey];
    NSString *hostName = [NSString stringWithFormat:@"%@://%@/%@",settingsAPI[SettingsProtocolKey],settingsAPI[SettingsDomainKey],settingsAPI[SettingsPathsKey][@"jsonrpc"]];
    return hostName;
}

-(NSDictionary *)buildRequestParametersForMethod:(NSString *)method methodParameters:(NSDictionary *)methodParameters{
    
    NSDictionary *parameters = @{@"json-rpc":@"2.0",
             @"params":methodParameters,
             @"method":method,
             @"id":TWICTimeStamp};
    return parameters;
}

-(void)jsonRequestForMethodName:(NSString *)methodName
               methodParameters:(NSDictionary *)methodParameters
                completionBlock:(void(^)(NSDictionary *data))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock
{
    [self buildHeaders];
    
    NSURLSessionDataTask *task = [self POST:[self hostName]
                                 parameters:[self buildRequestParametersForMethod:methodName methodParameters:methodParameters]
                                   progress:nil
                                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                                  {
                                      if(responseObject[@"error"]){
                                          failureBlock(responseObject[@"error"][@"message"]);
                                      }
                                      else{
                                          completionBlock(responseObject[@"result"]);
                                      }
                                  }
                                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                                  {
                                      [self processError:error failureBlock:failureBlock];
                                  }];
    [task resume];
}

#pragma mark - Public API
-(void)hangoutDataWithCompletionBlock:(void(^)(NSDictionary *data))completionBlock
                          failureBlock:(void (^)(NSError *error))failureBlock
{
    return [self jsonRequestForMethodName:TWICConversationGetPath
                         methodParameters:@{@"id":[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]}
                          completionBlock:completionBlock
                             failureBlock:failureBlock];
}

-(void)tokboxDataWithCompletionBlock:(void(^)(NSDictionary *data))completionBlock
                        failureBlock:(void (^)(NSError *error))failureBlock
{
    return [self jsonRequestForMethodName:TWICConversationGetTokenPath
                         methodParameters:@{@"id":[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]}
                          completionBlock:completionBlock
                             failureBlock:failureBlock];
}

-(void)detailForUsers:(NSArray*)userIds
      completionBlock:(void(^)(NSArray *data))completionBlock
         failureBlock:(void (^)(NSError *error))failureBlock
{
    return [self jsonRequestForMethodName:TWICUserGetPath
                         methodParameters:@{@"id":userIds}
                         completionBlock:^(NSDictionary *data)
    {
        completionBlock([data allValues]);
    }
                             failureBlock:failureBlock];
}

@end
