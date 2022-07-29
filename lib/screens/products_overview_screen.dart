import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import 'package:provider/provider.dart';
import '../widgets/badge.dart';
import './cart_screen.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/future_progress_container.dart';

enum FilterOptions { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions val) {
              setState(
                  () => _showOnlyFavorites = val == FilterOptions.Favorites);
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Only Favorites'),
                  value: FilterOptions.Favorites),
              PopupMenuItem(child: Text('Show all'), value: FilterOptions.All),
            ],
          ),
          Consumer<Cart>(
              builder: (_, cart, ch) => Badge(
                    child: ch!,
                    value: cart.itemCount.toString(),
                  ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () =>
                    Navigator.of(context).pushNamed(CartScreen.routeName),
              ))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureProgressBuilder<void>(
        future: Provider.of<Products>(context, listen: false).fetchAndSetProducts(),
        builder: (_, __, ___) {
          return ProductsGrid(_showOnlyFavorites);
        },
      ),
    );
  }
}
