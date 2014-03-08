/*!
 * @header
 *
 * @discussion Header file containing the main public API.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 * @class PulseSDK
 *
 * @abstract The main public interface to the Pulse SDK.
 *
 * @author Keith Simmons
 */
@interface PulseSDK : NSObject


/*!
 * @abstract Initialize the Pulse.io monitoring system.
 *
 * @discussion This should be called within an autorelease pool
 *   context but before any other calls are made.
 *
 * @param applicationID The API key provided by Pulse.io
 */
+ (void)monitor:(NSString *)applicationID;

/*!
 * @abstract Have the SDK trace all instance methods of the given
 *   class.
 *
 * @discussion All instance methods except for @link //apple_ref/occ/instm/NSObject/dealloc dealloc @/link of
 *   the class will be traced.
 *
 * @param cls The class whose methods should be traced
 */
+ (void)instrumentClass:(Class)cls;

/*!
 * @abstract Specify a user label for the most recent touch.
 *
 * @discussion This will supercede any automatically generated label.
 *
 * @param label The label to assign
 */
+ (void)labelTouch:(NSString *)label;

/*!
 * @abstract Begin a user-specified wait period.
 *
 * @discussion This method should be balanced with a
 *   @link stopWait: @/link call. If this method is called a second
 *   time with the same key and without an intervening
 *   @link stopWait: @/link call, it has no effect.
 *
 * @param key The key to use when specifying the end of the period
 */
+ (void)startWait:(NSString *)key;

/*!
 * @abstract End a user-specified wait period.
 *
 * @discussion If there has not been a previous call to
 *   @link startWait: @/link with the given key, this call has no effect.
 *
 * @param key The key that was used to start the wait period
 */
+ (void)stopWait:(NSString *)key;

/*!
 * @abstract Begin a user-specified wait period corresponding to a
 * specific touch event.
 *
 * @discussion This method should be balanced with a
 *   @link stopWait: @/link call. If this method is called a second
 *   time with the same key and without an intervening
 *   @link stopWait: @/link call, it has no effect.
 *
 * @param key The key to use when specifying the end of the period
 */
+ (void)startWait:(NSString *)key withTouch:(NSString *)touch;

/*!
 * @abstract Notify the SDK that a custom activity indicator has
 *   started animating.
 *
 * @param spinner The view of the activity indicator
 */
+ (void)startSpinner:(UIView *)spinner;

/*!
 * @abstract Notify the SDK that a custom activity indicator has
 *   stopped animating.
 *
 * @param spinner The view of the activity indicator
 */
+ (void)stopSpinner:(UIView *)spinner;

/*!
 * @abstract Notify the SDK that an activity indicator should not
 *   introduce a wait state.
 *
 * @param spinner The object that may be interpreted as an activity
 *   indicator
 *
 * @param disabled <code>YES</code> if the spinner should be ignored
 *   for the purposes of generating wait states; <code>NO</code> to treat it as a regular spinner
 */
+ (void)spinner:(UIView *)spinner setIgnored:(BOOL)disabled;

/*!
 * @abstract Check the ignored flag of an activity indicator.
 *
 * @param spinner The object that may be interpreted as an activity
 *   indicator
 */
+ (BOOL)isSpinnerIgnored:(UIView *)spinner;

/*!
 * @abstract Property controlling the stripping of query and parameter strings from recorded URLs.
 * @param enabled True if query and parameter strings should be stripped from URLs before they are recorded.
 */
+ (void)setURLStrippingEnabled:(BOOL)enabled;

/*!
 * @abstract If true, query and parameter strings should be stripped from URLs before they are recorded.
 */
+ (BOOL)URLStrippingEnabled;

@end
