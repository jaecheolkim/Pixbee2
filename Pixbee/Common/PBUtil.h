//
//  PBUtil.h
//  Pixbee
//
//  Created by jaecheol kim on 1/6/14.
//  Copyright (c) 2014 Pixbee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBUtil : NSObject
#define nilCheck(str) (str==nil || [str isEqualToString:@""])

// 파일 경로 가져오기
+ (NSString*)getDocumentPath;
+ (NSString*)getDocumentFilePath:(NSString*)filePath;

+ (NSString*)getCacheDirectory;
+ (NSString*)getCacheFilePath:(NSString*)filePath;

// 날짜 가져오기, 날짜 계산, 날짜 비교
+ (NSString *)getDate;
+ (BOOL)isLongerDate:(NSString*)startDate withEndDate:(NSString*)endDate withIndays:(int)days;
+ (NSString*)dayBeforeString:(NSString*)inputDateString;
+ (NSComparisonResult)compare:(NSString*)date withEndDate:(NSString*)otherDate;

// 단말의 언어설정 가져오기
+ (NSString *)languegeCode;

// UserDefault 값 가져오기, 쓰기
+ (NSDictionary*)getUserCustomDictionaryWithkey:(NSString*)key;
+ (void)setUserCustomDictionary:(NSDictionary*)aDictionary Withkey:(NSString*)aKey;

// 문자열의 % 포함 인코딩, 디코딩
+ (NSString*) encodeAddingPercentEscapeString:(NSString *) aString;
+ (NSString*) decodeFromPercentEscapeString:(NSString *) encodingString;

// 유효한 이메일 형태인지 체크
+ (BOOL) isValidEmailString:(NSString *)checkString;

// 포커스 된 UITextField의 위치에 따라 뷰를 올려줄 것인지 말 것인지, 뷰의 높이는 언어 별 키보드의 높이에 따라 변동
+ (void)moveView:(UIView*)aView WithZeroYOffset:(CGFloat)zeroOffset WithCurrentTextField:(UITextField*)aTextField WhenKeyboardshowAndHide:(NSNotification*)keyboardNotification;

// 키보드가 올라와 있는 상태에서 다른 텍스트필드를 선택했을 때의 뷰 이동
+ (void)moveView:(UIView*)aView WithZeroYOffset:(CGFloat)zeroOffset PreviousTextField:(UITextField*)aPreviousTextField AndCurrentTextField:(UITextField*)aCurrentTextField;

// 사용자 위치의 GMT 대비 Offset을 분 단위로 돌려주는 메소드
+ (NSString *)timeZoneOffsetInMinutes;

+ (NSString *)countryCode;

// 초성을 리턴
+ (NSString *)filterChosungText:(NSString *)string;

// 이미지 저장 키
+ (NSString*)getStoreKeyWithString:(NSString*)baseString andPrefix:(NSString*)prefix;




// data dictionary file management
+ (NSMutableDictionary*)getDic:(NSString*)key;
+ (void)saveDic:(NSMutableDictionary*)dic withKey:(NSString*)key;

+ (NSMutableDictionary*)getPhotoFeedsDic;
+ (void)savePhotoFeedsDic:(NSMutableDictionary*)photos;
@end
