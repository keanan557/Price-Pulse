import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Price Comparison',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Ensuring home is const if its children are also const for build optimization
      home: const PriceComparisonScreen(),
    );
  }
}

class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  // In a real app, you'd fetch this data or load it from a model.
  // For now, let's create some dummy data.
  final List<Map<String, dynamic>> allProducts = const [ // Renamed to allProducts
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
  ];

  // List to hold products filtered by search query
  List<Map<String, dynamic>> _filteredProducts = [];
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize filtered products with all products when the screen loads
    _filteredProducts = List.from(allProducts);
    // Add a listener to the search controller to filter products as the user types
    _searchController.addListener(_filterProducts);
  }

  // This method is called once for each State object when the dependencies of its
  // BuildContext change. We can use it to pre-cache images.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache all product images. This helps prevent jank when images first appear,
    // especially if they are large or numerous.
    for (var product in allProducts) { // Use allProducts here
      precacheImage(AssetImage(product['image']), context);
    }
  }

  // Dispose of the controller when the widget is removed from the widget tree
  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  // Method to filter products based on the search query
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(allProducts);
      } else {
        _filteredProducts = allProducts.where((product) {
          final productName = (product['productName'] as String).toLowerCase();
          final store = (product['store'] as String).toLowerCase();
          return productName.contains(query) || store.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or a very light grey
      body: SafeArea( // Ensures content doesn't go under status bar/notches
        child: SingleChildScrollView( // Allows scrolling if content overflows
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Spacing from top
                const Text(
                  'Price Comparison',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField( // Removed const as it now has a controller
                    controller: _searchController, // Assign the controller
                    decoration: const InputDecoration( // Kept const for decoration
                      hintText: 'Search for products...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Product List
                // ListView.builder is efficient because it only builds visible items.
                // Using shrinkWrap and NeverScrollableScrollPhysics is fine when
                // inside a SingleChildScrollView and you want the outer scroll view to handle scrolling.
                ListView.builder(
                  shrinkWrap: true, // Important for ListView inside SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                  itemCount: _filteredProducts.length, // Use the filtered list here
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index]; // Get product from filtered list
                    return ProductCard(
                      // Ensure these values are passed correctly and are not null
                      imagePath: product['image'] as String,
                      productName: product['productName'] as String,
                      store: product['store'] as String,
                      price: product['price'] as String,
                      lastUpdated: product['lastUpdated'] as String,
                      isBestPrice: product['isBestPrice'] as bool,
                    );
                  },
                ),
              ],
            ),
          ),
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

  const ProductCard({ // Added const to the constructor for performance
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
      elevation: 0, // No shadow for a flatter look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white, // Card background color
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
              ),
              child: ClipRRect( // ClipRRect to apply border radius to the image itself
                borderRadius: BorderRadius.circular(10),
                child: Image.asset( // Use Image.asset for local assets
                  imagePath,
                  fit: BoxFit.cover,
                  // Add a simple error builder for debugging image loading issues
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    store,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
                      fontSize: 12,
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
                  color: Colors.teal[400], // Greenish background
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
