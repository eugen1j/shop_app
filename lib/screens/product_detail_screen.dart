import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final productProvider = Provider.of<Products>(
      context,
      listen: false,
    );
    final product = productProvider.findById(productId);

    if (product == null) {
      throw NullThrownError();
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(product!.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                  color: Colors.black45,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(product.title)),
              background: Hero(
                tag: product.id,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(height: 10),
            Text(
              '\$${product.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(product.description,
                  textAlign: TextAlign.center, softWrap: true),
            ),
            SizedBox(height: 1000),
          ]))
        ],
      ),
    );
  }
}
