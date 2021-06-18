import 'package:enstagram/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  String? _username;
  submit() {
    final formKey = _formKey.currentState;
    if (_formKey.currentState!.validate()) {
      formKey?.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome $_username'),
          duration: Duration(microseconds: 200),
        ),
      );
      Navigator.pop(context, _username);
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(context,
          titleText: 'Set up your profile', removeBackButton: true),
      body: ListView(children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 25),
                child: Text(
                  'Create username',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (val) {
                        if (val!.trim().length < 6) {
                          return 'username too short';
                        } else if (val.trim().length > 15) {
                          return 'username too long';
                        } else
                          return null;
                      },
                      onSaved: (val) => _username = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'username',
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: 'Must be atleas 3 letters',
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: submit,
                child: Container(
                  height: 50,
                  width: 350,
                  margin: EdgeInsets.symmetric(horizontal: 45),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      color: Theme.of(context).primaryColor),
                  child: Text(
                    'submit',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
