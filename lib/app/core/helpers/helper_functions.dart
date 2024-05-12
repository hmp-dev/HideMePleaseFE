import 'package:mobile/app/core/enum/wallet_type.dart';
import 'package:intl/intl.dart';

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

String formatDate(DateTime dateTime) {
  // Define the desired date format
  final dateFormat = DateFormat('MM/dd HH:mm');

  // Format the DateTime object using the defined format
  return dateFormat.format(dateTime);
}

String formatDateGetMonthYear(String dateTimeString) {
  // Parse the string into a DateTime object
  DateTime dateTime = DateTime.parse(dateTimeString);

  // Define the desired date format
  final dateFormat = DateFormat('MM/yy');

  // Format the DateTime object using the defined format
  return dateFormat.format(dateTime);
}

String formatNumberWithCommas(String numberString) {
  final number = int.tryParse(numberString) ?? 0;
  final formatter = NumberFormat('#,###');
  return formatter.format(number);
}
