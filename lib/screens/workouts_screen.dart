import 'package:flutter/material.dart';
import 'package:academia_unifor/widgets.dart';
import 'package:academia_unifor/services/gym_data_service.dart';
import 'package:academia_unifor/models/gym_equipment.dart';

Map<String, int> suggestions = {
  "Máquinas para treinamento de força": 40,
  "Aparelhos ergométricos (cárdio)": 24,
  "Esteiras": 12,
  "Bikes para atividades de spinning": 11,
};

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: SafeArea(
        child: CustomConvexBottomBar(
          currentIndex: 1, // Índice correspondente ao botão "Treinos"
          child: const WorkoutsBody(),
        ),
      ),
    );
  }
}

class WorkoutsBody extends StatefulWidget {
  const WorkoutsBody({super.key});

  @override
  State<WorkoutsBody> createState() => _WorkoutsBodyState();
}

class _WorkoutsBodyState extends State<WorkoutsBody> {
  String? selectedCategory;
  List<EquipmentItem> allItems = [];
  List<EquipmentItem> selectedItems = [];

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  void _loadAllItems() async {
    final categories = await loadGymEquipment();
    final items = categories.expand((c) => c.items).toList();
    setState(() {
      allItems = items;
    });
  }

  void _loadCategory(String category) async {
    final categories = await loadGymEquipment();
    final selected = categories.firstWhere((c) => c.category == category);
    setState(() {
      selectedCategory = category;
      selectedItems = selected.items;
    });
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        selectedCategory = null;
        selectedItems = [];
      });
      return;
    }

    final filtered =
        allItems.where((item) {
          final lower = query.toLowerCase();
          return item.name.toLowerCase().contains(lower) ||
              item.brand.toLowerCase().contains(lower) ||
              item.model.toLowerCase().contains(lower);
        }).toList();

    setState(() {
      selectedCategory = 'Resultados da busca';
      selectedItems = filtered;
    });
  }

  Widget fallbackImageWithBorder() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.white,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chipColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: SearchAppBar(onSearchChanged: _onSearchChanged),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              selectedCategory == null
                  ? _EmptySearchSection(
                    chipColor: chipColor,
                    textColor: textColor,
                    onChipTap: _loadCategory,
                  )
                  : _SelectedCategoryList(
                    selectedCategory: selectedCategory!,
                    items: selectedItems,
                    onBack: () {
                      setState(() {
                        selectedCategory = null;
                        selectedItems = [];
                      });
                    },
                    fallbackImage: fallbackImageWithBorder,
                  ),
        ),
      ),
    );
  }
}

class _EmptySearchSection extends StatelessWidget {
  final Color chipColor;
  final Color textColor;
  final void Function(String) onChipTap;

  const _EmptySearchSection({
    required this.chipColor,
    required this.textColor,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.search, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          "Pesquise por um aparelho...",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children:
              suggestions.keys
                  .map(
                    (equipamento) => ActionChip(
                      label: Text(equipamento),
                      backgroundColor: chipColor,
                      labelStyle: TextStyle(color: textColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.transparent),
                      ),
                      onPressed: () => onChipTap(equipamento),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _SelectedCategoryList extends StatelessWidget {
  final String selectedCategory;
  final List<EquipmentItem> items;
  final VoidCallback onBack;
  final Widget Function() fallbackImage;

  const _SelectedCategoryList({
    required this.selectedCategory,
    required this.items,
    required this.onBack,
    required this.fallbackImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedCategory,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 150,
                child: Row(
                  children: [
                    // Informações
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.brand,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              item.model,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              'Qtd: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Imagem
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child:
                            item.image.isNotEmpty
                                ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      color: Colors.white,
                                      child: Image.network(
                                        item.image,
                                        height: double.infinity,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => fallbackImage(),
                                      ),
                                    ),
                                  ),
                                )
                                : fallbackImage(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
