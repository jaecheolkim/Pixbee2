//
//  PBUtil.m
//  Pixbee
//
//  Created by jaecheol kim on 1/6/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import "PBUtil.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


@implementation PBUtil

//가장 최근에 호출된 키보드의 높이
static float keyboardHeight;

#pragma mark - Class Methods

// Document 디렉토리의 경로를 가져옵니다.
+ (NSString*)getDocumentPath
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

+ (NSString *)getCacheDirectory
{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
}

// NSString* 의 폴더명을 넣어 Document 하위 폴더의 전체 경로값을 가져옵니다.
+ (NSString*)getDocumentFilePath:(NSString*)filePath
{
    NSString *returnPath = [[[self class] getDocumentPath] stringByAppendingPathComponent:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:returnPath]) {
		[fileManager createDirectoryAtPath:returnPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
    return returnPath;
}

+ (NSString*)getCacheFilePath:(NSString*)filePath
{
    NSString *returnPath = [[[self class] getCacheDirectory] stringByAppendingPathComponent:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:returnPath]) {
		[fileManager createDirectoryAtPath:returnPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
    return returnPath;
}


// 오늘 날짜를 yyyy-MM-dd 형식의 NSString* 문자열로 가져옵니다.
+ (NSString *)getDate
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];//@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
    return [formatter stringFromDate:today];
}

// 날짜계산을 할 때, 시작날짜(적은숫자, 기준이 되는 날짜), 종료날짜(큰 숫자, 비교할 날짜)가 days일 사이에 있는지를 BOOL 타입으로 반환합니다.
+ (BOOL)isLongerDate:(NSString*)startDate withEndDate:(NSString*)endDate withIndays:(int)days
{
    //startDate + days 가 endDate 보다 크다면 YES, startDate + days 더한 값 보다 endDate 가 크다면 NO
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSDate* sDate = [formatter dateFromString:startDate];
    NSDate* eDate = [formatter dateFromString:endDate];
    
    NSDate* uDate = [NSDate dateWithTimeInterval:(60 * 60 * 24 * days) sinceDate:sDate];
    
    if([uDate compare:eDate] == NSOrderedDescending){
        return YES;
    }
    return NO;
}

// *일 전, *시간 전, *분 전, *년 전 등.. 문자열을 돌려줍니다. 다국어 적용해야 함.
+ (NSString*)dayBeforeString:(NSString*)inputDateString
{
#warning 다국어 처리 필요
    NSString* justBeforeString = @"지금 막";
    NSString* beforFewMinuteString = @"%d분 전";
    NSString* before6HourString = @"%d시간 전";
    NSString* todayString = @"a h:mm";
    NSString* beforeYesterdayString = @"M월 d일 a h:mm";
    NSString* beforeLastYearString = @"yyyy년 M월 d일 a h:mm";
    
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss.S"];
	NSDate *inputDate = [df dateFromString: inputDateString];
    
    if (!inputDate) {
        //정상적으로 변환하지 못할 경우 들어온 텍스트 그대로 출력, ! 붙여서 에러인지 확인
        return [NSString stringWithFormat:@"!%@", inputDateString];
    }
    
	NSDate *today = [NSDate date];
	NSTimeInterval secondsBetween = [today timeIntervalSinceDate:inputDate];
    
    if (secondsBetween < 60) {
        return justBeforeString;
    }
    else if (secondsBetween < 3600) {
        return [NSString stringWithFormat:beforFewMinuteString, (int)(secondsBetween / 60)];
    }
    else if (secondsBetween < 21600) {
        return [NSString stringWithFormat:before6HourString, (int)(secondsBetween / 3600)];
    }
    else if (secondsBetween < 86400) {
        [df setDateFormat:todayString];
        return [df stringFromDate:inputDate];
    }
    else if (secondsBetween < 31536000) {
        [df setDateFormat:beforeYesterdayString];
        return [df stringFromDate:inputDate];
    }
    else {
        [df setDateFormat:beforeLastYearString];
        return [df stringFromDate:inputDate];
    }
}


// yyyyMMdd 형식의 문자열을 날짜형식으로 바꾸어 비교하여 NSComparisonResult 형식으로 반환합니다.
+ (NSComparisonResult)compare:(NSString*)date withEndDate:(NSString*)otherDate {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSDate* sDate = [formatter dateFromString:date];
    NSDate* eDate = [formatter dateFromString:otherDate];
    return [sDate compare:eDate];
}

// 단말의 언어 설정을 가져옵니다. 중국어일 경우 번체 간체 여부도 같이 합쳐서.
+ (NSString *)languegeCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *languege = languages[0];
    
    if ([languege isEqualToString:@"ko"] ||
        [languege isEqualToString:@"en"] ||
        [languege isEqualToString:@"ja"] ||
        [languege isEqualToString:@"es"] ||
        [languege isEqualToString:@"de"]) {
        
        return languege;
    }
    else if ([languege isEqualToString:@"zh-Hans"]) {
        return @"zh-CN";
    }
    else if ([languege isEqualToString:@"zh-Hant"]) {
        return @"zh-TW";
    }
    else {
        return @"en";
    }
}

#pragma mark - get UserDefault, New 아이콘 표시여부

// userDefault 값을 NSDictionary 형태로 반환합니다.
+ (NSDictionary*)getUserCustomDictionaryWithkey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

// userDefault 값을 쓸 때 사용합니다.
+ (void)setUserCustomDictionary:(NSDictionary*)aDictionary Withkey:(NSString*)aKey
{
    [[NSUserDefaults standardUserDefaults] setObject:aDictionary forKey:aKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



// iOS의 UTF8 Encoding은 몇몇 특수문자를 인코딩하지 못하므로 stringByReplacingPercentEscapesUsingEncoding 대신 아래를 사용
+ (NSString*) encodeAddingPercentEscapeString:(NSString *) aString
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)aString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}

// 마찬가지로 몇몇 특수문자가 포함된 UTF8 문자열을 제대로 디코드하지 못하므로 아래를 사용
+ (NSString*) decodeFromPercentEscapeString:(NSString *) encodingString
{
    return (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                         (__bridge CFStringRef) encodingString,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8);
}



// Email Validation Check
+ (BOOL) isValidEmailString:(NSString *)checkString
{
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


// 포커스 된 텍스트필드에 따라 뷰의 높이 조절 - 텍스트필드가 보이도록
+ (void)moveView:(UIView*)aView WithZeroYOffset:(CGFloat)zeroOffset WithCurrentTextField:(UITextField*)aTextField WhenKeyboardshowAndHide:(NSNotification*)keyboardNotification
{
    if ((!keyboardNotification || !aView) || !aTextField) {
        return;
    }
    
    NSDictionary* info = [keyboardNotification userInfo];
    CGRect beginRect = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardHeight = beginRect.origin.y - endRect.origin.y;
    CGFloat time = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    float convertPointY = [aTextField convertPoint:aTextField.frame.origin toView:aView].y + 44.0f;
    if (keyboardHeight >= 0) {
        if ( (convertPointY >= ((aView.frame.size.height - keyboardHeight) / 2.0f))
            && (convertPointY >= (aView.frame.size.height - keyboardHeight)) ) {
            //텍스트필드가 키보드가 올라온 이후의 화면에서 중간 이하일 경우, 가운데에 위치하도록 이동
            CGRect upViewFrame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y - (convertPointY - ((aView.frame.size.height - keyboardHeight) / 2.0f) - 44.0f),
                                            aView.frame.size.width, aView.frame.size.height);
            [UIView animateWithDuration:time animations:^{
                aView.frame = upViewFrame;
            } completion:^(BOOL finished) {
                
            }];
        }
        else if (convertPointY >= (aView.frame.size.height - keyboardHeight)) {
            //텍스트필드가 뷰의 하단에 있을 때, 뷰의 높이까지만 올려줌
            CGRect upViewFrame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y - keyboardHeight,
                                            aView.frame.size.width, aView.frame.size.height);
            [UIView animateWithDuration:time animations:^{
                aView.frame = upViewFrame;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    else {
        //뷰를 원래대로 내려준다
        CGRect downViewFrame = CGRectMake(aView.frame.origin.x, ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) ? zeroOffset : 0.0f,
                                          aView.frame.size.width, aView.frame.size.height);
        [UIView animateWithDuration:time animations:^{
            aView.frame = downViewFrame;
        } completion:^(BOOL finished) {
            
        }];
    }
}

// 키보드가 올라와 있는 상태에서 다른 텍스트필드를 선택했을 때의 뷰 이동
+ (void)moveView:(UIView*)aView WithZeroYOffset:(CGFloat)zeroOffset PreviousTextField:(UITextField*)aPreviousTextField AndCurrentTextField:(UITextField*)aCurrentTextField
{
    if (aPreviousTextField != nil && aPreviousTextField != aCurrentTextField) {
        float convertPointY = [aCurrentTextField convertPoint:aCurrentTextField.frame.origin toView:aView].y + 44.0f;
        if ( (convertPointY >= ((aView.frame.size.height - keyboardHeight) / 2.0f))
            && (convertPointY >= (aView.frame.size.height - keyboardHeight)) ) {
            //포커스된 필드가 뷰의 가운데 영역에 있다면 기존의 포커스되어있던 텍스트필드와 현재 선택한 텍스트필드의 차이만큼 뷰를 올리거나 내림
            float distance = [aPreviousTextField convertPoint:aPreviousTextField.frame.origin toView:aView].y - [aCurrentTextField convertPoint:aCurrentTextField.frame.origin toView:aView].y;
            CGRect viewFrame = CGRectMake(aView.frame.origin.x, aView.frame.origin.y + distance, aView.frame.size.width, aView.frame.size.height);
            [UIView animateWithDuration:0.25f animations:^{
                aView.frame = viewFrame;
            }];
        }
        else if(convertPointY >= aView.frame.size.height - (keyboardHeight / 2.0f)){
            //선택한 텍스트필드가 뷰의 하단에 있을 경우, 뷰를 아래까지만 내림
            CGRect viewFrame = CGRectMake(aView.frame.origin.x, -keyboardHeight, aView.frame.size.width, aView.frame.size.height);
            [UIView animateWithDuration:0.25f animations:^{
                aView.frame = viewFrame;
            }];
        }
        else {
            //선택한 텍스트필드가 뷰의 상단에 있을 경우, 뷰를 올리지 않음
            CGRect viewFrame = CGRectMake(aView.frame.origin.x, ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) ? zeroOffset : 0.0f
                                          , aView.frame.size.width, aView.frame.size.height);
            [UIView animateWithDuration:0.25f animations:^{
                aView.frame = viewFrame;
            }];
        }
    }
}

+ (NSString *)timeZoneOffsetInMinutes
{
    static NSString *resultString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
        NSTimeInterval gmtInterval = [currentTimeZone secondsFromGMTForDate:[NSDate date]];
        NSInteger offset = gmtInterval / 60;
        resultString = [NSString stringWithFormat:@"%d", (int)offset];
    });
    
    if (nil == resultString) {
        return @"0";
    }
    
    return resultString;
}

+ (NSString *)countryCode
{
    // 통신사에 대한 지역 코드 읽기
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    NSString *isoCountryCode = [carrier isoCountryCode];
    
    // 지역 코드를 읽어오지 못할 경우 로케일에 따른 지역 코드를 읽는다.
    NSString *countryCode = nil;
    if (isoCountryCode == nil || [isoCountryCode isEqualToString:@""]) {
        countryCode = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] uppercaseString];
    }
    else {
        countryCode = [[NSString stringWithFormat:@"%@", isoCountryCode] uppercaseString];
    }
    
    return countryCode;
}

+ (NSString *)filterChosungText:(NSString *)string
{
    NSArray *chosung = @[@"ㄱ", @"ㄲ", @"ㄴ", @"ㄷ", @"ㄸ",
                         @"ㄹ", @"ㅁ", @"ㅂ", @"ㅃ", @"ㅅ",
                         @"ㅆ", @"ㅇ", @"ㅈ", @"ㅉ", @"ㅊ",
                         @"ㅋ", @"ㅌ", @"ㅍ", @"ㅎ"];
    
    NSString *filteredText = @"";
    
    for (int i = 0; i < [string length]; i++) {
        NSInteger code = [string characterAtIndex:i];
        if (code >= 44032 && code <= 55203) {
            NSInteger unicode = code - 44032;
            NSInteger chosungIndex = unicode / 21 / 28;
            filteredText = [NSString stringWithFormat:@"%@%@", filteredText, [chosung objectAtIndex:chosungIndex]];
        }
        else {
            filteredText = [NSString stringWithFormat:@"%@%@", filteredText, [string substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    
    return filteredText;
}

// 이미지 저장 키
+ (NSString*)getStoreKeyWithString:(NSString*)baseString andPrefix:(NSString*)prefix
{
	
	NSURL * url = [NSURL URLWithString:baseString];
	
	NSString * path = url.path;
	NSString * domain = url.host;
	
	NSString * resultString;
	resultString = [NSString stringWithFormat:@"%@%@", domain, path];
	if (prefix) {
		return [NSString stringWithFormat:@"%@_%@", prefix, resultString];
	} else {
		return resultString;
	}
}

+ (UIImage *)imageWithColor:(UIColor *)color frame:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (NSMutableDictionary*)getDataDic
{
	NSString *cacheDir = [PBUtil getCacheFilePath:@"CYMERA_DBDATA"];
	NSString * file = [cacheDir stringByAppendingPathComponent:@"/SNSData.plist"];
	NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
	if (!dic) {
		dic = [NSMutableDictionary new];
		[dic writeToFile:file atomically:YES];
	}
	return dic;
}

+ (void)saveDataDic:(NSMutableDictionary*)dic
{
	NSString *cacheDir = [PBUtil getCacheFilePath:@"CYMERA_DBDATA"];
	NSString * file = [cacheDir stringByAppendingPathComponent:@"/SNSData.plist"];
	[dic writeToFile:file atomically:YES];
}

+ (NSMutableDictionary*)getDic:(NSString*)key
{
	NSMutableDictionary * dataDic = [PBUtil getDataDic];
	return dataDic ? (dataDic[key] ? dataDic[key] : [NSMutableDictionary dictionary]) : [NSMutableDictionary dictionary];
}

+ (void)saveDic:(NSMutableDictionary*)dic withKey:(NSString*)key
{
	NSMutableDictionary * dataDic = [PBUtil getDataDic];
	if (dic) {
		dataDic[key] = dic;
	} else {
		// remove dic
		if (dataDic[key]) {
			[dataDic removeObjectForKey:key];
		}
	}
    
	[PBUtil saveDataDic:dataDic];
}

// test
+ (NSMutableDictionary*)getPhotoFeedsDic
{
	return [PBUtil getDic:@"photoFeeds"];
}

+ (void)savePhotoFeedsDic:(NSMutableDictionary*)photos
{
	[PBUtil saveDic:photos withKey:@"photoFeeds"];
}

@end
