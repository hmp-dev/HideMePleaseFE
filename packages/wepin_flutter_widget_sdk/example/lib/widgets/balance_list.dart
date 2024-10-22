import 'package:flutter/material.dart';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

class BalanceListScreen extends StatelessWidget {
  final List<WepinAccountBalanceInfo> balanceList;

  const BalanceListScreen({Key? key, required this.balanceList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance List'),
      ),
      body: Column(
        children: [
          if (balanceList.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            const Text('Balance List Accounts:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: balanceList.length,
                itemBuilder: (context, index) {
                  WepinAccountBalanceInfo account = balanceList[index];
                  List<WepinTokenBalanceInfo> tokens = account.tokens;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: tokens.isNotEmpty
                        ? ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      backgroundColor: Colors.grey[200],
                      collapsedBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      title: Text(
                        account.network,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
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
                            const TextSpan(
                              text: 'Balance: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            TextSpan(
                              text: '${account.balance} ${account.symbol}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      leading: const Icon(Icons.account_balance_wallet_rounded, color: Colors.green),
                      children: tokens.map((token) {
                        return ListTile(
                          tileColor: Colors.white,
                          title: Text(
                            'Contract: ${token.contract}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Balance: ${token.balance} ${token.symbol}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          leading: const Icon(Icons.account_tree_outlined, color: Colors.green),
                        );
                      }).toList(),
                    )
                        : ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      tileColor: Colors.grey[200], // ListTile의 배경 색상을 ExpansionTile과 동일하게 설정
                      title: Text(
                        account.network,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
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
                            const TextSpan(
                              text: 'Balance: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            TextSpan(
                              text: '${account.balance} ${account.symbol}',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      leading: const Icon(Icons.account_balance_wallet_rounded, color: Colors.green),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
