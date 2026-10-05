import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/market_price_repository.dart';

class MarketPriceScreen extends StatefulWidget {
  final MarketPriceRepository repository;

  const MarketPriceScreen({super.key, required this.repository});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MarketPrice> _prices = const [];
  bool _loading = true;
  String? _error;
  String _cropFilter = 'All';
  String _stateFilter = 'All';
  String _marketFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadPrices();
    _searchController.addListener(_refresh);
  }

  @override
  void dispose() {
    _searchController.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prices = await widget.repository.getMarketPrices();

      if (!mounted) {
        return;
      }

      setState(() {
        _prices = prices;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _refresh() => setState(() {});

  List<MarketPrice> get _filtered {
    final q = _searchController.text.trim().toLowerCase();

    return _prices.where((p) {
      final matchesSearch = q.isEmpty ||
          '${p.commodity} ${p.variety} ${p.market} ${p.district} ${p.state}'
              .toLowerCase()
              .contains(q);

      return matchesSearch &&
          (_cropFilter == 'All' || p.commodity == _cropFilter) &&
          (_stateFilter == 'All' || p.state == _stateFilter) &&
          (_marketFilter == 'All' || p.market == _marketFilter);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final crops = {'All', ..._prices.map((e) => e.commodity)}.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Market Prices',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _showFilters,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPrices,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search crop, state or market',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.clear_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: crops.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final crop = crops[i];

                  return ChoiceChip(
                    label: Text(crop),
                    selected: _cropFilter == crop,
                    onSelected: (_) =>
                        setState(() => _cropFilter = crop),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_filtered.length} market records',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Text(
                  'GOVERNMENT OPEN DATA',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Source: data.gov.in • Current Daily Price of Various Commodities from Various Markets (Mandi)',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _ErrorState(
                message: _error!,
                onRetry: _loadPrices,
              )
            else if (_filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(35),
                child: Center(
                  child: Text(
                    'No government market prices match your filters.',
                  ),
                ),
              )
            else
              for (final price in _filtered)
                _MarketPriceCard(price: price),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilters() async {
    var crop = _cropFilter;
    var state = _stateFilter;
    var market = _marketFilter;

    final states = [
      'All',
      ..._prices.map((e) => e.state).toSet(),
    ];

    final markets = [
      'All',
      ..._prices.map((e) => e.market).toSet(),
    ];

    final crops = [
      'All',
      ..._prices.map((e) => e.commodity).toSet(),
    ];

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Filter Market Prices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: crop,
                decoration: const InputDecoration(labelText: 'Crop'),
                items: crops
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setSheetState(() => crop = v ?? 'All'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: state,
                decoration: const InputDecoration(labelText: 'State'),
                items: states
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setSheetState(() => state = v ?? 'All'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: market,
                decoration: const InputDecoration(labelText: 'Market'),
                items: markets
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setSheetState(() => market = v ?? 'All'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _cropFilter = 'All';
                          _stateFilter = 'All';
                          _marketFilter = 'All';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _cropFilter = crop;
                          _stateFilter = state;
                          _marketFilter = market;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 35, 10, 35),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Government market data is unavailable.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _MarketPriceCard extends StatelessWidget {
  final MarketPrice price;

  const _MarketPriceCard({required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    price.commodity,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  price.grade,
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${price.variety} • ${price.market}, ${price.district}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              price.state,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _Price(
                    label: 'MIN',
                    value: price.minPrice,
                  ),
                ),
                Expanded(
                  child: _Price(
                    label: 'MODAL',
                    value: price.modalPrice,
                    highlighted: true,
                  ),
                ),
                Expanded(
                  child: _Price(
                    label: 'MAX',
                    value: price.maxPrice,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Price per quintal • Government open data • '
              '${price.observationDate.day}/'
              '${price.observationDate.month}/'
              '${price.observationDate.year}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Price extends StatelessWidget {
  final String label;
  final int value;
  final bool highlighted;

  const _Price({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '₹$value',
          style: TextStyle(
            fontSize: highlighted ? 17 : 14,
            fontWeight: FontWeight.w900,
            color: highlighted
                ? AppTheme.primaryGreen
                : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
