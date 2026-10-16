import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store_item.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Study Coin Balance', style: TextStyle(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Text('${state.knowledgePoints}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 6),
                  const Icon(Icons.bolt, color: AppColors.kpGold),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: state.storeItems.length,
            itemBuilder: (context, i) => _StoreCard(item: state.storeItems[i]),
          ),
        ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreItem item;
  const _StoreCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final canAfford = state.knowledgePoints >= item.price;

    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              decoration: BoxDecoration(color: item.tint, borderRadius: BorderRadius.circular(14)),
              child: Icon(item.icon, size: 34, color: AppColors.textPrimary.withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(height: 10),
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${item.category}: ${item.name}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${item.price}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(width: 4),
              const Icon(Icons.bolt, size: 16, color: AppColors.kpGold),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: item.owned
                    ? AppColors.success
                    : (canAfford ? AppColors.primary : AppColors.success.withValues(alpha: 0.5)),
                minimumSize: const Size.fromHeight(40),
                padding: EdgeInsets.zero,
              ),
              onPressed: item.owned
                  ? null
                  : () {
                      final result = state.buyItem(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result), duration: const Duration(seconds: 1)),
                      );
                    },
              child: Text(
                item.owned ? 'Owned' : (canAfford ? 'Bumili' : 'Not Enough Coins'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
