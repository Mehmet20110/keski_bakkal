import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(const KeskiBakkalApp());
}

class KeskiBakkalApp extends StatelessWidget {
  const KeskiBakkalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keski Bakkal',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class Product {
  String barcode;
  String name;
  int stock;
  double price;

  Product({required this.barcode, required this.name, required this.stock, required this.price});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> _products = [];
  final List<Product> _cart = [];

  double get total => _cart.fold(0, (sum, item) => sum + item.price);

  Future<void> _scanBarcodeAndAddProduct() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "İptal",
      true,
      ScanMode.BARCODE,
    );

    if (barcode != "-1") {
      setState(() {
        _products.add(Product(barcode: barcode, name: "Yeni Ürün", stock: 1, price: 10.0));
      });
    }
  }

  void _addToCart(Product p) {
    if (p.stock > 0) {
      setState(() {
        p.stock -= 1;
        _cart.add(Product(barcode: p.barcode, name: p.name, stock: 1, price: p.price));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Keski Bakkal"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Satış"),
              Tab(text: "Ürün Ekle"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Satış Sayfası
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return ListTile(
                        title: Text("${item.name} - ${item.price.toStringAsFixed(2)} ₺"),
                      );
                    },
                  ),
                ),
                Text("Toplam: ${total.toStringAsFixed(2)} ₺", style: const TextStyle(fontSize: 18)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Müşterinin verdiği para"),
                    onSubmitted: (value) {
                      final paid = double.tryParse(value) ?? 0;
                      final change = paid - total;
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Para Üstü"),
                          content: Text("${change.toStringAsFixed(2)} ₺"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tamam"))
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Ürün Ekle Sayfası
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _scanBarcodeAndAddProduct,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text("Barkod Tara"),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      return ListTile(
                        title: Text("${p.name} - ${p.price} ₺ (Stok: ${p.stock})"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () => _addToCart(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _products.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}    