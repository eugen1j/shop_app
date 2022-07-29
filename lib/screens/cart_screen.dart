import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _orderCreating = false;

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(children: [
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Text('Total', style: TextStyle(fontSize: 20)),
                Spacer(),
                Chip(
                  label: Text(
                    "\$${cart.totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .primaryTextTheme
                            .headline6
                            ?.color),
                  ),
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                ),
                FlatButton(
                  onPressed: cart.items.isEmpty || _orderCreating
                      ? null
                      : () async {
                    setState(() => _orderCreating = true);
                    try {
                      await Provider.of<Orders>(context, listen: false)
                          .addOrder(
                        cart.items.values.toList(),
                        cart.totalAmount,
                      );
                      cart.clear();
                    } catch (error) {
                      messenger.showSnackBar(SnackBar(
                        content: Text(
                          'An error occured!',
                          textAlign: TextAlign.center,
                        ),
                      ));
                    } finally {
                      setState(() => _orderCreating = false);
                    }
                  },
                  child: _orderCreating ? CircularProgressIndicator() : Text('Order now'),
                  textColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, idx) {
                final item = cart.items.values.toList()[idx];
                final productId = cart.items.keys.toList()[idx];
                return CartItem(
                  productId: productId,
                  id: item.id,
                  title: item.title,
                  price: item.price,
                  quantity: item.quantity,
                );
              },
              itemCount: cart.items.length,
            ))
      ]),
    );
  }
}
