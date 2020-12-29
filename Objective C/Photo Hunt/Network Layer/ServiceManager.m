//
//  ServiceManager.m
//  Photo Hunt
//
//  Created by Ngay Vong on 11/13/20.
//

#import "ServiceManager.h"
#import <Foundation/Foundation.h>

@implementation ServiceManager

- (void)request:(NSURLRequest *)urlRequest withSuccessHandler:(void (^)(NSData * _Nonnull))successHandler failureHandler:(void (^)(NSError * _Nonnull))errorHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            errorHandler(error);
            return;
        }
        if (!data) {
            NSError *error = [[NSError alloc] initWithDomain:@"Data Unavaliable" code:1004 userInfo:nil];
            errorHandler(error);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response; // down-casting in objective c
        if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299) {
            successHandler(data);
        } else {
            NSLog(@"httpResponse.statusCode error");
            NSError *error = [[NSError alloc] initWithDomain:@"httpResponse.statusCode error" code:1004 userInfo:nil];
            errorHandler(error);
            return;
        }
    }];
    
    [task resume];
}
@end
