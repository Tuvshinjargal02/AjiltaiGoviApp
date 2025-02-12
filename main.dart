 import 'package:flutter/material.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart'; // Холбоо барих утасны дугаар руу залгах
import 'package:shared_preferences/shared_preferences.dart'; // Dark mode тохиргоо хадгалах

// Өнгөний тогтмол утгууд
const Color desertStart = Color(0xFFF4A460);
const Color desertEnd = Color(0xFFEDC9Af);

// Глобал хувьсагчид
int jobApplicationsCount = 0;
int postedJobsCount = 0;
List<String> earnedBadges = [];
List<Job> favoriteJobs = [];

// Нэвтрэх болон админ эрх
bool isLoggedIn = false;
bool isAdmin = false;
String userPhone = "";
String userName = "";

// Helper: Цалинг утсан дээр хөрвүүлэх функц
RangeValues getSalaryRange(String salaryString) {
  List<String> parts = salaryString.split('-');
  if (parts.length == 2) {
    double lower =
        double.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    double upper =
        double.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return RangeValues(lower, upper);
  }
  return RangeValues(0, 0);
}

void main() {
  runApp(AjiltaiGovApp());
}

/// Үндсэн апп: Material 3 ба adaptive UI
class AjiltaiGovApp extends StatefulWidget {
  @override
  _AjiltaiGovAppState createState() => _AjiltaiGovAppState();
}

class _AjiltaiGovAppState extends State<AjiltaiGovApp> {
  bool isDarkMode = false;
  double fontScale = 1.0;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
  }

  Future<void> _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? darkMode = prefs.getBool('isDarkMode');
    setState(() {
      isDarkMode = darkMode ?? false;
    });
  }

  void toggleDarkMode() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  void updateFontScale(double scale) {
    setState(() {
      fontScale = scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ажилтай Говь',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: desertStart,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: desertStart,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: desertStart,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: desertStart,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: fontScale),
          child: child!,
        );
      },
      home: _showOnboarding
          ? OnboardingScreen(onFinish: () {
              setState(() {
                _showOnboarding = false;
              });
            })
          : MainScreen(
              toggleDarkMode: toggleDarkMode,
              updateFontScale: updateFontScale,
            ),
    );
  }
}

/// Онбординг дэлгэц
class OnboardingScreen extends StatelessWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: desertStart,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Тавтай морил!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Энэ апп таныг ажил хайх үйл явцад хамгийн хялбар, сонирхолтой туршлагыг санал болгоно. Заруудыг үзээд дуртай зарыг тэмдэглэж, өргөдөл илгээж шагнал хүртээрэй.",
                style: TextStyle(fontSize: 18, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: desertEnd,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: StadiumBorder(),
                ),
                child: Text(
                  "Эхлээрэй",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient AppBar (Material 3 adaptive)
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  const GradientAppBar({required this.title, this.actions, this.bottom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
      centerTitle: true,
      actions: actions,
      bottom: bottom,
      surfaceTintColor: Colors.transparent,
      backgroundColor: desertStart,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [desertStart, desertEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null
      ? kToolbarHeight + bottom!.preferredSize.height
      : kToolbarHeight);
}

/// MainScreen – Adaptive Navigation (Material 3 NavigationBar)
class MainScreen extends StatefulWidget {
  final VoidCallback toggleDarkMode;
  final ValueChanged<double> updateFontScale;
  MainScreen({required this.toggleDarkMode, required this.updateFontScale});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      FeaturedJobsScreen(),
      SearchScreen(),
      FavoritesScreen(),
      SettingsScreen(
        toggleDarkMode: widget.toggleDarkMode,
        updateFontScale: widget.updateFontScale,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Нүүр'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Шилдэг зарууд'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Хайллт'),
          NavigationDestination(
              icon: Icon(Icons.favorite), label: 'Миний дуртай'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Тохиргоо'),
        ],
      ),
    );
  }
}

/// Job Model – Өөрчлөлттэй: статус болон хугацаа дуусах огноо,
/// мөн "postedBy" болон "contactNumber" гэсэн шинж чанаруудыг агуулна.
class Job {
  final String title;
  final String location;
  final String description;
  final String category;
  final String salary;
  final String workingHours;
  final bool isMealProvided;
  final bool isFeatured;
  bool isFavorite;
  String status;
  DateTime? expirationDate;
  final String postedBy;
  final String contactNumber;
  Job({
    required this.title,
    required this.location,
    required this.description,
    required this.category,
    required this.salary,
    required this.workingHours,
    required this.isMealProvided,
    this.isFeatured = false,
    this.isFavorite = false,
    this.status = "Хүлээгдэж буй",
    this.expirationDate,
    required this.postedBy,
    required this.contactNumber,
  });
}

List<Job> jobs = [
  Job(
    title: 'Барилгын ажилчин',
    location: 'Улаанбаатар',
    description: 'Туршлагатай, чанартай ажил гүйцэтгэх боломжтой.',
    category: 'Барилга',
    salary: '300,000₮ - 500,000₮',
    workingHours: '08:00-17:00',
    isMealProvided: false,
    isFeatured: true,
    status: "Идэвхтэй",
    expirationDate: DateTime.now().add(Duration(days: 30)),
    postedBy: "Ажил олгогч 1",
    contactNumber: "99001122",
  ),
  Job(
    title: 'Оффисын ажилтан',
    location: 'Хөвсгөл',
    description: 'Бичиг баримт боловсруулах, хурдан ажил гүйцэтгэх боломжтой.',
    category: 'Оффис',
    salary: '350,000₮ - 600,000₮',
    workingHours: '09:00-18:00',
    isMealProvided: true,
    isFeatured: false,
    status: "Хүлээгдэж буй",
    expirationDate: DateTime.now().add(Duration(days: 30)),
    postedBy: "Ажил олгогч 2",
    contactNumber: "88002233",
  ),
  Job(
    title: 'Шөнийн ээлжийн ажилтан',
    location: 'Улаанбаатар',
    description:
        'Шөнийн ээлжинд ажиллах хүсэлтэй, өндөр хурдтай үйл ажиллагааг дэмжих.',
    category: 'Шөнийн ээлж',
    salary: '400,000₮ - 550,000₮',
    workingHours: '22:00-06:00',
    isMealProvided: true,
    isFeatured: true,
    status: "Идэвхтэй",
    expirationDate: DateTime.now().add(Duration(days: 30)),
    postedBy: "Ажил олгогч 1",
    contactNumber: "99001122",
  ),
  Job(
    title: 'Оюутанд зориулсан ажил',
    location: 'Улаанбаатар',
    description: 'Цагийн хуваарь таарсан, оюутнуудад тохирсон ажил.',
    category: 'Оюутанд зориулсан',
    salary: '150,000₮ - 250,000₮',
    workingHours: '12:00-18:00',
    isMealProvided: false,
    isFeatured: false,
    status: "Хүлээгдэж буй",
    expirationDate: DateTime.now().add(Duration(days: 30)),
    postedBy: "Ажил олгогч 2",
    contactNumber: "88002233",
  ),
  Job(
    title: 'Зайнаас ажиллах',
    location: 'Онлайн',
    description: 'Уян хатан ажлын цагтай онлайн ажил.',
    category: 'Зайнаас ажиллах',
    salary: 'Хэлцэлээр',
    workingHours: 'Flexible',
    isMealProvided: false,
    isFeatured: false,
    status: "Хүлээгдэж буй",
    expirationDate: DateTime.now().add(Duration(days: 30)),
    postedBy: "Ажил олгогч 1",
    contactNumber: "99001122",
  ),
];

/// FeaturedJobsScreen – Говийн шилдэг зарууд дэлгэц
class FeaturedJobsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Job> featuredJobs = jobs.where((job) => job.isFeatured).toList();
    return Scaffold(
      appBar: GradientAppBar(title: 'Говийн шилдэг зарууд'),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: featuredJobs.length,
        itemBuilder: (context, index) {
          Job job = featuredJobs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: JobCard(
              job: job,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => JobDetailScreen(job: job)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// JobCard – Material 3 adaptive Card болон button-ийн шинэ загвар
class JobCard extends StatefulWidget {
  final Job job;
  final VoidCallback onTap;
  const JobCard({Key? key, required this.job, required this.onTap})
      : super(key: key);
  @override
  _JobCardState createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Hero(
              tag: 'jobIcon_${widget.job.title}',
              child: CircleAvatar(
                backgroundColor: desertStart,
                child: Text(
                  widget.job.title.substring(0, 1),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            title: Text(
              widget.job.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${widget.job.location} • ${widget.job.category}\nЦалин: ${widget.job.salary}',
              maxLines: 2,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.job.isFeatured)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Trending",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    widget.job.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.job.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.job.isFavorite = !widget.job.isFavorite;
                      if (widget.job.isFavorite) {
                        favoriteJobs.add(widget.job);
                      } else {
                        favoriteJobs.remove(widget.job);
                      }
                    });
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

/// HomeScreen – Adaptive Material 3 UI
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Job> displayedJobs = jobs;
  String searchQuery = "";
  int currentPage = 0;
  late PageController _pageController;

  // Цалингаар шүүх фильтр
  String selectedSalaryFilter = "Бүх цалин";
  final List<String> salaryFilters = [
    "Бүх цалин",
    "0 - 500,000₮",
    "500,000₮ - 1,000,000₮",
    "1,000,000₮ ба дээш"
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshJobs() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      displayedJobs = jobs.map((job) {
        if (job.expirationDate != null &&
            DateTime.now().isAfter(job.expirationDate!)) {
          job.status = "Дууссан";
        }
        return job;
      }).toList();
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      displayedJobs = jobs.where((job) {
        bool matchesSearch =
            job.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                job.location.toLowerCase().contains(searchQuery.toLowerCase());
        bool matchesSalary = true;
        if (selectedSalaryFilter != "Бүх цалин") {
          RangeValues range = getSalaryRange(job.salary);
          if (selectedSalaryFilter == "0 - 500,000₮") {
            matchesSalary = range.start < 500000;
          } else if (selectedSalaryFilter == "500,000₮ - 1,000,000₮") {
            matchesSalary = range.start >= 500000 && range.start < 1000000;
          } else if (selectedSalaryFilter == "1,000,000₮ ба дээш") {
            matchesSalary = range.start >= 1000000;
          }
        }
        return matchesSearch && matchesSalary;
      }).toList();
    });
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
    });
    _applyFilters();
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation =
            Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset.zero)
                .animate(animation);
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshJobs,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text("Ирээдүйг бүтээ!"),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [desertStart, desertEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Өөрийн чадвараа илэрхийлж, шинэ боломжуудыг ол!",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    onChanged: updateSearch,
                    decoration: InputDecoration(
                      hintText: 'Энд ажил хайх...',
                      prefixIcon: Icon(Icons.search, color: desertStart),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ExpansionTile(
                  title: Text("Цалингаар шүүх"),
                  children: [
                    Container(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: salaryFilters.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          String filter = salaryFilters[index];
                          bool isSelected = selectedSalaryFilter == filter;
                          return ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: desertStart.withOpacity(0.8),
                            onSelected: (bool selected) {
                              setState(() {
                                selectedSalaryFilter = filter;
                              });
                              _applyFilters();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: jobs.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    Job job = jobs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, _createRoute(JobDetailScreen(job: job)));
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              desertStart.withOpacity(0.8),
                              desertEnd.withOpacity(0.8)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.3,
                                child: Image.network(
                                  "https://via.placeholder.com/400x220.png?text=${job.title}",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  Job job = displayedJobs[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: JobCard(
                      job: job,
                      onTap: () {
                        Navigator.push(
                            context, _createRoute(JobDetailScreen(job: job)));
                      },
                    ),
                  );
                },
                childCount: displayedJobs.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: desertStart,
        child: Icon(Icons.add),
        onPressed: () {
          if (!isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Нэвтрэх шаардлагатай байна")),
            );
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          } else {
            Navigator.push(context, _createRoute(PostJobScreen()));
          }
        },
      ),
    );
  }
}

/// JobDetailScreen – Adaptive Material 3 дэлгэрэнгүй зарын дэлгэц
class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({required this.job});
  @override
  _JobDetailScreenState createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: widget.job.title),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Hero(
              tag: 'jobIcon_${widget.job.title}',
              child: CircleAvatar(
                radius: 40,
                backgroundColor: desertStart,
                child: Text(widget.job.title.substring(0, 1),
                    style: TextStyle(fontSize: 40, color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
            Text(widget.job.title,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: desertStart)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.grey),
                SizedBox(width: 4),
                Text(widget.job.location,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                SizedBox(width: 16),
                Icon(Icons.category, color: Colors.grey),
                SizedBox(width: 4),
                Text(widget.job.category,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              ],
            ),
            Divider(height: 30, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.attach_money, color: desertStart),
                    SizedBox(height: 4),
                    Text(widget.job.salary,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('Цалин',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.access_time, color: desertStart),
                    SizedBox(height: 4),
                    Text(widget.job.workingHours,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('Цаг',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                        widget.job.isMealProvided
                            ? Icons.restaurant
                            : Icons.restaurant_menu,
                        color: desertStart),
                    SizedBox(height: 4),
                    Text(widget.job.isMealProvided ? 'Хоолтой' : 'Хоолгүй',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('Хоол',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            Divider(height: 30, thickness: 1),
            // Холбоо барих утасны дугаар харуулах хэсэг
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, color: desertStart),
                SizedBox(width: 4),
                Text("Холбоо: ${widget.job.contactNumber}",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500)),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(widget.job.description,
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            if (isLoggedIn &&
                userName == widget.job.postedBy &&
                widget.job.status != "Дууссан")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditJobScreen(job: widget.job)));
                    },
                    icon: Icon(Icons.edit),
                    label: Text("Засах"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        widget.job.status = "Дууссан";
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Зар хаагдлаа!")));
                    },
                    icon: Icon(Icons.check_circle),
                    label: Text("Хаах"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final Uri launchUri = Uri(
                  scheme: 'tel',
                  path: widget.job.contactNumber,
                );
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Утас руу залгах боломжгүй байна")),
                  );
                }
              },
              icon: Icon(Icons.phone),
              label: Text('Холбоо барих'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (!isLoggedIn) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                } else {
                  jobApplicationsCount++;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Өргөдөл илгээгдлээ!")));
                  if (jobApplicationsCount >= 10 &&
                      !earnedBadges.contains("Идэвхтэй ажил хайгч")) {
                    earnedBadges.add("Идэвхтэй ажил хайгч");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Шинэ тэмдэг: Идэвхтэй ажил хайгч олголоо!")),
                    );
                  }
                }
              },
              icon: Icon(Icons.send),
              label: Text('Өргөдөл илгээх'),
              style: ElevatedButton.styleFrom(
                backgroundColor: desertStart,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PostJobScreen – Adaptive Material 3 Ажил байр нэмэхийн формын дэлгэц
class PostJobScreen extends StatefulWidget {
  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String location = '';
  String description = '';
  String category = 'Барилга';
  String salary = '';
  String workingHours = '';
  bool isMealProvided = false;
  int selectedDurationDays = 30;
  String contactNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Ажил байр нэмэх'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(
                  label: 'Ажлын нэр', onSaved: (value) => title = value ?? ''),
              SizedBox(height: 16),
              buildTextField(
                  label: 'Байршил', onSaved: (value) => location = value ?? ''),
              SizedBox(height: 16),
              buildTextField(
                  label: 'Ажлын тайлбар',
                  onSaved: (value) => description = value ?? '',
                  maxLines: 4),
              SizedBox(height: 16),
              buildTextField(
                  label: 'Холбоо барих дугаар',
                  onSaved: (value) => contactNumber = value ?? ''),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Ангилал',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: <String>[
                  'Барилга',
                  'Оффис',
                  'Бусад',
                  'Шөнийн ээлж',
                  'Оюутанд зориулсан',
                  'Зайнаас ажиллах'
                ]
                    .map((String value) => DropdownMenuItem<String>(
                        value: value, child: Text(value)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    category = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              buildTextField(
                  label: 'Цалин хөлс (Жишээ: 300,000₮ - 500,000₮)',
                  onSaved: (value) => salary = value ?? ''),
              SizedBox(height: 16),
              buildTextField(
                  label: 'Ажиллах цаг (Жишээ: 09:00-18:00)',
                  onSaved: (value) => workingHours = value ?? ''),
              SizedBox(height: 16),
              DropdownButtonFormField<bool>(
                value: isMealProvided,
                decoration: InputDecoration(
                  labelText: 'Хоол',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  DropdownMenuItem(child: Text('Хоолгүй'), value: false),
                  DropdownMenuItem(child: Text('Хоолтой'), value: true),
                ],
                onChanged: (newValue) {
                  setState(() {
                    isMealProvided = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedDurationDays,
                decoration: InputDecoration(
                  labelText: 'Зарын хугацаа (хоног)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [30, 60, 90]
                    .map((int days) => DropdownMenuItem<int>(
                        value: days, child: Text("$days хоног")))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedDurationDays = newValue!;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Job newJob = Job(
                      title: title,
                      location: location,
                      description: description,
                      category: category,
                      salary: salary,
                      workingHours: workingHours,
                      isMealProvided: isMealProvided,
                      isFeatured: false,
                      status: "Хүлээгдэж буй",
                      expirationDate: DateTime.now()
                          .add(Duration(days: selectedDurationDays)),
                      postedBy: userName,
                      contactNumber: contactNumber,
                    );
                    jobs.add(newJob);
                    postedJobsCount++;
                    if (postedJobsCount >= 5 &&
                        !earnedBadges.contains("Шилдэг ажил олгогч")) {
                      earnedBadges.add("Шилдэг ажил олгогч");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Шинэ тэмдэг: Шилдэг ажил олгогч олголоо!")),
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: desertStart,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text('Нэмэх',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      {required String label,
      int maxLines = 1,
      required FormFieldSetter<String> onSaved}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      onSaved: onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Энэ талбарыг бөглөнө үү';
        }
        return null;
      },
      maxLines: maxLines,
    );
  }
}

/// SearchScreen – Adaptive Material 3 ангилалын Tab Navigation
class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: GradientAppBar(
          title: 'Хайллт',
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            isScrollable: true,
            tabs: [
              Tab(text: 'Барилга'),
              Tab(text: 'Оффис'),
              Tab(text: 'Бусад'),
              Tab(text: 'Шөнийн ээлж'),
              Tab(text: 'Оюутанд зориулсан'),
              Tab(text: 'Зайнаас ажиллах'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            JobCategoryList(category: 'Барилга'),
            JobCategoryList(category: 'Оффис'),
            JobCategoryList(category: 'Бусад'),
            JobCategoryList(category: 'Шөнийн ээлж'),
            JobCategoryList(category: 'Оюутанд зориулсан'),
            JobCategoryList(category: 'Зайнаас ажиллах'),
          ],
        ),
      ),
    );
  }
}

/// JobCategoryList – Ангилалын дагуу ажлын байрны жагсаалт
class JobCategoryList extends StatelessWidget {
  final String category;
  JobCategoryList({required this.category});
  @override
  Widget build(BuildContext context) {
    List<Job> categoryJobs =
        jobs.where((job) => job.category == category).toList();
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: categoryJobs.length,
      itemBuilder: (context, index) {
        Job job = categoryJobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: JobCard(
            job: job,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      JobDetailScreen(job: job),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    final offsetAnimation =
                        Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset.zero)
                            .animate(animation);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// FavoritesScreen – Adaptive Material 3 Миний дуртай дэлгэц
class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Миний дуртай'),
      body: favoriteJobs.isEmpty
          ? Center(
              child: Text('Одоогоор дуртай зар байхгүй байна.',
                  style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: favoriteJobs.length,
              itemBuilder: (context, index) {
                Job job = favoriteJobs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: JobCard(
                    job: job,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => JobDetailScreen(job: job)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

/// SettingsScreen – Adaptive Material 3 Тохиргоо дэлгэц
class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleDarkMode;
  final ValueChanged<double> updateFontScale;
  SettingsScreen({required this.toggleDarkMode, required this.updateFontScale});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double fontScale = 1.0;
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: GradientAppBar(title: 'Тохиргоо'),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: Text('Харанхуй горим'),
            value: isDark,
            activeColor: desertStart,
            onChanged: (val) {
              widget.toggleDarkMode();
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: desertStart),
            title: Text('Профайл'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: desertStart),
            title: Text('Санал хүсэлт'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FeedbackScreen()));
            },
          ),
          if (isLoggedIn && isAdmin)
            ListTile(
              leading:
                  Icon(Icons.admin_panel_settings, color: Colors.redAccent),
              title: Text('Админ Панель'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminPanelScreen()));
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListTile(
              title: Text('Фонтын хэмжээ'),
              subtitle: Slider.adaptive(
                value: fontScale,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: fontScale.toStringAsFixed(1),
                activeColor: desertStart,
                onChanged: (newValue) {
                  setState(() {
                    fontScale = newValue;
                    widget.updateFontScale(newValue);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ProfileScreen – Adaptive Material 3 Хэрэглэгчийн мэдээлэл
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Профайл'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: isLoggedIn
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: desertStart,
                        child:
                            Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(userName,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(userPhone,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                      SizedBox(height: 16),
                      Text("Өргөдөл илгээсэн: $jobApplicationsCount",
                          style: TextStyle(fontSize: 16)),
                      Text("Нэмсэн ажил байр: $postedJobsCount",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 16),
                      Text("Тэмдэгүүд:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: earnedBadges
                            .map((badge) => Chip(
                                  label: Text(badge),
                                  backgroundColor: desertStart.withOpacity(0.8),
                                  labelStyle: TextStyle(color: Colors.white),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 24),
                      Text("Дуртай ажлууд:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      favoriteJobs.isEmpty
                          ? Text("Дуртай ажлын байр байхгүй байна.",
                              style: TextStyle(fontSize: 16))
                          : Column(
                              children: favoriteJobs
                                  .map((job) => ListTile(
                                        leading: Icon(Icons.work,
                                            color: desertStart),
                                        title: Text(job.title),
                                      ))
                                  .toList(),
                            ),
                      SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isLoggedIn = false;
                            isAdmin = false;
                            userName = "";
                            userPhone = "";
                          });
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        icon: Icon(Icons.logout),
                        label: Text("Гарах",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Та нэвтэрч орно уу",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: desertStart,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: StadiumBorder(),
                      ),
                      child: Text("Нэвтрэх",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// FeedbackScreen – Adaptive Material 3 Санал хүсэлт дэлгэц
class FeedbackScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: "Санал хүсэлт"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Бидэнд санал хүсэлт илгээгээрэй",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Энд санал хүсэлтээ бичнэ үү",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Санал хүсэлт илгээгдлээ.")),
                );
              },
              child: Text("Илгээх"),
              style: ElevatedButton.styleFrom(
                backgroundColor: desertStart,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// LoginScreen – Adaptive Material 3 Нэвтрэх дэлгэц (Show Password)
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String phone = "";
  String password = "";
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [desertStart, desertEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              margin: EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Нэвтрэх",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Гар утасны дугаар",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onSaved: (value) => phone = value ?? "",
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Утасны дугаар оруулна уу";
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Нууц үг",
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: _obscureText,
                        onSaved: (value) => password = value ?? "",
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Нууц үг оруулна уу";
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (phone.trim() == "89773009" &&
                                password == "1234") {
                              isAdmin = true;
                            } else {
                              isAdmin = false;
                            }
                            setState(() {
                              isLoggedIn = true;
                              userPhone = phone;
                              userName = "Хэрэглэгч";
                            });
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          }
                        },
                        child: Text("Нэвтрэх", style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: desertStart,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: StadiumBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()));
                        },
                        child: Text("Бүртгүүлэх",
                            style: TextStyle(fontSize: 16, color: desertStart)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// RegisterScreen – Adaptive Material 3 Бүртгүүлэх дэлгэц
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String phone = "";
  String password = "";
  String confirmPassword = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: "Бүртгүүлэх"),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [desertStart, desertEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              margin: EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text("Бүртгүүлэх",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Хэрэглэгчийн нэр",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onSaved: (value) => name = value ?? "",
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Нэрээ оруулна уу";
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Гар утасны дугаар",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onSaved: (value) => phone = value ?? "",
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Утасны дугаар оруулна уу";
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Нууц үг",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                        onSaved: (value) => password = value ?? "",
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Нууц үг оруулна уу";
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Нууц үг баталгаажуулах",
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                        onSaved: (value) => confirmPassword = value ?? "",
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Баталгаажуулах нууц үг оруулна уу";
                          if (value != password)
                            return "Нууц үг таарахгүй байна";
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              isLoggedIn = true;
                              userName = name;
                              userPhone = phone;
                              if (phone.trim().toLowerCase() == "admin") {
                                isAdmin = true;
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        child:
                            Text("Бүртгүүлэх", style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: desertStart,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AdminPanelScreen – Adaptive Material 3 Админ Панель
class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Админ Панель',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // List-ыг шинэчлэх
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          Job job = jobs[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(job.title),
              subtitle: Text(
                  "Статус: ${job.status}\nХугацаа дуусах: ${job.expirationDate != null ? job.expirationDate!.toLocal().toString().split(' ')[0] : 'Олсонгүй'}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditJobScreen(job: job)));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        jobs.remove(job);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// EditJobScreen – Adaptive Material 3 Зар засах дэлгэц
class EditJobScreen extends StatefulWidget {
  final Job job;
  EditJobScreen({required this.job});
  @override
  _EditJobScreenState createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late String status;
  late DateTime? expirationDate;
  @override
  void initState() {
    super.initState();
    status = widget.job.status;
    expirationDate = widget.job.expirationDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Зарыг засах'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(
                  labelText: 'Статус',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ["Хүлээгдэж буй", "Идэвхтэй", "Дууссан"]
                    .map((s) =>
                        DropdownMenuItem<String>(value: s, child: Text(s)))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    status = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text("Хугацаа дуусах огноо"),
                subtitle: Text(expirationDate != null
                    ? expirationDate!.toLocal().toString().split(' ')[0]
                    : "Олсонгүй"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: expirationDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)));
                  if (picked != null) {
                    setState(() {
                      expirationDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      widget.job.status = status;
                      widget.job.expirationDate = expirationDate;
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text("Хадгалах", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: desertStart,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}