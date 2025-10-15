import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../authentication/data/models/user_model.dart';
import '../../../store/data/models/store_model.dart';
import '../../data/models/promo_model.dart';
import '../viewmodels/promo_viewmodel.dart';
import 'promo_form_view.dart';

class PromoListView extends StatefulWidget {
  final Store store;
  final User user;

  const PromoListView({
    super.key,
    required this.store,
    required this.user,
  });

  @override
  State<PromoListView> createState() => _PromoListViewState();
}

class _PromoListViewState extends State<PromoListView> {
  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PromoViewModel>().loadPromos(widget.store.id, widget.user.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PromoViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A5C9C), Color(0xFF5A6DAE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const _Header(title: 'PROMO'),
              _StoreInfo(store: widget.store),
              const SizedBox(height: 16),
              Expanded(
                child: _PromoListSection(
                  store: widget.store,
                  user: widget.user,
                  viewModel: viewModel,
                  formatCurrency: formatCurrency,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _AddPromoButton(
        store: widget.store,
        user: widget.user,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
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
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoListSection extends StatelessWidget {
  final Store store;
  final User user;
  final PromoViewModel viewModel;
  final NumberFormat formatCurrency;

  const _PromoListSection({
    required this.store,
    required this.user,
    required this.viewModel,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (viewModel.promos.isEmpty) {
      return const Center(
        child: Text('No promo available for this store', style: TextStyle(color: Colors.black54, fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: viewModel.promos.length,
      itemBuilder: (context, index) {
        final promo = viewModel.promos[index];
        return FutureBuilder<bool>(
          future: viewModel.isPromoSynced(store.id, promo.id ?? -1),
          builder: (context, snapshot) {
            final synced = snapshot.data ?? true;
            return _PromoCard(
              promo: promo,
              synced: synced,
              formatCurrency: formatCurrency,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PromoFormView(store: store, promo: promo, user: user),
                  ),
                );
                context.read<PromoViewModel>().loadPromos(store.id, user.token);
              },
            );
          },
        );
      },
    );
  }
}

class _PromoCard extends StatelessWidget {
  final Promo promo;
  final bool synced;
  final NumberFormat formatCurrency;
  final VoidCallback onTap;

  const _PromoCard({
    required this.promo,
    required this.synced,
    required this.formatCurrency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatCurrency.format(promo.normalPrice),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(promo.productName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                ),
                const SizedBox(width: 16),
                Text(
                  formatCurrency.format(promo.promoPrice),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE74C3C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(synced ? Icons.check_circle : Icons.sync_problem,
                    color: synced ? Colors.green : Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  synced ? 'Tersinkron' : 'Belum Sinkron',
                  style: TextStyle(fontSize: 12, color: synced ? Colors.green : Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPromoButton extends StatelessWidget {
  final Store store;
  final User user;

  const _AddPromoButton({required this.store, required this.user});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PromoFormView(store: store, user: user)),
        );
        context.read<PromoViewModel>().loadPromos(store.id, user.token);
      },
      label: const Text('Add Promo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      icon: const Icon(Icons.add, color: Colors.white),
      backgroundColor: const Color(0xFF758DE3),
    );
  }
}
