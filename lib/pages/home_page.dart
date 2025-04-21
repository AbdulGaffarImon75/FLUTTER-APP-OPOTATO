import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import 'kacchi_page.dart';

class Cuisine {
  final String label;
  final String image;
  final Widget page;

  Cuisine({required this.label, required this.image, required this.page});
}

class Combo {
  final String title;
  final String vendor;
  final String price;
  final String image;
  final Widget page;

  Combo({
    required this.title,
    required this.vendor,
    required this.price,
    required this.image,
    required this.page,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cuisines = [
      Cuisine(
        label: 'Kacchi',
        image: 'assets/kacchi.jpeg',
        page: const KacchiPage(),
      ),
      Cuisine(
        label: 'Pizza',
        image: 'assets/pizza.jpg',
        page: DummyPage('Pizza'),
      ),
      Cuisine(
        label: 'Burger',
        image: 'assets/burger.jpg',
        page: DummyPage('Burger'),
      ),
      Cuisine(
        label: 'Wraps',
        image: 'assets/wraps.jpg',
        page: DummyPage('Wraps'),
      ),
    ];

    final combos = [
      Combo(
        title: 'Meaty Supreme',
        vendor: 'Meat & Marrow',
        price: '৳690',
        image: 'assets/meaty_supreme.jpg',
        page: DummyPage('Meaty Supreme'),
      ),
      Combo(
        title: 'Burger Meal',
        vendor: "Khana's",
        price: '৳1049',
        image: 'assets/burger_meal.jpeg',
        page: DummyPage('Burger Meal'),
      ),
      Combo(
        title: 'Unlimited Pizza',
        vendor: "Domino's Pizza",
        price: '৳999',
        image: 'assets/pizza_unlimited.jpg',
        page: DummyPage('Unlimited Pizza'),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/logo.png', width: 40, height: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _actionButton(Icons.bookmark, "Bookmarks"),
                      _actionButton(Icons.local_offer, "Offers"),
                      _actionButton(Icons.person_add, "Following"),
                      _actionButton(Icons.shopping_bag, "Order"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DummyPage('Billboard')),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/platter.jpg',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            color: Colors.white70,
                            child: const Text(
                              "Mejo Feast Platter\nonly ৳1555TK",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Cuisines",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cuisines.length,
                    itemBuilder: (context, index) {
                      final cuisine = cuisines[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => cuisine.page),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(cuisine.image),
                                radius: 30,
                              ),
                              const SizedBox(height: 4),
                              Text(cuisine.label),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Explore Combo",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: combos.length,
                    itemBuilder: (context, index) {
                      final combo = combos[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => combo.page),
                          );
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  combo.image,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      combo.vendor,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      combo.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      combo.price,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

// DummyPage is a placeholder for other pages
// that will be navigated to when the user taps on a cuisine or combo.
//class DummyPage extends StatelessWidget {
 // final String title;
  //const DummyPage(this.title, {super.key});

 // @override
  //Widget build(BuildContext context) {
   // return Scaffold(
      //appBar: AppBar(title: Text(title), centerTitle: true),
      //body: Center(
        //child: Text(
//'Welcome to $title Page!',
          //style: const TextStyle(fontSize: 24),
        //),
     // ),
//);
 // }
//}
