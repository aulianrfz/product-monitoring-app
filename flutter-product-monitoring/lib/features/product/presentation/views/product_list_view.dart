import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../authentication/data/models/user_model.dart';
import '../../../store/data/models/store_model.dart';
import '../../data/models/product_model.dart';
import '../viewmodels/product_viewmodel.dart';

class ProductListView extends StatefulWidget {
  final User user;
  final Store store;

  const ProductListView({super.key, required this.user, required this.store});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductViewModel>().loadProducts(widget.user.token, widget.store.id);
    });
  }

  void _showSnackBar(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} has been updated to ${product.available ? 'Unavailable' : 'Available'}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A5C9C), Color(0xFF5A6DAE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const _Header(),
              _StoreInfo(store: widget.store),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                      ? Center(child: Text(viewModel.errorMessage!))
                      : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: viewModel.products.length,
                    itemBuilder: (context, i) {
                      final product = viewModel.products[i];
                      return ProductCard(
                        product: product,
                        onToggle: () async {
                          await viewModel.updateAvailability(
                              widget.user.token, widget.store.id, product);
                          if (mounted) _showSnackBar(product);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'PRODUK',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StoreInfo extends StatelessWidget {
  final Store store;
  const _StoreInfo({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(store.address ?? '-', style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              store.code,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onToggle;

  const ProductCard({super.key, required this.product, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          _barcodeColumn(),
          const SizedBox(width: 16),
          Expanded(
            child: Text(product.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: product.available ? const Color(0xFF4CAF50) : const Color(0xFFBDBDBD),
                shape: BoxShape.circle,
              ),
              child: product.available
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _barcodeColumn() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration:
          BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: CustomPaint(painter: BarcodePainter()),
        ),
        const SizedBox(height: 4),
        Text(product.barcode, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}

class BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final bars = [3.0, 2.0, 3.0, 1.0, 2.0, 3.0, 2.0, 1.0, 3.0];
    double x = 5;
    for (int i = 0; i < bars.length; i++) {
      if (i.isEven) canvas.drawRect(Rect.fromLTWH(x, 8, bars[i], size.height - 16), paint);
      x += bars[i] + 1;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
