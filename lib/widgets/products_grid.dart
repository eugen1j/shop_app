import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import './product_item.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  const ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Products>(context);
    final products =
        showFavs ? productProvider.favoriteItems : productProvider.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, idx) {
        final product = products[idx];
        return ChangeNotifierProvider.value(
          value: product,
          child: ProductItem(),
        );
      },
    );
  }
}
