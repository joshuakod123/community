import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:version1/provider/post_provider.dart';
import 'package:version1/screen/board.dart';
import 'package:version1/screen/post_detail.dart';
import 'package:date_picker_timetable/date_picker_timetable.dart';
import 'package:version1/screen/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userId = Supabase.instance.client.auth.currentUser?.userMetadata?['Display name'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {

      await Provider.of<Posts>(context, listen: false).fetchThreePosts();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load posts. Please try again later.\nError: $error'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<Posts>(context);
    final posts = postProvider.items;
    DatePickerController _controller = DatePickerController();
    DateTime _selectedDayValue = DateTime.now();
    DateTime _selectedMonthValue = DateTime.now();

    int _selectedIndex =0;

    DateTime firstDayOfMonth(DateTime date) {
      return DateTime(date.year, date.month, 1);
    }
    
    int daysInMonth(DateTime date) {
      var firstDayThisMonth = firstDayOfMonth(
        date,
      );
      var firstDayNextMonth = new DateTime(
        date.year,
        date.month + 1,
        1,
      );

      return firstDayNextMonth.difference(firstDayThisMonth).inDays;
    }

    Future<void> signOut(BuildContext context) async {
      final supabase = Supabase.instance.client;
      try {
        await supabase.auth.signOut();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e")),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Hi, $userId',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: (){
              signOut(context);
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(
        child: Text(
          'No posts found',
          style: TextStyle(fontSize: 16),
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                height: MediaQuery.of(context).size.height/8,
                color: Colors.black,
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height/38,
              ),

              DatePicker(
                DateTime.now(),
                selectionColor: Colors.black,
                dayTextStyle: TextStyle(fontSize: 8),
                locale: "en_US",
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height/18,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Community',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BoardScreen(),
                          ),
                        );
                      }, child: Text('see more...'),
                  ),
                ],
              ),
              Container(
                      height: MediaQuery.of(context).size.height/2.8,
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              border: Border.all(

                width: 1.0,
              )
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: posts.length,
                        itemBuilder: (ctx, index) {
                final post = posts[index];
                return Column(
                  children: [

                    ListTile(
                      title: Text(
                        post.title != null
                            ? (post.title!.length > 60
                            ? '${post.title!.substring(0, 40)}...'
                            : post.title!)
                            : 'No Title',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(posts : post),
                          ),
                        );
                      },
                    ),
                    if(index != 4) const Divider(
                      height: .2,
                      thickness: 1,
                    ),
                  ],
                );
                        },
                      ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height/18,
              ),
            ],
          ),
      
      bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
                icon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8), // Adjust circle size
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black, // Black background
                  ),
                  child: const Icon(Icons.add, color: Colors.white), // White icon
                ),
              label: "CALCULATE",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'BOARD',
            ),
          ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[400],
        onTap:(int index) {
            switch(index){
              case 0:
                if(_selectedIndex == index){
                  setState(() {});
                }
              case 1: //여기에 계산기
                
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BoardScreen(),
                  ),
                );
            }
        }
      ),
    );
  }
}
