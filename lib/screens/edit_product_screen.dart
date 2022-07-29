import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // In earlier version of Flutter you needed to handle focus
  // transition to the next field manually
  final _imageRegex = RegExp(r'^https?:\/\/.*\.(png|jpg|jpeg)$');

  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Product _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _isInit = true;
  var _isLoading = false;

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        final product =
            Provider.of<Products>(context, listen: false).findById(productId);
        if (product != null) {
          _editedProduct = product;
          _imageUrlController.text = product.imageUrl;
        }
      }
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus &&
        _imageRegex.hasMatch(_imageUrlController.text)) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final state = _form.currentState;
    if (state == null) return;
    if (!state.validate()) return;
    state.save();
    setState(() => _isLoading = true);
    final product = Provider.of<Products>(context, listen: false);

    try {
      if (_editedProduct.id == '') {
        await product.addProduct(_editedProduct);
      } else {
        await product.editProduct(_editedProduct.id, _editedProduct);
      }
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured!'),
          content: Text('Something went wrong'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Okay'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _editedProduct.title,
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onSaved: (val) => _editedProduct =
                            _editedProduct.copyWith(title: val),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please provide a value';
                          }
                          return null;
                        },
                        // onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_priceFocusNode),
                      ),
                      TextFormField(
                        initialValue: _editedProduct.price == 0
                            ? ''
                            : _editedProduct.price.toString(),
                        decoration: InputDecoration(
                            labelText: 'Price', prefixText: '\$'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onSaved: (val) => _editedProduct = _editedProduct
                            .copyWith(price: double.parse(val ?? '0')),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please provide a value';
                          }

                          final doubleVal = double.tryParse(val);
                          if (doubleVal == null) {
                            return 'Please enter a valid number';
                          }
                          if (doubleVal <= 0) {
                            return 'Please enter a number greater than zero';
                          }

                          return null;
                        },
                        // focusNode: _priceFocusNode,
                      ),
                      TextFormField(
                        initialValue: _editedProduct.description,
                        decoration: InputDecoration(labelText: 'Title'),
                        // textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        onSaved: (val) => _editedProduct =
                            _editedProduct.copyWith(description: val),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter a description';
                          }
                          if (val.length < 10) {
                            return 'Should be at least 10 charactes long';
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child:
                                _imageRegex.hasMatch(_imageUrlController.text)
                                    ? FittedBox(
                                        child: Image.network(
                                          _imageUrlController.text,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(child: Text('Enter a URL')),
                          ),
                          Expanded(
                              child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () => setState(() {}),
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) => _saveForm(),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter an image URL';
                              }

                              if (!val.startsWith('http://') &&
                                  !val.startsWith('https://')) {
                                return 'Please enter a valid URL';
                              }

                              if (!val.endsWith('.png') &&
                                  !val.endsWith('.jpg') &&
                                  !val.endsWith('.jpeg')) {
                                return 'Please enter an image URL (.png, .jpg, .jpeg)';
                              }

                              return null;
                            },
                            onSaved: (val) => _editedProduct =
                                _editedProduct.copyWith(imageUrl: val),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
