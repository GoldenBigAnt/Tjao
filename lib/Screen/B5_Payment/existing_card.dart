import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:tjao/helper/payment_service.dart';

class ExistingCardsPage extends StatefulWidget {
  const ExistingCardsPage({Key key}) : super(key: key);

  @override
  _ExistingCardsPageState createState() => _ExistingCardsPageState();
}

class _ExistingCardsPageState extends State<ExistingCardsPage> {

  List cards = [{
    'cardNumber': '4242424242424242',
    'expiryDate': '02/23',
    'cardHolderName': 'Nataliya',
    'cvvCode': '424',
    'showBackView': false,
  }, {
    'cardNumber': '5555555555554444',
    'expiryDate': '02/24',
    'cardHolderName': 'Daniel',
    'cvvCode': '165',
    'showBackView': false,
  }];

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  payViaExistingCard(BuildContext context, card) async {
    var response = await StripeService.payViaExistingCard(amount: '399', currency: 'EUR', card: card);
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: Text(response.message),
        duration: new Duration(microseconds: response.success == true ? 2000 : 3000),
      ),
    );
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Choose existing card'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                payViaExistingCard(context, cards[index]);
              },
              child: CreditCardWidget(
                cardNumber: cards[index]['cardNumber'],
                expiryDate: cards[index]['expiryDate'],
                cardHolderName: cards[index]['cardHolderName'],
                cvvCode: cards[index]['cvvCode'],
                showBackView: cards[index]['showBackView'],
                obscureCardNumber: false,
                obscureCardCvv: false,
                width: MediaQuery.of(context).size.width,
                animationDuration: Duration(milliseconds: 3000),
              ),
            );
          },
        ),
      ),
    );
  }
}
