# mobile

A new Flutter project.

## Flutter version

```console
[✓] Flutter (Channel stable, 3.19.5, on macOS 14.4.1 23E224 darwin-arm64, locale en-IN)
[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 15.1)
[✓] Chrome - develop for the web
[✓] Android Studio (version 2022.3)
[✓] VS Code (version 1.87.2)
```

## Generate injectable

```console
flutter packages pub run build_runner build
```

## Generate Envied

```console
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

## Generate JSON Serializables

```console
flutter pub run build_runner build --delete-conflicting-outputs
```

## Generate Localizations

```console
flutter pub run easy_localization:generate -f keys -o locale_keys.g.dart -S assets/translations
```

## Generate Launcher Icons

```console
flutter pub run flutter_launcher_icons -f flutter_launcher_icons.yaml
```

## Generate Splash Screen

```console
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
```

## Testing Firebase ANalytics in Debug View

```console
adb shell setprop debug.firebase.analytics.app packagename
```

## change theme for web3modal_flutter

## packages/web3modal_flutter/lib/widgets/web3modal.dart

## packages/web3modal_flutter/lib/widgets/navigation/navbar.dart

```
wallet list is being made by following
```

## packages/web3modal_flutter/lib/pages/wallets_list_short_page.dart

## notes for reown_appkit package for wallet connect

### file name : packages/reown_appkit/lib/modal/pages/public/appkit_modal_main_wallets_page.dart

`title: '지갑연결', //'Connect wallet',` change for model tile text to korean

## Steps to include custom wallet inside reown_appkit package

1- add the wallet in listing inside `packages/reown_appkit/lib/modal/services/explorer_service/explorer_service.dart` in ` _listings` as below, where a custom object of ReownAppKitModalWalletInfo for phantom

```
 _listings = [
      ReownAppKitModalWalletInfo(
        listing: Listing.fromJson({
          'id': 'wepin-custom',
          'name': 'Wepin',
          'image_id':
              'https://dev-admin.hidemeplease.xyz/assets/244989c6-90e3-428f-b2a7-0316174240c1',
          'homepage': 'https://www.wepin.io/',
          'order': 4,
          // 'mobile_link': schema,
        }),
        installed: true,
        recent: true,
      ),
      ReownAppKitModalWalletInfo(
        listing: Listing.fromJson({
          'id': 'phantom-custom',
          'name': 'Phantom',
          'image_id':
              'https://firebasestorage.googleapis.com/v0/b/hidemeplease2024-dev.appspot.com/o/public%2Fphantom-wallet.png?alt=media&token=9ad22838-f0b0-4d31-b603-9ca0725963aa',
          'homepage': 'https://phantom.app/',
          'order': 5,
          // 'mobile_link': schema,
        }),
        installed: true,
        recent: true,
      ),
      //...allListings[0],
      ...allListings[2].sortByFeaturedIds(featuredWalletIds),
      ...allListings[1].sortByFeaturedIds(featuredWalletIds),
      ...allListings[3].sortByFeaturedIds(featuredWalletIds),
    ];
```

2- in file `packages/reown_appkit/lib/modal/pages/public/appkit_modal_main_wallets_page.dart`

```
 onTapWallet: (data) {
                service.selectWallet(data);
                widgetStack.instance.push(const ConnectWalletPage());
              },

```

replace above with checking if data.listing.id == 'THE WALLET ID IS SET INSIDE' `packages/reown_appkit/lib/modal/services/explorer_service/explorer_service.dart` in step 1

```
 onTapWallet: (data) {

                if (data.listing.id == 'phantom-custom') {
                  service.selectWallet(data);
                  service.closeModal();
                  return;
                }

                 if (data.listing.id == 'wepin-custom') {
                  service.selectWallet(data);
                  service.closeModal();
                  return;
                }

                service.selectWallet(data);
                widgetStack.instance.push(const ConnectWalletPage());
              },

```
