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

### file name : lib/modal/pages/public/appkit_modal_main_wallets_page.dart

`title: '지갑연결', //'Connect wallet',` change for model tile text to korean

### add trailing comma instead of RECENT text inside packages/reown_appkit/lib/modal/widgets/lists/wallets_list.dart

```
  trailing: Icon(Icons.arrow_forward_ios,
                      size: 17, color: Color(0x4DFFFFFF))
                  // trailing: listItem.data.recent
                  //     ? const WalletItemChip(value: ' RECENT ')
                  //     : null,

```

to disable checkmark make showCheckmark as false

showCheckmark: false, //listItem.data.installed,

inside below packages/reown_appkit/lib/modal/widgets/lists/wallets_list.dart:54

```
itemList.map(
            (listItem) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: WalletListItem(
                  onTap: () => onTapWallet?.call(listItem.data),
                  showCheckmark: false, //listItem.data.installed,
                  imageUrl: listItem.image,
                  title: listItem.title,
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 17, color: Color(0x4DFFFFFF))
                  // trailing: listItem.data.recent
                  //     ? const WalletItemChip(value: ' RECENT ')
                  //     : null,
                  ),
            ),
          );
```

### change wallet title text style packages/reown_appkit/lib/modal/widgets/lists/list_items/wallet_list_item.dart:87

```
 child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                  letterSpacing: 1,
                  height: 1.7,
                ),
                // style: themeData.textStyles.paragraph500.copyWith(
                //   color: onTap == null
                //       ? themeColors.foreground200
                //       : themeColors.foreground100,
                //),
              ),
            ),
```

### to change navbar packages/reown_appkit/lib/modal/widgets/navigation/navbar.dart

```
 SafeArea(
            left: true,
            right: true,
            top: false,
            bottom: false,
            child: SizedBox(
              height: kNavbarHeight,
              child: ValueListenableBuilder(
                valueListenable: widgetStack.instance.onRenderScreen,
                builder: (context, render, _) {
                  if (!render) return SizedBox.shrink();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // widgetStack.instance.canPop() && !noBack
                      //     ? NavbarActionButton(
                      //         asset: 'lib/modal/assets/icons/chevron_left.svg',
                      //         action: onBack ?? widgetStack.instance.pop,
                      //       )
                      //     : (leftAction ??
                      //         const SizedBox.square(dimension: kNavbarHeight)),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: GestureDetector(
                          onTap: () => onTapTitle?.call(),
                          child: Center(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.1,
                                height: 1.4,
                              ),
                              // style: themeData.textStyles.paragraph600.copyWith(
                              //   color: themeColors.foreground100,
                              // ),
                            ),
                          ),
                        ),
                      ),
                      noClose
                          ? const SizedBox.square(dimension: kNavbarHeight)
                          : NavbarActionButton(
                              asset: 'lib/modal/assets/icons/close.svg',
                              action: () {
                                ModalProvider.of(context).instance.closeModal();
                              },
                            ),
                      // Row(
                      //   children: rightActions,
                      // ),
                    ],
                  );
                },
              ),
            ),
          ),
          Divider(color: Color(0x0DFFFFFF), height: 1.0),
          Flexible(
            child: SafeArea(
              left: safeAreaLeft,
              right: safeAreaRight,
              bottom: safeAreaBottom,
              child: body,
            ),
          ),
```

### color Scheme

1-changing the background Color of wallet connect bottom model
file Path ===> lib/modal/widgets/modal_container.dart

```
 // decoration: BoxDecoration(
          //   border: Border.all(
          //     color: themeColors.grayGlass005,
          //     width: 1,
          //   ),
          //   color: themeColors.background125,
          // ),
          decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFF0C0C0E), //themeColors.grayGlass005,
                //color: themeColors.grayGlass005,
                width: 1,
              ),
              color: Color(0xFF0C0C0E)
              //color: themeColors.background125,
              ),
```

## remove all wallets tile inside bottom model

comment out /items.addAll(bottomItems); inside file lib/modal/widgets/lists/wallets_list.dart:70

```
 if (bottomItems.isNotEmpty) {
      //items.addAll(bottomItems);
    }

```

### remove empty space at bottom of model widget

```
 double maxHeight = isPortrait
        ? (kListItemHeight * 5)
        : ResponsiveData.maxHeightOf(context);
```

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
