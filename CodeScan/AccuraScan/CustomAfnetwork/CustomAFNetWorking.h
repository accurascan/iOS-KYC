//
//  CustomAFNetWorking.h

#define LivenessTag 6

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CustomAFNetWorking : NSObject
{
    //Delegate
    id _delegate;
    
    //Data;
    NSMutableData *dataReceived;
}
//Properties
@property (nonatomic) int tag;
@property (strong,nonatomic) id delegate;
-(id)initWithPost:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter;
-(id)initWithGet:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter;
-(id)initWithPost:(NSString *)requeststr withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter ImageName: (UIImage *)image andImageKey: (NSString *)key;
-(id)initWithDeleteToken:(NSString *)request withTag:(int)cTag withParameter:(NSMutableDictionary *)parameter;
@end

@protocol CustomAFNetWorkingDelegate<NSObject>

- (void)customURLConnectionDidFinishLoading:(CustomAFNetWorking *)connection withTag:(int)tagCon withResponse:(id)response;

- (void)customURLConnection:(CustomAFNetWorking *)connection withTag:(int)tagCon didReceiveResponse:(NSURLResponse *)response;


//Delegate Methods

//For Error
- (void)customURLConnection:(CustomAFNetWorking *)connection withTag:(int)tagCon didFailWithError:(NSError *)error;

//For Exception
- (void)customURLConnection:(CustomAFNetWorking *)connection withException:(NSException *)exception withTag:(int)tagCon;

//For Getting Response

//For Receive Partial Data
- (void)customURLConnection:(CustomAFNetWorking *)connection withTag:(int)tagCon didReceiveData:(NSData *)data;

//For Getting the complete Response
- (void)customURLConnectionDidFinishLoading:(CustomAFNetWorking *)connection withTag:(int)tagCon;

//For Complete Response with Result

//For Complete Result in data
- (void)customURLConnectionDidFinishLoading:(CustomAFNetWorking *)connection withTag:(int)tagCon withData:(NSMutableData *)data;

//For Complete Result in data
- (void)customURLConnectionDidFinishLoading:(CustomAFNetWorking *)connection withTag:(int)tagCon withData:(NSMutableData *)data FromURL:(NSURL *)url;

@end
