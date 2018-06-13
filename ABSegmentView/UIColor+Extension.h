//
//  UIColor+Extension.h
//  Wildto
//
//  Created by Wildto on 16/6/13.
//  Copyright © 2016年 Wildto. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 颜色16进制 */
#define ColorWithHex(hex) [UIColor colorWithHexString:hex]

/** 颜色16进制（alpha）  */
#define ColorWithHexAlpha(hex,a) [UIColor colorWithHexString:hex alpha:a]

/** 颜色RGB */
#define Color(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

/** 颜色RGB（alpha） */
#define ColorWithAlpha(r, g, b ,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

/** 随机颜色 */
#define YTRandomColor Color(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

/** 随机颜色 */
#define YTRandomColorWithAlpha ColorWithAlpha(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), 0.25)

@interface UIColor (Extension)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

+ (UIColor *)colorWithHexString:(NSString *)color;

@end
