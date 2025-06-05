import 'package:flutter/material.dart';

class AccountSelector extends StatefulWidget {
  const AccountSelector({super.key});

  @override
  AccountSelectorState createState() => AccountSelectorState();
}

class AccountSelectorState extends State<AccountSelector> {
  String? _selectedAccount;

  // Placeholder list of accounts
  final List<String> _accounts = ['Account 1', 'Account 2'];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Select Account',
        border: OutlineInputBorder(),
      ),
      value: _selectedAccount,
      items: _accounts.map((String account) {
        return DropdownMenuItem<String>(
          value: account,
          child: Text(account),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedAccount = newValue;
        });
      },
    );
  }
}