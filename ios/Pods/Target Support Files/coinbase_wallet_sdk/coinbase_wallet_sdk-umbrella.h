#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CoinbaseWalletSdkFlutterPlugin.h"

FOUNDATION_EXPORT double coinbase_wallet_sdkVersionNumber;
FOUNDATION_EXPORT const unsigned char coinbase_wallet_sdkVersionString[];

