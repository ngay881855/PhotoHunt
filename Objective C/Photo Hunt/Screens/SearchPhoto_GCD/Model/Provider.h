//
//  Provider.h
//  Photo Hunt
//
//  Created by Ngay Vong on 11/16/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Provider : NSObject
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSMutableDictionary *header;
@property (nonatomic) BOOL *isOn;

- (instancetype)
- (void) addQueryToParameters: (NSString *)query;

@end

NS_ASSUME_NONNULL_END
