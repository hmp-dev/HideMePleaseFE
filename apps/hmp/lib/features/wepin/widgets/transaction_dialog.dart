import 'package:flutter/material.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

class TransactionDialog extends StatelessWidget {
  const TransactionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController addressController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    return AlertDialog(
      title: const Text('Enter Transaction Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'To Address',
            ),
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null); // Cancel the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(WepinTxData(
              toAddress: addressController.text,
              amount: amountController.text,
            )); // Return the inputted txData
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

Future<WepinTxData?> showTransactionDialog(BuildContext context) {
  return showDialog<WepinTxData>(
    context: context,
    builder: (BuildContext context) {
      return const TransactionDialog();
    },
  );
}
