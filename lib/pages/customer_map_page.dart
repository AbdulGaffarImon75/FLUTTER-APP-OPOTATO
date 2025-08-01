import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class CustomerMapPage extends StatefulWidget {
  @override
  State<CustomerMapPage> createState() => _CustomerMapPageState();
}

class _CustomerMapPageState extends State<CustomerMapPage> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(23.8103, 90.4125);
  List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  String _routeInfo = '';
  final TextEditingController _searchController = TextEditingController();

  final String orsApiKey = 'YOUR_ORS_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _loadFirestoreRestaurants();
  }

  Future<void> _loadUserLocation() async {
    final location = await _getCurrentLatLng();
    if (location != null) {
      setState(() => _currentLocation = location);
      _mapController.move(_currentLocation, 13);
    }
  }

  Future<LatLng?> _getCurrentLatLng() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) return null;
      }

      final pos = await Geolocator.getCurrentPosition();
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      print("❌ Location Error: $e");
      return null;
    }
  }

  Future<void> _loadFirestoreRestaurants() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('rest').get();

      final restaurantMarkers =
          snap.docs.map((doc) {
            final data = doc.data();
            final lat = data['latitude'] as double;
            final lng = data['longitude'] as double;
            final name = data['name'];

            return Marker(
              point: LatLng(lat, lng),
              width: 60,
              height: 60,
              child: Tooltip(
                message: name,
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            );
          }).toList();

      setState(() => _markers.addAll(restaurantMarkers));
    } catch (e) {
      print("❌ Firestore Error: $e");
    }
  }

  Future<void> _searchWithNominatim(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=bd';

    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterApp'},
      );

      final List data = json.decode(res.body);
      if (data.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No results found")));
        return;
      }

      showModalBottomSheet(
        context: context,
        builder:
            (_) => ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) {
                final place = data[i];
                final lat = double.parse(place['lat']);
                final lon = double.parse(place['lon']);
                final displayName = place['display_name'];
                return ListTile(
                  title: Text(displayName),
                  onTap: () async {
                    Navigator.pop(context);
                    await _handlePlaceSelection(LatLng(lat, lon), displayName);
                  },
                );
              },
            ),
      );
    } catch (e) {
      print("❌ Nominatim error: $e");
    }
  }

  Future<void> _handlePlaceSelection(LatLng destination, String name) async {
    final snapshot = await FirebaseFirestore.instance.collection('rest').get();
    bool matchFound = false;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final restName = (data['name'] ?? '').toString().toLowerCase();
      if (name.toLowerCase().contains(restName)) {
        matchFound = true;
        break;
      }
    }

    _mapController.move(destination, 16);

    setState(() {
      _routeInfo = '';
      _routePoints.clear();
      _markers.add(
        Marker(
          point: destination,
          width: 60,
          height: 60,
          child: Tooltip(
            message: name,
            child: Icon(
              Icons.location_on,
              size: 40,
              color: matchFound ? Colors.green : Colors.orange,
            ),
          ),
        ),
      );
    });

    _getWalkingRoute(destination, name);
  }

  Future<void> _getWalkingRoute(LatLng to, String label) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/foot-walking/geojson',
    );

    final body = jsonEncode({
      "coordinates": [
        [_currentLocation.longitude, _currentLocation.latitude],
        [to.longitude, to.latitude],
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': orsApiKey,
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final coords = decoded['features'][0]['geometry']['coordinates'];
        final summary = decoded['features'][0]['properties']['summary'];
        final distanceKm = (summary['distance'] / 1000).toStringAsFixed(2);
        final durationMin = (summary['duration'] / 60).toStringAsFixed(1);

        setState(() {
          _routePoints = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
          _routeInfo = '$label: $distanceKm km, ~ $durationMin min walk';
        });
      } else {
        print("❌ ORS status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ ORS Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Map")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search restaurant or location...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchWithNominatim(_searchController.text),
                ),
              ],
            ),
          ),
          if (_routeInfo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_routeInfo, style: const TextStyle(fontSize: 16)),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(center: _currentLocation, zoom: 13),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 5,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                    ..._markers,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.move(_currentLocation, 15),
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
