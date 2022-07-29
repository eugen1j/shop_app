import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../widgets/future_progress_container.dart';
import '../widgets/user_product_item.dart';
import '../screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts(
      filterByUser: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routeName),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureProgressBuilder<void>(
          future: _refreshProducts(context),
          builder: (ctx, _, __) {
            return RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Consumer<Products>(
                  builder: (ctx, products, _) => ListView.builder(
                    itemBuilder: (_, idx) {
                      final product = products.items[idx];
                      return Column(
                        children: [
                          UserProductItem(
                            id: product.id,
                            title: product.title,
                            imageUrl: product.imageUrl,
                          ),
                          Divider(),
                        ],
                      );
                    },
                    itemCount: products.items.length,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
