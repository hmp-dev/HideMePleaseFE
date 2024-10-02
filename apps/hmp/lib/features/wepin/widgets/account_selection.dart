import 'package:flutter/material.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

class AccountSelectionScreen extends StatefulWidget {
  final List<WepinAccount> getAccounts;
  final bool? selection;
  final bool? withoutToken;
  final bool allowMultiSelection;

  const AccountSelectionScreen({
    super.key,
    required this.getAccounts,
    this.selection,
    this.withoutToken,
    this.allowMultiSelection = false,
  });

  @override
  AccountSelectionScreenState createState() => AccountSelectionScreenState();
}

class AccountSelectionScreenState extends State<AccountSelectionScreen> {
  Set<WepinAccount> selectedAccounts = <WepinAccount>{};

  void toggleSelectAll() {
    setState(() {
      if (selectedAccounts.length == widget.getAccounts.length) {
        selectedAccounts.clear();
      } else {
        selectedAccounts = widget.getAccounts.toSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<WepinAccount> filteredAccounts = widget.withoutToken == true
        ? widget.getAccounts.where((account) => account.contract == null || account.contract!.isEmpty).toList()
        : widget.getAccounts;

    return PopScope(
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        Navigator.pop(context, <WepinAccount>[]);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Accounts'),
          actions: [
            if (widget.selection == true && widget.allowMultiSelection)
              TextButton(
                onPressed: toggleSelectAll,
                child: Text(
                  selectedAccounts.length == widget.getAccounts.length ? 'Deselect All' : 'Select All',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            if (widget.selection == true)
              IconButton(
                icon: const Icon(Icons.done, color: Colors.black54),
                onPressed: () {
                  Navigator.pop(context, selectedAccounts.toList());
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: filteredAccounts.length,
            itemBuilder: (context, index) {
              WepinAccount account = filteredAccounts[index];
              bool isSelected = selectedAccounts.contains(account);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  leading: Icon(
                    widget.selection == true
                        ? (isSelected ? Icons.check_box : Icons.check_box_outline_blank)
                        : (account.contract != null && account.contract!.isNotEmpty ? Icons.account_tree_outlined : Icons.account_balance_wallet_rounded),
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    account.network,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blueAccent : Colors.black,
                    ),
                  ),
                  // subtitle: Text(
                  //   account.contract != null && account.contract!.isNotEmpty ? 'Contract: ${account.contract}' : '',
                  //   style: const TextStyle(color: Colors.black54),
                  // ),
                  subtitle: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Address: ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        TextSpan(
                          text: '${account.address}\n',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        if(account.contract != null && account.contract!.isNotEmpty) ...[
                            const TextSpan(
                              text: 'Contract: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            TextSpan(
                              text: '${account.contract}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                        ]
                      ],
                    ),
                  ),
                  onTap: widget.selection == true
                      ? () {
                    setState(() {
                      if (widget.allowMultiSelection) {
                        if (isSelected) {
                          selectedAccounts.remove(account);
                        } else {
                          selectedAccounts.add(account);
                        }
                      } else {
                        selectedAccounts.clear();
                        selectedAccounts.add(account);
                      }
                    });
                  }
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
