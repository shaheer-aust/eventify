import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/scheduler.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurple, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(
            'Eventify',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        actions: [
          FirebaseAuth.instance.currentUser == null
              ? _TabButton(
                  label: 'Login',
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                    /* Navigate to Login */
                  },
                )
              : SizedBox(),
          FirebaseAuth.instance.currentUser == null
              ? _TabButton(
                  label: 'Signup',
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                    /* Navigate to Signup */
                  },
                )
              : SizedBox(),
          _TabButton(
            label: 'Events',
            onTap: () {
              /* Navigate to Events */
            },
          ),
          FirebaseAuth.instance.currentUser != null
              ? _TabButton(
                  label: 'Dashboard',
                  onTap: () {
                    Navigator.pushNamed(context, '/dashboard');
                  },
                )
              : Container(),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseAuth.instance.currentUser != null
                ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get()
                : Future.value(
                    // Create an empty DocumentSnapshot for non-logged-in users
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc('dummy')
                        .get(),
                  ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                return SizedBox();
              }
              final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              if (data['role'] == 'admin') {
                return _TabButton(
                  label: 'Admin Panel',
                  onTap: () {
                    print(" admin ");
                    // Navigator.pushNamed(context, '/user');
                  },
                );
              }
              return SizedBox();
            },
          ),
        ],
      ),
      body: EventCarousel(),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          //height: 100,
          //width: 100,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color.fromARGB(255, 31, 31, 31).withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: FittedBox(
            child: Text(
              label,
              style: const TextStyle(
                color: Color.fromARGB(255, 191, 40, 211),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.white,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EventCarousel extends StatelessWidget {
  const EventCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred. Please try again later.'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No events found.'));
        }

        final events = snapshot.data!.docs;

        return SizedBox(
          height: 400,
          child: CarouselSlider.builder(
            itemCount: events.length,
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              height: 400,
              enlargeCenterPage: true,
            ),
            itemBuilder: (context, index, realIndex) {
              final Map<String, dynamic> eventData =
                  events[index].data() as Map<String, dynamic>;
              final String imageUrl = eventData['bgPicture'] ?? '';
              final String title = eventData['title'] ?? '';

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: EventCarouselItem(
                  imageUrl: imageUrl,
                  title: title,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/eventDetail',
                      arguments: events[index].id,
                    );
                  },
                  deadLine: eventData['deadline'] ?? Timestamp.now(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class EventCarouselItem extends StatelessWidget {
  final String imageUrl;
  final Timestamp deadLine;
  final String title;
  final VoidCallback onTap;

  const EventCarouselItem({
    super.key,
    required this.imageUrl,
    required this.deadLine,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FadeInImage.assetNetwork(
                placeholder: 'assets/placeholder_image.png',
                image: imageUrl,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  child: const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  'DeadLine: ${deadLine.toDate().toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
