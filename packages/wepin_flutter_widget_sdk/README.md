<br/>

<p align="center">
  <a href="https://wepin.io">
      <picture>
        <source media="(prefers-color-scheme: dark)" srcset="https://github.com/WepinWallet/wepin-web-sdk-v1/blob/main//assets/wepin_logo_white.png">
        <img bg_color="white" alt="wepin logo" src="https://github.com/WepinWallet/wepin-web-sdk-v1/blob/main//assets/wepin_logo_color.png" width="250" height="auto">
      </picture>
  </a>
</p>

<br>


# wepin_flutter_widget_sdk

[![mit licence](https://img.shields.io/dub/l/vibe-d.svg?style=for-the-badge)](https://github.com/WepinWallet/wepin-flutter-sdk/blob/main/LICENSE)

[![pub package](https://img.shields.io/pub/v/wepin_flutter_widget_sdk.svg?logo=flutter&style=for-the-badge)](https://pub.dartlang.org/packages/wepin_flutter_widget_sdk)

[![platform - android](https://img.shields.io/badge/platform-Android-3ddc84.svg?logo=android&style=for-the-badge)](https://www.android.com/) [![platform - ios](https://img.shields.io/badge/platform-iOS-000.svg?logo=apple&style=for-the-badge)](https://developer.apple.com/ios/)

Wepin Widget SDK for Flutter. This package is exclusively available for use in Android and iOS environments.

## ⏩ Get App ID and Key

After signing up for [Wepin Workspace](https://workspace.wepin.io/), navigate to the development tools menu, and enter the required information for each app platform to receive your App ID and App Key.

## ⏩ Requirements

- Android API version **21** or newer is required.
  - Set `compileSdkVersion` to **34** in the `android/app/build.gradle` file.
- iOS version **13** or newer is required.
  - Update the `platform :ios` version to **13.0** in the `ios/Podfile` of your Flutter project. Verify and modify the `ios/Podfile` as needed.
- Dart version **2.18.3** or newer is required.
- Flutter version **3.3.0** or newer is required.

## ⏩ Install
Add the `wepin_flutter_widget_sdk` dependency in your pubspec.yaml file:

```yaml
dependencies:
  wepin_flutter_widget_sdk: ^0.0.5
```
or run the following command:

```bash
flutter pub add wepin_flutter_widget_sdk
```

## ⏩ Getting Started

### Config Deep Link

The Deep Link configuration is required for logging into Wepin. Setting up the Deep Link Scheme allows your app to handle external URL calls.

The format for the Deep Link scheme is `wepin. + Your Wepin App ID`

#### Android

When a custom scheme is used, the WepinWidget SDK can be easily configured to capture all redirects using this custom scheme through a manifest placeholder in the `build.gradle (app)` file::

```kotlin
// For Deep Link => RedirectScheme Format: wepin. + Wepin App ID
android.defaultConfig.manifestPlaceholders = [
  'appAuthRedirectScheme': 'wepin.{{YOUR_WEPIN_APPID}}'
]
```

#### iOS

You must add the app's URL scheme to the `Info.plist` file. This is necessary for redirection back to the app after the authentication process.

The value of the URL scheme should be `'wepin.' + your Wepin app id`.

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>unique name</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>wepin.{{YOUR_WEPIN_APPID}}</string>
        </array>
    </dict>
</array>

```

### Add Permssion
To use this SDK, camera access permission is required. The camera function is essential for recognizing addresses in QR code format. [[Reference: permission_handle](https://pub.dev/packages/permission_handler)]

#### Android
Add the below line in your app's `AndroidMainfest.xml` file

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.INTERNET" />
  <!-- ... -->
</manifest>
```

#### iOS
1. **Update `Podfile`**: Add a camera permission to your `Podfile` file:
  ```
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      flutter_additional_ios_build_settings(target)
  
      target.build_configurations.each do |config|
        # For more information, refer to https://github.com/BaseflowIT/flutter-permission-handler/blob/master/permission_handler/ios/Classes/PermissionHandlerEnums.h
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
          '$(inherited)',
          ## dart: PermissionGroup.camera
          'PERMISSION_CAMERA=1',
          ]
      end
    end
  end
  ```
2. **Update `Info.plist`:** Update your Info.plist with the required permission usage descriptions:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- 🚨 Keep only the permissions used in your app 🚨 -->
  <key>NSCameraUsageDescription</key>
  <string>YOUR TEXT</string>
  <!-- … -->
</dict>
</plist>
```

### OAuth Login Provider Setup

If you want to use OAuth login functionality (e.g., loginWithUI), you need to set up OAuth login providers.
To do this, you must first register your OAuth login provider information in the [Wepin Workspace](https://workspace.wepin.io/). 
Navigate to the Login tab under the Developer Tools menu, click the Add or Set Login Provider button in the Login Provider section, and complete the registration.  

![image](https://github.com/user-attachments/assets/b7a7f6d3-69a7-4ee5-ab66-bad57a715fda)


## ⏩ Import SDK

```dart
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';
```

## ⏩ Initialize

```dart
WepinWidgetSDK wepinSDK = WepinWidgetSDK(wepinAppKey: wepinAppKey, wepinAppId: wepinAppId);
```

### init

```dart
await wepinSDK.init({WidgetAttributes? attributes})
```

#### Parameters
- `attributes` \<WidgetAttributes> __optional__ - An optional object to configure widget attributes.
    - `defaultLanguage` \<String> - The language to be displayed on the widget (default: 'ko'). Currently, only 'ko', 'en', and 'ja' are supported.
    - `defaultCurrency` \<String> - The currency to be displayed on the widget (default: 'KRW'). Currently, only 'KRW', 'USD', and 'JPY' are supported.

#### Example

```dart
await wepinSDK.init(WidgetAttributes(defaultLanguage: 'ko', defaultCurrency: 'KRW'))
```

### isInitialized

```dart
wepinSDK.isInitialized()
```

The `isInitialized()` method checks if the Wepin Widget SDK is initialized.

#### Returns

- Future\<bool> - Returns `true` if Wepin Widget SDK is already initialized, otherwise false.

### changeLanguage
```dart
wepinSDK.changeLanguage({language, currency})
```

The `changeLanguage()` method changes the language and currency of the widget.

#### Parameters
- `language` \<String> - The language to be displayed on the widget. Currently, only 'ko', 'en', and 'ja' are supported.
- `currency` \<String> - The currency to be displayed on the widget. Currently, only 'KRW', 'USD', and 'JPY' are supported.

#### Returns
- void

#### Example

```dart
wepinSDK.changeLanguage(
  language: 'ko',
  currency: 'KRW'
);
```

### getStatus
```dart
await wepinSDK.getStatus()
```

The `getStatus()` method returns the lifecycle status of Wepin SDK.

#### Parameters
- None

#### Returns
- Future\<WepinLifeCycle> - Returns the current lifecycle of the Wepin SDK, which is defined as follows:
     - `notInitialized`:  Wepin is not initialized.
     - `initializing`: Wepin is in the process of initializing.
     - `initialized`: Wepin is initialized.
     - `beforeLogin`: Wepin is initialized but the user is not logged in.
     - `login`:The user is logged in.
     - `loginBeforeRegister`: The user is logged in but not registered in Wepin.

#### Example

```dart
final status = await wepinSDK.getStatus();
```


## ⏩ Method & Variable

Methods and Variables can be used after initialization of Wepin Widget SDK.

### login

The `login` variable is a Wepin login library that includes various authentication methods, allowing users to log in using different approaches. It supports email and password login, OAuth provider login, login using ID tokens or access tokens, and more. For detailed information on each method, please refer to the official library documentation at [wepin_flutter_login_lib](https://pub.dev/packages/wepin_flutter_login_lib).

#### Available Methods
- `loginWithOauthProvider`
- `signUpWithEmailAndPassword`
- `loginWithEmailAndPassword`
- `loginWithIdToken`
- `loginWithAccessToken`
- `getRefreshFirebaseToken`
- `loginFirebaseWithOauthProvider`
- `loginWepinWithOauthProvider`
- `loginWepinWithIdToken`
- `loginWepinWithAccessToken`
- `loginWepinWithEmailAndPassword`
- `loginWepin`
- `getCurrentWepinUser`
- `logout`
- `getSignForLogin`

These methods support various login scenarios, allowing you to select the appropriate method based on your needs.

For detailed usage instructions and examples for each method, please refer to the official library documentation. The documentation includes explanations of parameters, return values, exception handling, and more.

#### Example
```dart
// Login using an OAuth provider
final oauthResult = await wepinSDK.login.loginWithOauthProvider(provider: 'google', clientId: 'your-client-id');

// Sign up and log in using email and password
final signUpResult = await wepinSDK.login.signUpWithEmailAndPassword(email: 'example@example.com', password: 'password123');

// Log in using an ID token
final idTokenResult = await wepinSDK.login.loginWithIdToken(idToken: 'your-id-token', sign: 'your-sign');

// Log in to Wepin
final wepinLoginResult = await wepinSDK.login.loginWepin(idTokenResult);

// Get the currently logged-in user
final currentUser = await wepinSDK.login.getCurrentWepinUser();

// Logout
await wepinSDK.login.logout();

```

For more details on each method and to see usage examples, please visit the official  [wepin_flutter_login_lib documentation](https://pub.dev/packages/wepin_flutter_login_lib).

### loginWithUI
```dart
await wepinSDK.loginWithUI(BuildContext context, {required List<LoginProvider> loginProviders, String? email})
```
The loginWithUI() method provides the functionality to log in using a widget and returns the information of the logged-in user. If a user is already logged in, the widget will not be displayed, and the method will directly return the logged-in user's information. To perform a login without the widget, use the loginWepin() method from the login variable instead.

> [!CAUTION]
> This method can only be used after the authentication key has been deleted from the [Wepin Workspace](https://workspace.wepin.io/).
> (Wepin Workspace > Development Tools menu > Login tab > Auth Key > Delete)
> > * The Auth Key menu is visible only if an authentication key was previously generated.

#### Supported Version
Supported from version *`0.0.4`* and later.

#### Parameters
- context \<BuildContext> - The `BuildContext` parameter is essential in Flutter as it represents the location of a widget in the widget tree. This context is used by Flutter to locate the widget's position in the tree and to provide various functions like navigation, accessing theme data, and more. When you call `loginWithUI`, you pass the current context to ensure that the widget is displayed within the correct part of the UI hierarchy.
- loginProviders \<List\<LoginProvider>> - An array of login providers to configure the widget. If an empty array is provided, only the email login function is available.
  - provider \<String> - The OAuth login provider (e.g., 'google', 'naver', 'discord', 'apple').
  - clientId \<String> - The client ID of the OAuth login provider.
- email \<String> - __optional__ The email parameter allows users to log in using the specified email address when logging in through the widget.

> [!NOTE]
> For details on setting up OAuth providers, refer to the [OAuth Login Provider Setup section](#oauth-login-provider-setup).

#### Returns
- Future\<WepinUser>
  - status \<'success'|'fail'>
  - userInfo \<WepinUserInfo> __optional__
    - userId \<String>
    - email \<String>
    - provider \<'google'|'apple'|'naver'|'discord'|'email'|'external_token'>
    - use2FA \<bool>
  - userStatus: \<WepinUserStatus> - The user's status in Wepin login, including:
    - loginStatus: \<'complete' | 'pinRequired' | 'registerRequired'> - If the user's `loginStatus` value is not complete, registration in Wepin is required.
    - pinRequired?: <bool> 
  - walletId \<String> __optional__
  - token \<WepinToken> - Wepin Token

#### Exception
- [WepinError](#WepinError)

#### Example
```dart
// google, apple, discord, naver login
final userInfo = await wepinSDK.loginWithUI(context,
  loginProviders: [
    {
      provider: 'google',
      clientId: 'google-client-id'
    },
    {
      provider: 'apple',
      clientId: 'apple-client-id'
    },
    {
      provider: 'discord',
      clientId: 'discord-client-id'
    },
    {
      provider: 'naver',
      clientId: 'naver-client-id'
    },
  ]);

// only email login
final userInfo = await wepinSDK.loginWithUI(context,
  loginProviders: []);

//with specified email address
final userInfo = await wepinSDK.loginWithUI(context,
  loginProviders: [], email: 'abc@abc.com');
```

### openWidget
```dart
await wepinSDK.openWidget(BuildContext context)
```

The `openWidget()` method displays the Wepin widget. If a user is not logged in, the widget will not open. Therefore, you must log in to Wepin before using this method. To log in to Wepin, use the `loginWithUI` method or `loginWepin` method from the `login` variable.

#### Parameters
- context \<BuildContext> - The `BuildContext` parameter is essential in Flutter as it represents the location of a widget in the widget tree. This context is used by Flutter to locate the widget's position in the tree and to provide various functions like navigation, accessing theme data, and more. When you call `openWidget`, you pass the current context to ensure that the widget is displayed within the correct part of the UI hierarchy.

#### Returns
- Future \<void> - A `Future` that completes when the widget is successfully opened.

#### Example

```dart
await wepinSDK.openWidget(context);
```

### closeWidget
```dart
wepinSDK.closeWidget()
```

The `closeWidget()` method closes the Wepin widget.

#### Parameters
- None - This method does not take any parameters.

#### Returns
- `void` - This method does not return any value.

#### Example

```dart
wepinSDK.closeWidget();
```

### register
```dart
await wepinSDK.register(BuildContext context)
```

The `register` method registers the user with Wepin. After joining and logging in, this method opens the Register page of the Wepin widget, allowing the user to complete registration (wipe and account creation) for the Wepin service.

This method is only available if the lifecycle of the WepinSDK is `WepinLifeCycle.loginBeforeRegister`. After calling the `loginWepin()` method in the `login` variable, if the `loginStatus` value in the userStatus is not 'complete', this method must be called.

#### Parameters
- context \<BuildContext> - The `BuildContext` parameter is essential in Flutter as it represents the location of a widget in the widget tree. This context is used by Flutter to locate the widget's position in the tree and to provide various functions like navigation, accessing theme data, and more. When you call `register`, you pass the current context to ensure that the widget is displayed within the correct part of the UI hierarchy.

#### Returns
- Future\<WepinUser>
  - status \<'success'|'fail'>
  - userInfo \<WepinUserInfo> __optional__
    - userId \<String>
    - email \<String>
    - provider \<'google'|'apple'|'naver'|'discord'|'email'|'external_token'>
    - use2FA \<bool>
  - userStatus: \<WepinUserStatus> - The user's status in Wepin login, including:
    - loginStatus: \<'complete' | 'pinRequired' | 'registerRequired'> - If the user's `loginStatus` value is not complete, registration in Wepin is required.
    - pinRequired?: <bool> 
  - walletId \<String> __optional__
  - token \<WepinToken> - Wepin Token

#### Exception
- [WepinError](#WepinError)

#### Example

```dart
final userInfo = await wepinSDK.register(context);
```

### getAccounts

```dart
await wepinSDK.getAccounts({List<String>? networks, bool? withEoa})
```
The `getAccounts()` method returns user accounts. It is recommended to use this method without arguments to retrieve all user accounts. It can only be used after widget login.

##### Parameters
- networks: \<List\<String>> __optional__ A list of network names to filter the accounts.
- withEoa: \<bool> __optional__ Whether to include EOA accounts if AA accounts are included.

#### Returns
- Future \<List\<WepinAccount>> - A future that resolves to a list of the user's accounts.
  - address \<String>
  - network \<String>
  - contract \<String> __optional__ The token contract address.
  - isAA \<bool> __optional__  Whether it is an AA account or not.

#### Exception
- [WepinError](#WepinError)

#### Example
```dart
final result = await wepinSDK.getAccounts(
  networks: ['Ethereum'], 
  withEoa: true
)
```
- response
```dart
[
  WepinAccount(
    address: "0x0000001111112222223333334444445555556666",
    network: "Ethereum",
  ),
  WepinAccount(
    address: "0x0000001111112222223333334444445555556666",
    network: "Ethereum",
    contract: "0x777777888888999999000000111111222222333333",
  ),
  WepinAccount(
    address: "0x4444445555556666000000111111222222333333",
    network: "Ethereum",
    isAA: true,
  ),
]
```

### getBalance
```dart
await wepinSDK.getBalance({List<WepinAccount>? accounts})
```

The `getBalance()` method returns the balance information for specified accounts. It can only be used after the widget is logged in. To get the balance information for all user accounts, use the `getBalance()` method without any arguments.

#### Parameters
- accounts \<List\<WepinAccount>> __optional__ - A list of accounts for which to retrieve balance information.
  - network \<String> - The network associated with the account.
  - address \<String> - The address of the account.
  - isAA \<bool> __optional__ - Indicates whether the account is an AA (Account Abstraction) account.
  
#### Returns
- Future \<List\<WepinAccountBalanceInfo>> - A future that resolves to a list of balance information for the specified accounts.
  - network \<String> - The network associated with the account.
  - address \<String> - The address of the account.
  - symbol \<String> - The symbol of the account's balance.
  - balance \<String> - The balance of the account.
  - tokens \<List\<WepinTokenBalanceInfo>> - A list of token balance information for the account.
    - symbol \<String> - The symbol of the token.
    - balance \<String> - The balance of the token.
    - contract \<String> - The contract address of the token.

#### Exception
- [WepinError](#WepinError)

#### Example
```dart
final result = await wepinSDK.getBalance([WepinAccount(
  address: '0x0000001111112222223333334444445555556666',
  network: 'Ethereum',
)]);
```
- response
```dart
[
    WepinAccountBalanceInfo(
        network: "Ethereum",
        address: "0x0000001111112222223333334444445555556666",
        symbol: "ETH",
        balance: "1.1",
        tokens:[
            WepinTokenBalanceInfo(
                contract: "0x123...213",
                symbol: "TEST",
                balance: "10"
            ),
        ]
    )
]
```

### getNFTs

```dart
await wepinSDK.getNFTs({required bool refresh, List<String>? networks})
```
The `getNFTs()` method returns user NFTs. It is recommended to use this method without the networks argument to get all user NFTs. This method can only be used after the widget is logged in.

##### Parameters
- refresh \<bool> - A required parameter to indicate whether to refresh the NFT data.
- networks \<List\<String>> __optional__ - A list of network names to filter the NFTs.

#### Returns
- Future \<List\<WepinNFT>> - A future that resolves to a list of the user's NFTs.
  - account \<WepinAccount>
    - address \<String> - The address of the account associated with the NFT.
    - network \<String> - The network associated with the NFT.
    - contract \<String> __optional__ The token contract address.
    - isAA \<bool> __optional__ Indicates whether the account is an AA (Account Abstraction) account.
  - contract \<WepinNFTContract>
    - name \<String> - The name of the NFT contract.
    - address \<String> - The contract address of the NFT.
    - scheme \<String> - The scheme of the NFT.
    - description \<String> __optional__ - A description of the NFT contract.
    - network \<String> - The network associated with the NFT contract.
    - externalLink \<String> __optional__  - An external link associated with the NFT contract.
    - imageUrl \<String> __optional__ - An image URL associated with the NFT contract.
  - name \<String> - The name of the NFT.
  - description \<String> - A description of the NFT.
  - externalLink \<String> - An external link associated with the NFT.
  - imageUrl \<String> - An image URL associated with the NFT.
  - contentUrl \<String> __optional__ - A URL pointing to the content associated with the NFT.
  - quantity \<int> - The quantity of the NFT.
  - contentType \<String> - The content type of the NFT.
  - state \<int> - The state of the NFT.

#### Exception
- [WepinError](#WepinError)
  
#### Example
```dart
final result = await wepinSDK.getNFTs(refresh: true, networks: ['Ethereum']);
```
- response
```dart
[
  WepinNFT(
    account: WepinAccount(
      address: "0x0000001111112222223333334444445555556666",
      network: "Ethereum",
      contract: "0x777777888888999999000000111111222222333333",
      isAA: true,
    ),
    contract: WepinNFTContract(
      name: "NFT Collection",
      address: "0x777777888888999999000000111111222222333333",
      scheme: "ERC721",
      description: "An example NFT collection",
      network: "Ethereum",
      externalLink: "https://example.com",
      imageUrl: "https://example.com/image.png",
    ),
    name: "Sample NFT",
    description: "A sample NFT description",
    externalLink: "https://example.com/nft",
    imageUrl: "https://example.com/nft-image.png",
    contentUrl: "https://example.com/nft-content.png",
    quantity: 1,
    contentType: "image/png",
    state: 0,
  ),
]
```

### send
```dart
await wepinSDK.send(BuildContext context, {required WepinAccount account, WepinTxData? txData})
```

The `send()` method sends a transaction and returns the transaction ID information. This method can only be used after the widget is logged in.

#### Parameters
- context \<BuildContext> -  The `BuildContext` parameter is essential in Flutter as it represents the location of a widget in the widget tree. This context is used by Flutter to locate the widget's position in the tree and to provide various functions like navigation, accessing theme data, and more. When you call `send`, you pass the current context to ensure that the widget is displayed within the correct part of the UI hierarchy.
- account \<WepinAccount> - The account from which the transaction will be sent.
  - network \<String> - The network associated with the account.
  - address \<String>  - The address of the account.
  - contract \<String> __optional__ The contract address of the token.
- txData \<WepinTxData> __optional__ - The transaction data to be sent.
  - to \<String> - The address to which the transaction is being sent.
  - amount \<String> - The amount of the transaction.

#### Returns
- Future \<WepinSendResponse> - A future that resolves to a response containing the transaction ID.
  - txId \<String> - The ID of the sent transaction.

#### Exception
- [WepinError](#WepinError)

#### Example
```dart
final result = await wepinSDK.send(context, {
    account: WepinAccount(
      address: '0x0000001111112222223333334444445555556666',
      network: 'Ethereum',
    ),
    txData: WepinTxData(
      to: '0x9999991111112222223333334444445555556666',
      amount: '0.1',
    )
})

// token send
final result = await wepinSDK.send(context, {
  account: WepinAccount(
    address: '0x0000001111112222223333334444445555556666',
    network: 'Ethereum',
    contract: '0x9999991111112222223333334444445555556666'
  ),
  txData: WepinTxData(
    to: '0x9999991111112222223333334444445555556666',
    amount: '0.1',
  )
})
```
- response
```dart
WepinSendResponse(
    txId: "0x76bafd4b700ed959999d08ab76f95d7b6ab2249c0446921c62a6336a70b84f32"
)
```

### receive
```dart
await wepinSDK.receive(BuildContext context, {required WepinAccount account})
```

The `receive` method opens the account information page associated with the specified account. This method can only be used after logging into Wepin.

#### Supported Version
Supported from version *`0.0.4`* and later.

#### Parameters
- context \<BuildContext> -  The `BuildContext` parameter is essential in Flutter as it represents the location of a widget in the widget tree. This context is used by Flutter to locate the widget's position in the tree and to provide various functions like navigation, accessing theme data, and more. When you call `receive`, you pass the current context to ensure that the widget is displayed within the correct part of the UI hierarchy.
- account \<WepinAccount> - Provides the account information for the page that will be opened.
  - network \<String> - The network associated with the account.
  - address \<String>  - The address of the account.
  - contract \<String> __optional__ The contract address of the token.

#### Returns
- Future \<WepinReceiveResponse> - A future that resolves to a `WepinReceiveResponse` object containing the information about the opened account.
  - account \<WepinAccount> - The account information of the page that was opened.
    - network \<String> - The network associated with the account.
    - address \<String>  - The address of the account.
    - contract \<String> __optional__ The contract address of the token. 

#### Exception
- [WepinError](#WepinError)

#### Example
```dart
// Opening an account page
final result = await wepinSDK.receive(context, {
    account: WepinAccount(
      address: '0x0000001111112222223333334444445555556666',
      network: 'Ethereum',
    ),
})

// Opening a token page
final result = await wepinSDK.receive(context, {
  account: WepinAccount(
    address: '0x0000001111112222223333334444445555556666',
    network: 'Ethereum',
    contract: '0x9999991111112222223333334444445555556666'
  ),
})
```
- response
```dart
WepinReceiveResponse(
    account: WepinAccount(
      address: '0x0000001111112222223333334444445555556666',
      network: 'Ethereum',
      contract: '0x9999991111112222223333334444445555556666'
  )
)
```


### finalize
```dart
await wepinSDK.finalize()
```

The `finalize()` method finalizes the Wepin SDK, releasing any resources or connections it has established.

#### Parameters
 - None - This method does not take any parameters.
 - 
#### Returns
 - Future\<void> - A future that completes when the SDK has been finalized.

#### Example
```dart
await wepinSDK.finalize();
```


### WepinError

This section provides descriptions of various error codes that may be encountered while using the Wepin SDK functionalities. Each error code corresponds to a specific issue, and understanding these can help in debugging and handling errors effectively.

| Error Code                     | Error Message                    | Error Description                                                                                                                                                                                       |
| ------------------------------ | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `invalidAppKey`          	 | "InvalidAppKey"            	   | The Wepin app key is invalid.                                                                                                                                                                        	|
| `invalidParameters` `    	 | "InvalidParameters" 	 	   | One or more parameters provided are invalid or missing.                                                                                                                                              	|
| `invalidLoginProvider`    	 | "InvalidLoginProvider"     	   | The login provider specified is not supported or is invalid.                                                                                                                                         	|
| `invalidToken`             	 | "InvalidToken"            	   | The token does not exist.                                                                                                                                                                            	|
| `invalidLoginSession`    	 | "InvalidLoginSession"      	   | The login session information does not exist.                                                                                                                                                        	|
| `notInitialized`     		 | "NotInitialized"       	   | The WepinLoginLibrary has not been properly initialized.                                                                                                                                             	|
| `alreadyInitialized` 		 | "AlreadyInitialized"            | The WepinLoginLibrary is already initialized, so the logout operation cannot be performed again.                                                                                                     	|
| `userCancelled`           	 | "UserCancelled"           	   | The user has cancelled the operation.                                                                                                                                                                	|
| `unknownError`            	 | "UnknownError"       	   | An unknown error has occurred, and the cause is not identified.                                                                                                                                      	|
| `notConnectedInternet`   	 | "NotConnectedInternet"     	   | The system is unable to detect an active internet connection.                                                                                                                                        	|
| `failedLogin`             	 | "FailedLogin"     	 	   | The login attempt has failed due to incorrect credentials or other issues.                                                                                                                           	|
| `alreadyLogout`           	 | "AlreadyLogout"           	   | The user is already logged out, so the logout operation cannot be performed again.                                                                                                                   	|
| `invalidEmailDomain`     	 | "InvalidEmailDomain"       	   | The provided email address's domain is not allowed or recognized by the system.                                                                                                                      	|
| `failedSendEmail`         	 | "FailedSendEmail"           	   | The system encountered an error while sending an email. This is because the email address is invalid or we sent verification emails too often. Please change your email or try again after 1 minute. 	|
| `requiredEmailVerified`  	 | "RequiredEmailVerified"     	   | Email verification is required to proceed with the requested operation.                                                                                                                              	|
| `incorrectEmailForm`      	 | "incorrectEmailForm"        	   | The provided email address does not match the expected format.                                                                                                                                      	|
| `incorrectPasswordForm`   	 | "IncorrectPasswordForm"     	   | The provided password does not meet the required format or criteria.                                                                                                                                 	|
| `notInitializedNetwork`   	 | "NotInitializedNetwork" 	  	   | The network or connection required for the operation has not been properly initialized.                                                                                                              	|
| `requiredSignupEmail`     	 | "RequiredSignupEmail"       	   | The user needs to sign up with an email address to proceed.                                                                                                                                          	|
| `failedEmailVerified`     	 | "FailedEmailVerified"       	   | The WepinLoginLibrary encountered an issue while attempting to verify the provided email address.                                                                                                    	|
| `failedPasswordStateSetting`   | "FailedPasswordStateSetting"    | Failed to set the password state. This error may occur during password management operations, potentially due to invalid input or system issues.                                                   	|
| `failedPasswordSetting` 	 | "failedPasswordSetting"         | Failed to set the password. This could be due to issues with the provided password or internal errors during the password setting process.                                                              |
| `existedEmail`                 | "ExistedEmail"           	   | The provided email address is already registered. This error occurs when attempting to sign up with an email that is already in use.                               					|
| `apiRequestError`              | "ApiRequestError"               | There was an error while making the API request. This can happen due to network issues, invalid endpoints, or server errors.                                                                            |
| `incorrectLifecycleException`  | "IncorrectLifecycleException"   |The lifecycle of the Wepin SDK is incorrect for the requested operation. Ensure that the SDK is in the correct state (e.g., `initialized` and `login`) before proceeding.  |
| `failedRegister`             	 | "FailedRegister"           	   | Failed to register the user. This can occur due to issues with the provided registration details or internal errors during the registration process.                                                    |
| `accountNotFound`              | "AccountNotFound"           	   | The specified account was not found. This error is returned when attempting to access an account that does not exist in the Wepin.                                                                      |
| `nftNotFound`             	 | "NftNotFound"           	   | The specified NFT was not found. This error occurs when the requested NFT does not exist or is not accessible within the user's account.                                                                |
| `failedSend`             	 | "FailedSend"           	   | Failed to send the required data or request. This error could be due to network issues, incorrect data, or internal server errors.                                                                      |

