//
//  CustomAFNetWorking.m


#import "CustomAFNetWorking.h"
#import "AFNetworking.h"


@implementation CustomAFNetWorking

-(id)initWithPost:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter
{
    self = [super init];
    
    if (self)
    {
        self.tag =cTag;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        if (cTag != 7)
        {
            [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [manager.requestSerializer setValue:@"dUfNhktz2Tcl32pGgbPTZ57QujOQBluh" forHTTPHeaderField:@"X-App-Token"];
        }
      
        [manager POST:request parameters:parameter progress:nil success:^(NSURLSessionTask *task, id responseObject)
        {
            [self.delegate customURLConnectionDidFinishLoading:self withTag:self.tag withResponse:responseObject];
        }
        failure:^(NSURLSessionTask *operation, NSError *error)
        {
            [self.delegate customURLConnection:self withTag:self.tag didFailWithError:error];
        }];
    }
    
    return self;
    
}
-(id)initWithGet:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter
{
    self = [super init];
    
    if (self)
    {
        self.tag =cTag;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"dUfNhktz2Tcl32pGgbPTZ57QujOQBluh" forHTTPHeaderField:@"X-App-Token"];
        [manager GET:request parameters:parameter progress:nil success:^(NSURLSessionTask *task, id responseObject)
         {
             [self.delegate customURLConnectionDidFinishLoading:self withTag:cTag withResponse:responseObject];
         }
             failure:^(NSURLSessionTask *operation, NSError *error)
         {
             [self.delegate customURLConnection:self withTag:self.tag didFailWithError:error];
         }];
    }
    
    return self;
    
}
-(id)initWithPost:(NSString *)requeststr withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter ImageName :(UIImage *)image andImageKey: (NSString *)key
{
    self = [super init];
    
    if (self)
    {
        
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:requeststr parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.7  ) name:key fileName:@"image.jpg" mimeType:@"image/jpeg"];
        } error:nil];
        
        // added
       
        [request setValue:@"dUfNhktz2Tcl32pGgbPTZ57QujOQBluh" forHTTPHeaderField:@"X-App-Token"];
        
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSURLSessionUploadTask *uploadTask;
        uploadTask = [manager
                      uploadTaskWithStreamedRequest:request
                      progress:^(NSProgress * _Nonnull uploadProgress) {
                          // This is not called back on the main queue.
                          // You are responsible for dispatching to the main queue for UI updates
                          dispatch_async(dispatch_get_main_queue(), ^{
                              //Update the progress view
                          });
                      }
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          if (error) {
                              NSLog(@"Error: %@", error);
                                          [self.delegate customURLConnection:self withTag:cTag didFailWithError:error];

                          } else {
//                              NSLog(@"%@ %@", response, responseObject);
                                          [self.delegate customURLConnectionDidFinishLoading:self withTag:cTag withResponse:responseObject];

                          }
                      }];
        
        [uploadTask resume];    }
    
    return self;

}
-(id)initWithPost:(NSString *)requeststr withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter ImageName :(UIImage *)image andImageKey: (NSString *)key CellImageName :(UIImage *)cellImage andCellImageKey: (NSString *)cellKey
{
    self = [super init];
    
    if (self)
    {
        NSURL  *url = [NSURL URLWithString:requeststr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

       request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:requeststr parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
            {
                
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.7  ) name:key fileName:@"image.jpg" mimeType:@"image/jpeg"];
            [formData appendPartWithFileData:UIImageJPEGRepresentation(cellImage, 0.7  ) name:cellKey fileName:@"image1.jpg" mimeType:@"image/jpeg"];
        } error:nil];
        
        // added
        [request setValue:@"dUfNhktz2Tcl32pGgbPTZ57QujOQBluh" forHTTPHeaderField:@"X-App-Token"];
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        
        NSURLSessionUploadTask *uploadTask;
        uploadTask = [manager
                      uploadTaskWithStreamedRequest:request
                      progress:^(NSProgress * _Nonnull uploadProgress) {
                          // This is not called back on the main queue.
                          // You are responsible for dispatching to the main queue for UI updates
                          dispatch_async(dispatch_get_main_queue(), ^{
                              //Update the progress view
                          });
                      }
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          if (error) {
                              NSLog(@"Error: %@", error);
                              [self.delegate customURLConnection:self withTag:cTag didFailWithError:error];
                              
                          } else {
//                              NSLog(@"%@ %@", response, responseObject);
                              [self.delegate customURLConnectionDidFinishLoading:self withTag:cTag withResponse:responseObject];
                              
                          }
                      }];
        
        [uploadTask resume];    }
    
    return self;
    
}

-(void)dummy
{
}
-(id)initWithPostLogin:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter
{
    self = [super init];
    
    if (self)
    {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
      
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
       
        [manager POST:request parameters:parameter progress:nil success:^(NSURLSessionTask *task, id responseObject)
         {
             [self.delegate customURLConnectionDidFinishLoading:self withTag:cTag withResponse:responseObject];
         }
              failure:^(NSURLSessionTask *operation, NSError *error)
         {
             NSLog(@"%@",[error description]);
             [self.delegate customURLConnection:self withTag:cTag didFailWithError:error];
         }];
    }
    
    return self;
    
}
-(id)initWithPostToken:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter
{
    self = [super init];
    
    if (self)
    {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
              manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager POST:request parameters:parameter progress:nil success:^(NSURLSessionTask *task, id responseObject)
         {
             [self.delegate customURLConnectionDidFinishLoading:self withTag:cTag withResponse:responseObject];
         }
              failure:^(NSURLSessionTask *operation, NSError *error)
         {
             NSLog(@"%@",[error description]);
             [self.delegate customURLConnection:self withTag:cTag didFailWithError:error];
         }];
    }
    
    return self;
    
}
-(id)initWithPutToken:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter
{
    self = [super init];
    
    if (self)
    {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"application/json"]forHTTPHeaderField:@"Content-Type"];
        
        [manager PUT:request parameters:parameter success:^(NSURLSessionTask *task, id responseObject)
         {
             [self.delegate customURLConnectionDidFinishLoading:self withTag:cTag withResponse:responseObject];
         }
             failure:^(NSURLSessionTask *operation, NSError *error)
         {
             [self.delegate customURLConnection:self withTag:cTag didFailWithError:error];
         }];
    }
    
    return self;
    
}
-(id)initWithGetToken:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter
{
    self = [super init];
    
    if (self)
    {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:401];
        manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:404];
        manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:400];
        manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:200];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"application/json"]forHTTPHeaderField:@"Content-Type"];
        
        [manager GET:request parameters:parameter progress:nil success:^(NSURLSessionTask *task, id responseObject)
         {
             [self.delegate customURLConnectionDidFinishLoading:self withTag:cTag withResponse:responseObject];
         }
              failure:^(NSURLSessionTask *operation, NSError *error)
         {
             NSLog(@"%@",[error description]);
             [self.delegate customURLConnection:self withTag:cTag didFailWithError:error];
         }];
    }
    
    return self;
    
}
-(id)initWithDeleteToken:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter
{
    self = [super init];
    
    if (self)
    {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:401];
        manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:404];
        manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:400];
        manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:200];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"dUfNhktz2Tcl32pGgbPTZ57QujOQBluh" forHTTPHeaderField:@"X-App-Token"];

        [manager DELETE:request parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self.delegate customURLConnectionDidFinishLoading:self withTag:cTag withResponse:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",[error description]);
            [self.delegate customURLConnection:self withTag:cTag didFailWithError:error];
        }];
    }
    
    return self;
    
}
@end
