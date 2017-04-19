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

#define TWICTimeStamp [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000]


static NSString *TWICConversationGetPath = @"conversation.get";
static NSString *TWICConversationGetTokenPath = @"conversation.getToken";

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
    return @{@"json-rpc":@"2.0",
             @"params":methodParameters,
             @"method":method,
             @"id":TWICTimeStamp};
}

#pragma mark - Public API
-(void)handgoutDataWithCompletionBlock:(void(^)(NSDictionary *data))completionBlock
                          failureBlock:(void (^)(NSError *error))failureBlock
{
    [self buildHeaders];
    
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:[self buildRequestParametersForMethod:TWICConversationGetPath
                                       methodParameters:@{@"id":[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]}]];
    [parameters addObject:[self buildRequestParametersForMethod:TWICConversationGetTokenPath
                                       methodParameters:@{@"id":[[TWICSettingsManager sharedInstance]settingsForKey:SettingsHangoutIdKey]}]];
    NSURLSessionDataTask *task = [self POST:[self hostName]
                                 parameters:parameters
                                  progress:nil
                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                                  {
                                      //NSString *string = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                                      //{"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
                                      if(responseObject[@"error"]){
                                          failureBlock(responseObject[@"error"][@"message"]);
                                      }else{
                                          completionBlock([responseObject firstObject]);
                                      }
                                  }
                                   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                                  {
                                      [self processError:error failureBlock:failureBlock];
                                  }];
    [task resume];

}

@end
