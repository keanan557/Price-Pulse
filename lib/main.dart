import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Price Pulse',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PricePulseHomeScreen(),
    );
  }
}

class PricePulseHomeScreen extends StatefulWidget {
  const PricePulseHomeScreen({super.key});

  @override
  State<PricePulseHomeScreen> createState() => _PricePulseHomeScreenState();
}

class _PricePulseHomeScreenState extends State<PricePulseHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Dummy product data
  final List<Map<String, dynamic>> _allProducts = [
    {
      'image': 'assets/shoprite_bread.png',
      'productName': 'Wholesome White Bread',
      'store': 'Shoprite',
      'price': 'R14,50',
      'lastUpdated': '30 Min ago',
      'isBestPrice': true,
    },
    {
      'image': 'assets/checkers_bread.png',
      'productName': 'Golden Crust White Bread',
      'store': 'Checkers',
      'price': 'R15,95',
      'lastUpdated': '30 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/albany_bread.png',
      'productName': 'Albany White Bread',
      'store': 'Pick n Pay',
      'price': 'R17,50',
      'lastUpdated': '30 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/woolworths_bread.png',
      'productName': 'Blue Ribbon White Bread',
      'store': 'Woolworths',
      'price': 'R18,99',
      'lastUpdated': '30 Min ago',
      'isBestPrice': false,
    },
    // Add more products to make suggestions more diverse
    {
      'image': 'assets/shoprite_milk.png',
      'productName': 'Full Cream Milk 1L',
      'store': 'Shoprite',
      'price': 'R22,00',
      'lastUpdated': '25 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/checkers_milk.png',
      'productName': 'Low Fat Milk 1L',
      'store': 'Checkers',
      'price': 'R23,50',
      'lastUpdated': '20 Min ago',
      'isBestPrice': false,
    },
    {
      'image': 'assets/picknpay_chicken.png',
      'productName': 'Chicken Breast Fillets 500g',
      'store': 'Pick n Pay',
      'price': 'R65,00',
      'lastUpdated': '1 Hour ago',
      'isBestPrice': true,
    },
    {
      'image': 'assets/woolworths_yogurt.png',
      'productName': 'Greek Yogurt 1kg',
      'store': 'Woolworths',
      'price': 'R45,00',
      'lastUpdated': '45 Min ago',
      'isBestPrice': false,
    },
  ];

  List<Map<String, dynamic>> _filteredProducts = [];
  List<String> _autocompleteSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = [];
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _updateFilteredProductsAndSuggestions();
    });
  }

  void _updateFilteredProductsAndSuggestions() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = [];
      _autocompleteSuggestions = [];
    } else {
      final queryLower = _searchQuery.toLowerCase();

      // Filter products for the main display
      _filteredProducts = _allProducts.where((product) {
        final productNameLower = (product['productName'] as String).toLowerCase();
        final storeLower = (product['store'] as String).toLowerCase();
        return productNameLower.contains(queryLower) || storeLower.contains(queryLower);
      }).toList();

      // Generate autocomplete suggestions based on product names and stores
      Set<String> uniqueSuggestions = {}; // Use a Set to avoid duplicate suggestions
      for (var product in _allProducts) {
        final productName = product['productName'] as String;
        final storeName = product['store'] as String;

        if (productName.toLowerCase().contains(queryLower)) {
          uniqueSuggestions.add(productName);
        }
        if (storeName.toLowerCase().contains(queryLower)) {
          uniqueSuggestions.add(storeName);
        }
      }
      _autocompleteSuggestions = uniqueSuggestions.take(5).toList(); // Limit to top 5 suggestions
    }
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _searchController.text = suggestion;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      ); // Move cursor to end
      _searchQuery = suggestion; // Update search query
      _autocompleteSuggestions = []; // Clear suggestions after selection
      _updateFilteredProductsAndSuggestions(); // Update main product list based on selected suggestion
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2D3B),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with "Price Pulse"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                children: [
                  Text(
                    'Price Pulse',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[200],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      // "Find the Best Prices" Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEE7FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Find the Best Prices',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4C4A5C),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Compare prices across all major South African\nretailers and save money on your shopping.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4C4A5C),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Search Bar
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search for products...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                                ),
                              ),
                            ),
                            // Autocomplete Suggestions
                            if (_autocompleteSuggestions.isNotEmpty && _searchQuery.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  constraints: BoxConstraints(
                                      maxHeight:
                                      _autocompleteSuggestions.length * 48.0), // Max height for suggestions
                                  child: ListView.builder(
                                    shrinkWrap: true, // Important for ListView inside Column
                                    itemCount: _autocompleteSuggestions.length,
                                    itemBuilder: (context, index) {
                                      final suggestion = _autocompleteSuggestions[index];
                                      return ListTile(
                                        title: Text(suggestion),
                                        onTap: () => _selectSuggestion(suggestion),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Conditional Product List
                      if (_searchQuery.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return ProductCard(
                                imagePath: product['image'],
                                productName: product['productName'],
                                store: product['store'],
                                price: product['price'],
                                lastUpdated: product['lastUpdated'],
                                isBestPrice: product['isBestPrice'],
                              );
                            },
                          ),
                        )
                      else
                        const Spacer(),

                      // Disclaimer Section at the bottom
                      Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline, color: Colors.red[300], size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Price Disclaimer\n',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[300],
                                          ),
                                        ),
                                        const TextSpan(
                                          text: 'Prices are updated regularly but may vary from actual store prices. Please verify prices before making purchases.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'For more information, visit our Terms & Conditions',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate Widget for a single Product Card for reusability and cleaner code
class ProductCard extends StatelessWidget {
  final String imagePath;
  final String productName;
  final String store;
  final String price;
  final String lastUpdated;
  final bool isBestPrice;

  const ProductCard({
    super.key,
    required this.imagePath,
    required this.productName,
    required this.store,
    required this.price,
    required this.lastUpdated,
    this.isBestPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    store,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Last updated $lastUpdated',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isBestPrice)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Best Price',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}