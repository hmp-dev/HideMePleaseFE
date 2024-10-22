# 🚀 Wepin Widget SDK Migration Guide
To take advantage of the latest features offered by Wepin, you'll need to migrate from the existing `wepin_flutter` to `wepin_flutter_widget_sdk`. Follow the steps below to update your setup.

- Legacy Packages: [wepin_flutter](https://pub.dev/packages/wepin_flutter)

- Updated package: [wepin_flutter_widget_sdk](https://pub.dev/packages/wepin_flutter_widget_sdk)

## 1. Install the New Package
First, remove the existing `wepin_flutter` package and install `wepin_flutter_widget_sdk`.

```bash
# Remove the existing package
flutter pub remove wepin_flutter

# Install the new package
flutter pub add wepin_flutter_widget_sdk
```

## 2. Update Your Code
Change all import statements that reference `wepin_flutter` to `wepin_flutter_widget_sdk`.

- Legacy Packages([wepin_flutter](https://pub.dev/packages/wepin_flutter))
```dart
import 'package:wepin_flutter/wepin.dart';
import 'package:wepin_flutter/wepin_inputs.dart';
import 'package:wepin_flutter/wepin_outputs.dart';
```

- Updated Packages([wepin_flutter_widget_sdk](https://pub.dev/packages/wepin_flutter_widget_sdk))
```dart
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';
```

## 3. Update Configuration Settings
### 3.1 Android Deep Link Configuration
#### Legacy Packages([wepin_flutter](https://pub.dev/packages/wepin_flutter))
In legacy packages, the Android deep link was configured directly in the `AndroidManifest.xml` file. Below is an example of how it was set up:
```xml
<activity
    android:name=".MainActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- For Deep Link => Urlscheme Format: wepin. + appID -->
        <data
            android:scheme="wepin.88889999000000000000000000000000"
            />
    </intent-filter>
</activity>

```

#### Updated Packages([wepin_flutter_widget_sdk](https://pub.dev/packages/wepin_flutter_widget_sdk))
In the updated package, the deep link configuration has changed. Now, you must define the custom scheme through a manifest placeholder in the `build.gradle (app)` file. This allows the WepinWidget SDK to easily capture all redirects using the custom scheme.
```gradle
// For Deep Link => RedirectScheme Format: wepin. + Wepin App ID
android.defaultConfig.manifestPlaceholders = [
  'appAuthRedirectScheme': 'wepin.{{YOUR_WEPIN_APPID}}'
]
```

> [!NOTE]
> Setting up deep links is now mandatory in the updated package.
> <details>
>  <summary>See details</summary>
> Ensure that the custom scheme correctly matches your Wepin App ID.
> Remove the previous deep link settings from the AndroidManifest.xml file if migrating from the legacy setup.
> </details>

### 3.2 Camera Permission Configuration
In the updated package, adding camera permissions is required as the camera function is essential for recognizing addresses in QR code format.

#### Android
To configure camera permissions on Android, add the following permissions to your `AndroidManifest.xml` file:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.INTERNET" />
  <!-- ... -->
</manifest>
```

#### iOS
For iOS, you need to update both your `Podfile` and `Info.plist` files.

 - `Podfile`: Add a camera permission configuration in your `Podfile`:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
      # You can remove unused permissions here
      # for more information: https://github.com/BaseflowIT/flutter-permission-handler/blob/master/permission_handler/ios/Classes/PermissionHandlerEnums.h
      # e.g. when you don't need camera permission, just add 'PERMISSION_CAMERA=0'
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        ## dart: PermissionGroup.camera
        'PERMISSION_CAMERA=1',
        ]
    end
  end
end
```
 - `Info.plist`: Update your `Info.plist` with the required permission usage descriptions:
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
<details>
  <summary>Additional Notes</summary>
Replace "YOUR TEXT" with a description of why your app requires camera access.
Only include the permissions that are necessary for your application.
</details>

### 3.3 OAuth Login Provider Setup
If you want to use OAuth login functionality (e.g., loginWithUI), you need to set up OAuth login providers.
To do this, you must first register your OAuth login provider information in the [Wepin Workspace](https://workspace.wepin.io/). 
Navigate to the Login tab under the Developer Tools menu, click the Add or Set Login Provider button in the Login Provider section, and complete the registration.  

![image](https://github.com/user-attachments/assets/b7a7f6d3-69a7-4ee5-ab66-bad57a715fda)


## 4. Major Changes
Review the significant changes in the new SDK and modify your code accordingly. Here are some examples:

### 4.1 Initialization
- Legacy Packages([wepin_flutter](https://pub.dev/packages/wepin_flutter))
  ```dart
    Wepin _wepin = Wepin();
    _handleDeepLink(); // Add method in your app's 'initState()' for Handing Deeplink
    WidgetAttributes widgetAttributes = WidgetAttributes('ko', 'krw');
    WepinOptions wepinOptions =
    WepinOptions(_appId, _appSdkKey, widgetAttributes);
    _wepin.initialize(context, wepinOptions)
  
    ```
- Updated Packages([wepin_flutter_widget_sdk](https://pub.dev/packages/wepin_flutter_widget_sdk))
    ```dart
    WepinWidgetSDK wepinSDK = WepinWidgetSDK(wepinAppKey: wepinAppKey, wepinAppId: wepinAppId);
    await wepinSDK.init(WidgetAttributes(defaultLanguage: 'ko', defaultCurrency: 'KRW'))
    ```

In the updated package([wepin_flutter_widget_sdk](https://pub.dev/packages/wepin_flutter_widget_sdk)), there is no need to add a method for handling deep links manually.

### 4.2 Method Calls
Check if the method calling conventions have changed and update them if necessary.

#### login
- Legacy Packages([wepin_flutter](https://pub.dev/packages/wepin_flutter))
    ```dart
    await _wepin.login();
    ```

- Updated Packages([wepin_flutter_widget_sdk](https://pub.dev/packages/wepin_flutter_widget_sdk))
  - without UI
    > For more details on login operations, refer to the [wepin_flutter_login_lib plugin](https://pub.dev/packages/wepin_flutter_login_lib).
    ```dart
    final res = await wepinSDK.login.loginWithOauthProvider(
        provider: "google",
        clientId: "your-google-client-id"
    );
    
    final sign = wepinSDK.login.getSignForLogin(privateKey: privateKey, message: res!.token);
    LoginResult? resLogin;
    if(provider == 'naver' || provider == 'discord') {
      resLogin = await wepinSDK.login.loginWithAccessToken(provider: provider, accessToken: res!.token, sign: sign));
    } else {
      resLogin = await wepinSDK.login.loginWithIdToken(idToken: res!.token, sign: sign));
    }
    
    final userInfo = await wepinSDK.login.loginWepin(resLogin);
    final userStatus = userInfo.userStatus;
    if (userStatus.loginStatus == 'pinRequired' || userStatus.loginStatus == 'registerRequired') {
    // Wepin register
      await wepinSDK.register(context);
    }
    ```
  - with UI (Supported from version `0.0.4` and later.)
     ```dart
    // google, apple, discord, naver login
    final res = await wepinSDK.loginWithUI(context,
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
    final res = await wepinSDK.loginWithUI(context,
      loginProviders: []);
    
    //with specified email address
    final res = await wepinSDK.loginWithUI(context,
      loginProviders: [], email: 'abc@abc.com');
      
    if(res.userStatus.loginStatus != "complete"){
        final userInfo  = await wepinSDK.register(context);
    }
    ```

## 5. Testing
Once you have completed all the code changes, test your application to ensure all features are working correctly. Pay special attention to key functionalities such as login, logout, and fetching data.

## 6. Refer to the Documentation
For further changes and detailed information, refer to the official documentation of `wepin_flutter_widget_sdk`.

> [wepin_flutter_widget_sdk Documentation](https://github.com/WepinWallet/wepin-flutter-sdk-v1/blob/main/packages/wepin_flutter_widget_sdk/README.md)

By following this guide, you should be able to successfully migrate from `wepin_flutter` to `wepin_flutter_widget_sdk`. If you have any additional questions or need further assistance, please contact the support team at wepin.contact@iotrust.kr.
