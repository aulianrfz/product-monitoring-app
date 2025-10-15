import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/viewmodels/product_viewmodel.dart';
import '../../../store/data/models/store_model.dart';
import '../../data/models/promo_model.dart';
import '../viewmodels/promo_viewmodel.dart';

class PromoFormView extends StatefulWidget {
  final Store store;
  final User user;
  final Promo? promo;

  const PromoFormView({
    super.key,
    required this.store,
    required this.user,
    this.promo,
  });

  @override
  State<PromoFormView> createState() => _PromoFormViewState();
}

class _PromoFormViewState extends State<PromoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _normalPriceController = TextEditingController();
  final _promoPriceController = TextEditingController();

  Product? _selectedProduct;
  List<Product> _availableProducts = [];
  bool _isLoadingProducts = false;

  bool get isEditing => widget.promo != null;

  @override
  void initState() {
    super.initState();
    isEditing ? _initEditForm() : _loadAvailableProducts();
  }

  void _initEditForm() {
    _normalPriceController.text = _toRupiah(widget.promo!.normalPrice);
    _promoPriceController.text = _toRupiah(widget.promo!.promoPrice);
  }

  String _toRupiah(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
  }

  Future<void> _loadAvailableProducts() async {
    setState(() => _isLoadingProducts = true);

    final productVM = context.read<ProductViewModel>();
    final promoVM = context.read<PromoViewModel>();

    await productVM.loadProducts(widget.user.token, widget.store.id);
    await promoVM.loadPromos(widget.store.id, widget.user.token);

    final allProducts = productVM.products;
    final promos = promoVM.promos;
    final promoProductIds = promos.map((p) => p.productId).toSet();

    _availableProducts = allProducts.where((p) => !promoProductIds.contains(p.id)).toList();
    setState(() => _isLoadingProducts = false);
  }

  @override
  void dispose() {
    _normalPriceController.dispose();
    _promoPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(PromoViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    if (!isEditing && _selectedProduct == null) {
      _showSnackBar('Pilih produk terlebih dahulu');
      return;
    }

    final normal = _parseCurrency(_normalPriceController.text);
    final promo = _parseCurrency(_promoPriceController.text);

    if (isEditing) {
      await vm.updatePromo(widget.store.id, widget.promo!.id!, normal, promo, widget.user.token);
    } else {
      final newPromo = Promo(
        storeId: widget.store.id,
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        normalPrice: normal,
        promoPrice: promo,
      );
      await vm.sendPromo(widget.store.id, newPromo, widget.user.token);
    }

    if (context.mounted) Navigator.pop(context);
  }

  double _parseCurrency(String text) =>
      double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _handleDelete(PromoViewModel vm) async {
    final confirm = await DialogService.showConfirm(
      context,
        title: "Delete Promo",
        message: "Are you sure you want to delete this promo?"
    );

    if (confirm == true) {
      await vm.deletePromo(widget.store.id, widget.promo!.id!, widget.user.token);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PromoViewModel>();

    if (!isEditing && !_isLoadingProducts && _availableProducts.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: _PromoAppBar(
          title: 'TAMBAH PROMO',
          onBack: () => Navigator.pop(context),
        ),
        body: const Center(
          child: Text(
            'Semua produk sudah memiliki promo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _PromoAppBar(
        title: isEditing ? 'EDIT PROMO' : 'TAMBAH PROMO',
        onBack: () => Navigator.pop(context),
        onDelete: isEditing ? () => _handleDelete(vm) : null,
      ),
      body: _isLoadingProducts && !isEditing
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _ProductSelector(
                      isEditing: isEditing,
                      selectedProduct: _selectedProduct,
                      availableProducts: _availableProducts,
                      promoProductName: widget.promo?.productName,
                      onSelect: (p) => setState(() => _selectedProduct = p),
                    ),
                    const SizedBox(height: 16),
                    _PriceField(label: 'Regular price', controller: _normalPriceController),
                    const SizedBox(height: 16),
                    _PriceField(
                      label: 'Promo price',
                      controller: _promoPriceController,
                      isPromoField: true,
                      normalController: _normalPriceController,
                    ),
                  ],
                ),
              ),
            ),
            _SaveButton(
              isLoading: vm.isLoading,
              label: isEditing ? 'Update Promo' : 'Save Promo',
              onPressed: () => _handleSave(vm),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onDelete;

  const _PromoAppBar({required this.title, required this.onBack, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF4A5C9C),
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: onBack),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
      actions: [
        if (onDelete != null)
          IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: onDelete),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProductSelector extends StatelessWidget {
  final bool isEditing;
  final Product? selectedProduct;
  final List<Product> availableProducts;
  final String? promoProductName;
  final ValueChanged<Product> onSelect;

  const _ProductSelector({
    required this.isEditing,
    required this.selectedProduct,
    required this.availableProducts,
    required this.promoProductName,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final name = isEditing
        ? promoProductName
        : selectedProduct?.name ?? 'Pick Product';

    return GestureDetector(
      onTap: isEditing
          ? null
          : () async {
        final selected = await showModalBottomSheet<Product>(
          context: context,
          builder: (_) => ListView(
            children: availableProducts
                .map((p) => ListTile(
              title: Text(p.name),
              onTap: () => Navigator.pop(context, p),
            ))
                .toList(),
          ),
        );
        if (selected != null) onSelect(selected);
      },
      child: _FormCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_basket, color: Color(0xFFFF9800)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isEditing
                      ? Colors.black87
                      : selectedProduct == null
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
            ),
            if (!isEditing)
              const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPromoField;
  final TextEditingController? normalController;

  const _PriceField({
    required this.label,
    required this.controller,
    this.isPromoField = false,
    this.normalController,
  });

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, _RupiahInputFormatter()],
            decoration: const InputDecoration(hintText: 'Insert price', border: InputBorder.none, isDense: true),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Wajib diisi';
              if (isPromoField) {
                final normal = double.tryParse(
                    normalController?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ??
                    0;
                final promo = double.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                if (promo >= normal) return 'The promo price must be lower than the regular price';
              }
              return null;
            },
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A5C9C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _RupiahInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final numeric = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) return newValue.copyWith(text: '');
    final number = int.parse(numeric);
    final newText = _formatter.format(number);
    return TextEditingValue(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}

