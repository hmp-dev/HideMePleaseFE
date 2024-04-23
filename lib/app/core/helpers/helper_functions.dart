import 'package:mobile/app/core/enum/wallet_type.dart';

String formatWalletAddress(String walletAddress) {
  if (walletAddress.length < 10) {
    return walletAddress; // Return the original address if it's too short
  }

  // Extract the first 6 characters and last 4 characters
  String prefix = walletAddress.substring(0, 6);
  String suffix = walletAddress.substring(walletAddress.length - 4);

  // Format the truncated address with ellipsis
  String formattedAddress = '$prefix...$suffix';

  return formattedAddress;
}

String getWalletProvider(String inputString) {
  String lowercaseInput = inputString.toLowerCase();
  for (WalletProvider provider in WalletProvider.values) {
    if (lowercaseInput.contains(provider.name.toLowerCase())) {
      return provider.name;
    }
  }
  return '';
}
