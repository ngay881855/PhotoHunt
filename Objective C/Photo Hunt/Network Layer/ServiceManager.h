//
//  ServiceManager.h
//  Photo Hunt
//
//  Created by Ngay Vong on 11/13/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ServiceManagerProtocol <NSObject>

- (void)request: (NSURLRequest *) urlRequest withSuccessHandler: (void(^)(NSData *data))successHandler failureHandler: (void(^)(NSError *error))errorHandler;

@end

@interface ServiceManager : NSObject <ServiceManagerProtocol>

@end

NS_ASSUME_NONNULL_END
