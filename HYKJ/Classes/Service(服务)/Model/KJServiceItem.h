//
//  KJServiceItem.h
//  HYKJ
//
//  Created by information on 2020/8/26.
//  Copyright © 2020 hongyan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    ServiceTypeFangwei = 0,  // 防伪
    ServiceTypeShouhou = 1,  // 售后
    ServiceTypeToushu = 2,   // 投诉
    ServiceTypeKnowledge = 3, // 知识
    ServiceTypeKefu = 4 // 客服
} ServiceType;

NS_ASSUME_NONNULL_BEGIN

@interface KJServiceItem : NSObject

/** 图片  */
@property (nonatomic, copy ,readonly) NSString *iconImage;
/** 文字  */
@property (nonatomic, copy ,readonly) NSString *gridTitle;
/** tag  */
@property (nonatomic, copy ,readonly) NSString *gridTag;
/** tag颜色  */
@property (nonatomic, copy ,readonly) NSString *gridColor;
/** 服务类型 */
@property (nonatomic, assign) ServiceType serviceType;
@end

NS_ASSUME_NONNULL_END
