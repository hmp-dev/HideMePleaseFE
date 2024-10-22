import 'package:flutter/material.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';
import 'package:wepin_flutter_widget_sdk_example/widgets/account_selection.dart';
import 'package:wepin_flutter_widget_sdk_example/widgets/balance_list.dart';
import 'package:wepin_flutter_widget_sdk_example/widgets/nft_list.dart';
import 'package:wepin_flutter_widget_sdk_example/widgets/transaction_dialog.dart';
import 'package:wepin_flutter_widget_sdk_example/widgets/user_drawer.dart';
import 'values/sdk_app_info.dart';
import 'widgets/email_login_dialog.dart';
import 'widgets/custom_dialog.dart';

class WepinSDKScreen extends StatefulWidget {
  const WepinSDKScreen({super.key});
  @override
  WepinSDKScreenState createState() => WepinSDKScreenState();
}

class WepinSDKScreenState extends State<WepinSDKScreen> {
  final Map<String, String> currency = {
    'ko': 'KRW',
    'en': 'USD',
    'ja': 'JPY',
  };

  WepinWidgetSDK? wepinSDK;
  String? selectedLanguage = 'ko';
  String? selectedValue = sdkConfigs[0]['name'];

  WepinLifeCycle wepinStatus = WepinLifeCycle.notInitialized;
  String userEmail = '';
  List<WepinAccount> selectedAccounts = [];
  List<WepinAccount> accountsList = [];
  List<WepinAccountBalanceInfo> balanceList = [];
  List<WepinNFT> nftList = [];
  bool isLoading = false;
  String? privateKey;
  List<LoginProvider> loginProviders = sdkConfigs[0]['loginProviders'];
  List<LoginProvider> selectedSocialLogins = sdkConfigs[0]['loginProviders'];


  @override
  void initState() {
    super.initState();
    setLoginInfo();
  }

  void setLoginInfo() {
    final selectedConfig = sdkConfigs.firstWhere((config) => config['name'] == selectedValue);
    _updateConfig(selectedConfig);
    initWepinSDK(selectedConfig['appId']!, selectedConfig['appKey']!, selectedConfig['privateKey']!);
  }

  void _updateConfig(Map<String, dynamic> config) {
    setState(() {
      privateKey = config['privateKey'];
      loginProviders = config['loginProviders'];
      selectedSocialLogins = config['loginProviders'];
    });
  }

  Future<void> initWepinSDK(String appId, String appKey, String privateKey) async {
    wepinSDK?.finalize();
    wepinSDK = WepinWidgetSDK(wepinAppKey: appKey, wepinAppId: appId);
    await wepinSDK!.init(attributes: WidgetAttributes(defaultLanguage: selectedLanguage!, defaultCurrency: currency[selectedLanguage!]!));
    wepinStatus = await wepinSDK!.getStatus();
    userEmail = wepinStatus == WepinLifeCycle.login ? (await wepinSDK!.login.getCurrentWepinUser())?.userInfo?.email ?? '' : '';

    if (wepinStatus == WepinLifeCycle.notInitialized) {
      showError('WepinSDK is not initialized.');
    }
    setState(() {});
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(message: message, isError: true),
    );
  }

  void showSuccess(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(title: title, message: message),
    );
  }

  Future<void> performActionWithLoading(Function action) async {
    setState(() => isLoading = true);
    try {
      await action();
    } catch(e){
      showError(e.toString());
    }finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> navigateToAccountSelection({bool? selection, bool? allowMultiSelection, bool? withoutToken}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountSelectionScreen(
          getAccounts: accountsList,
          selection: selection,
          allowMultiSelection: allowMultiSelection?? false,
          withoutToken: withoutToken,
        ),
      ),
    );

    if (result != null) {
      setState(() => selectedAccounts = result);
    }
  }

  Future<void> navigateToBalanceList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BalanceListScreen(balanceList: balanceList)),
    );
  }

  Future<void> navigateToNftList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WepinNFTListScreen(wepinNFTs: nftList)),
    );
  }

  Future<void> loginWithProvider(String provider, String? clientId) async {
    await performActionWithLoading(() async {
      try {
        final oauthToken = await wepinSDK!.login.loginWithOauthProvider(provider: provider, clientId: clientId!);
        final idToken = oauthToken?.token;
        final sign = wepinSDK?.login.getSignForLogin(privateKey: privateKey!, message: idToken!);
        final type = oauthToken?.type;

        LoginResult? fbToken;
        if (type == WepinOauthTokenType.idToken) {
          fbToken = await wepinSDK!.login.loginWithIdToken(idToken: idToken!, sign: sign!);
        } else {
          fbToken = await wepinSDK!.login.loginWithAccessToken(provider: provider, accessToken: idToken!, sign: sign!);
        }

        final wepinUser = await wepinSDK?.login.loginWepin(fbToken);
        userEmail = wepinUser!.userInfo!.email;
        wepinStatus = await wepinSDK!.getStatus();
      } catch (e) {
        if (!e.toString().contains('UserCancelled')) {
          showError('Login Failed. (error code - $e)');
        }
      }
    });
  }

  Future<void> loginWithEmail(String email, String password) async {
    await performActionWithLoading(() async {
      try {
        final fbToken = await wepinSDK!.login.loginWithEmailAndPassword(email: email, password: password);
        final wepinUser = await wepinSDK?.login.loginWepin(fbToken);
        userEmail = wepinUser!.userInfo!.email;
        wepinStatus = await wepinSDK!.getStatus();
      } catch (e) {
        if (e.toString().contains('RequiredSignupEmail')) {
          showError('Required Signup Email. error code - $e');
        } else {
          showError('Login Failed. (error code - $e)');
        }
      }
    });
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await performActionWithLoading(() async {
      try {
        final fbToken = await wepinSDK!.login.singUpWithEmailAndPassword(email: email, password: password);
        final wepinUser = await wepinSDK?.login.loginWepin(fbToken);
        userEmail = wepinUser!.userInfo!.email;
        wepinStatus = await wepinSDK!.getStatus();
      } catch (e) {
        if (e.toString().contains('ExistEmail')) {
          showError('Exist Email Address. (error code - $e)');
        } else {
          showError('Signup Failed. (error code - $e)');
        }
      }
    });
  }

  void getStatus() async {
    await performActionWithLoading(() async {
      if (wepinSDK != null) {
        wepinStatus = await wepinSDK!.getStatus();
      }
    });
  }

  Future<void> _sendTransaction(WepinTxData? txData) async {
    try {
      final sendRes = await wepinSDK!.send(
        context,  // Assuming context is available or refactor to avoid its usage
        account: selectedAccounts[0],
        txData: txData,
      );
      wepinStatus = await wepinSDK!.getStatus();
      showSuccess('Send completed', '$sendRes');
    } catch (e) {
      showError(e.toString());
    }
  }

  Future<void> _loginWithUI({String? email}) async {
    try {
      final loginRes = await wepinSDK!.loginWithUI(
        context,  // Assuming context is available or refactor to avoid its usage
        loginProviders: selectedSocialLogins,
        email: email
      );

      userEmail = loginRes!.userInfo!.email;
      getStatus();
      showSuccess('loginWithUI completed', '$loginRes');
    } catch (e) {
      showError(e.toString());
    }
  }

  Future<void> _receiveAccount() async {
    try {
      final sendRes = await wepinSDK!.receive(
        context,  // Assuming context is available or refactor to avoid its usage
        account: selectedAccounts[0],
      );
      wepinStatus = await wepinSDK!.getStatus();
      showSuccess('Receive completed', '$sendRes');
    } catch (e) {
      showError(e.toString());
    }
  }

  // Function to find clientId by provider
  String? findClientIdByProvider(String provider) {
    Map<String, String> providerToClientIdMap = {
      for (var provider in loginProviders) provider.provider: provider.clientId
    };
    return providerToClientIdMap[provider];
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wepin SDK Example'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (wepinSDK != null) ...[
                  const SizedBox(height: 16.0),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text('Wepin Status: $wepinStatus', style: const TextStyle(fontSize: 16)),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                        onPressed: getStatus,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16.0),
                Expanded(
                  child: ListView(
                    children: [
                      if (wepinStatus == WepinLifeCycle.initialized) ...[
                        _buildActionButton('Login With UI', () async {
                            await _loginWithUI();
                        }),
                        _buildActionButton('Login With UI(specified Email)', () {
                          showDialog(
                            context: context,
                            builder: (ctx) => EmailLoginDialog(requirePassword: false, onLogin: _loginWithUI),
                          );
                        }),
                        _buildActionButton('Login with Google', () => loginWithProvider('google', findClientIdByProvider('google'))),
                        _buildActionButton('Login with Apple', () => loginWithProvider('apple', findClientIdByProvider('apple'))),
                        _buildActionButton('Login with Discord', () => loginWithProvider('discord', findClientIdByProvider('discord'))),
                        _buildActionButton('Login with Naver', () => loginWithProvider('naver', findClientIdByProvider('naver'))),
                        _buildActionButton('SignUp with Email', () {
                          showDialog(
                            context: context,
                            builder: (ctx) => EmailLoginDialog(onLogin: signUpWithEmail),
                          );
                        }),
                        _buildActionButton('Login with Email', () {
                          showDialog(
                            context: context,
                            builder: (ctx) => EmailLoginDialog(onLogin: loginWithEmail),
                          );
                        }),
                      ],
                      if (wepinStatus == WepinLifeCycle.login) ...[
                        _buildActionButton('Open Widget', () => wepinSDK!.openWidget(context)),
                        _buildActionButton('Get Accounts', () async {
                          await performActionWithLoading(() async {
                            accountsList = await wepinSDK!.getAccounts();
                            wepinStatus = await wepinSDK!.getStatus();
                            navigateToAccountSelection(selection: false);
                          });
                        }),
                        _buildActionButton('Get NFTs', () async {
                          await performActionWithLoading(() async {
                            nftList = await wepinSDK!.getNFTs(refresh: false);
                            wepinStatus = await wepinSDK!.getStatus();
                            navigateToNftList();
                          });
                        }),
                        _buildActionButton('Get NFTs(with refresh)', () async {
                          await performActionWithLoading(() async {
                            nftList = await wepinSDK!.getNFTs(refresh: true);
                            wepinStatus = await wepinSDK!.getStatus();
                            navigateToNftList();
                          });
                        }),
                        if (accountsList.isNotEmpty) ...[
                          _buildActionButton('Account List View', () => navigateToAccountSelection(selection: false)),
                          _buildActionButton('Receive', () async {
                            await navigateToAccountSelection(selection: true, allowMultiSelection: false, withoutToken: false);
                            if(context.mounted && selectedAccounts.isNotEmpty) {
                              await _receiveAccount();
                            }
                          }),

                          _buildActionButton('Get Balance', () async {
                            await navigateToAccountSelection(selection: true, allowMultiSelection: true, withoutToken: true);
                            if(selectedAccounts.isNotEmpty) {
                              await performActionWithLoading(() async {
                                balanceList = await wepinSDK!.getBalance(
                                    accounts: selectedAccounts);
                                wepinStatus = await wepinSDK!.getStatus();
                                navigateToBalanceList();
                              });
                            }
                          }),
                          _buildActionButton('Send', () async {
                            await navigateToAccountSelection(selection: true, allowMultiSelection: false, withoutToken: false);
                            if(context.mounted && selectedAccounts.isNotEmpty) {
                              final txData = await showTransactionDialog(context);
                              await _sendTransaction(txData);
                            }
                          }),
                          if (balanceList.isNotEmpty)
                            _buildActionButton('Account Balance List View', navigateToBalanceList),
                        ],
                        _buildActionButton('Logout', () async {
                          await performActionWithLoading(() async {
                            await wepinSDK!.login.logoutWepin();
                            selectedAccounts = [];
                            accountsList = [];
                            userEmail = '';
                            wepinStatus = await wepinSDK!.getStatus();
                          });
                        }),
                      ],
                      if (wepinStatus == WepinLifeCycle.loginBeforeRegister) ...[
                        _buildActionButton('Register', () async {
                          await performActionWithLoading(() async {
                            await wepinSDK!.register(context);
                            wepinStatus = await wepinSDK!.getStatus();
                          });
                        }),
                        _buildActionButton('Logout', () async {
                          await performActionWithLoading(() async {
                            await wepinSDK!.login.logoutWepin();
                            userEmail = '';
                            wepinStatus = await wepinSDK!.getStatus();
                          });
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            ModalBarrier(color: Colors.black.withOpacity(0.5), dismissible: false),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      endDrawer: UserDrawer(
        userEmail: userEmail,
        wepinStatus: wepinStatus,
        selectedLanguage: selectedLanguage!,
        selectedMode: selectedValue,
        sdkConfigs: sdkConfigs,
        currency: currency,
        onModeChanged: (value) {
          selectedValue = value;
          final selectedConfig = sdkConfigs.firstWhere((config) => config['name'] == value);
          _updateConfig(selectedConfig);
          initWepinSDK(selectedConfig['appId']!, selectedConfig['appKey']!, selectedConfig['privateKey']!);
        },
        onLanguageChanged: (value) {
          setState(() {
            selectedLanguage = value;
            if (wepinSDK != null) {
              wepinSDK?.changeLanguage(
                language: selectedLanguage,
                currency: currency[selectedLanguage]!,
              );
            }
          });
        },
        socialLogins: loginProviders, // List of social logins
        selectedSocialLogins: selectedSocialLogins, // Initially selected social logins
        onSocialLoginsChanged: (selectedLogins) {
          setState(() {
            selectedSocialLogins = selectedLogins;
            print('Selected social logins: $selectedLogins');
          });
        }, // Handle changes
      ),
    );
  }
}
