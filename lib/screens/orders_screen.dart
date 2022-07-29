import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import 'package:provider/provider.dart';
import '../widgets/order_item.dart';
import '../widgets/future_progress_container.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  @override
  void initState() {
    _ordersFuture =
        Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders')),
      body: FutureProgressBuilder<void>(
        future: _ordersFuture,
        builder: (_, __, ___) => Consumer<Orders>(
          builder: (ctx, orders, _) => ListView.builder(
            itemBuilder: (ctx, idx) {
              return OrderItem(orders.orders[idx]);
            },
            itemCount: orders.orders.length,
          ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
