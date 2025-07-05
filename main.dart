import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HabitTrackerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Habit {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  bool isCompleted;
  int currentStreak;
  int totalDays;
  List<bool> weekProgress;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isCompleted = false,
    this.currentStreak = 0,
    this.totalDays = 0,
    List<bool>? weekProgress,
  }) : weekProgress = weekProgress ?? List.filled(7, false);

  double get progressPercentage =>
      totalDays > 0 ? currentStreak / totalDays : 0.0;
}

class HabitTrackerScreen extends StatefulWidget {
  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  List<Habit> habits = [
    Habit(
      id: '1',
      name: 'Drink Water',
      description: '8 glasses per day',
      icon: Icons.local_drink,
      color: Colors.blue,
      currentStreak: 5,
      totalDays: 10,
      weekProgress: [true, true, false, true, true, true, false],
    ),
    Habit(
      id: '2',
      name: 'Exercise',
      description: '30 minutes daily',
      icon: Icons.fitness_center,
      color: Colors.orange,
      currentStreak: 3,
      totalDays: 7,
      weekProgress: [false, true, true, true, false, false, false],
    ),
    Habit(
      id: '3',
      name: 'Read Books',
      description: '20 pages daily',
      icon: Icons.menu_book,
      color: Colors.green,
      currentStreak: 8,
      totalDays: 12,
      weekProgress: [true, true, true, false, true, true, true],
    ),
    Habit(
      id: '4',
      name: 'Meditate',
      description: '10 minutes daily',
      icon: Icons.self_improvement,
      color: Colors.purple,
      currentStreak: 2,
      totalDays: 5,
      weekProgress: [true, false, true, false, false, false, false],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleHabit(int index) {
    setState(() {
      habits[index].isCompleted = !habits[index].isCompleted;
      if (habits[index].isCompleted) {
        habits[index].currentStreak++;
        habits[index].totalDays++;
      } else {
        habits[index].currentStreak = habits[index].currentStreak > 0
            ? habits[index].currentStreak - 1
            : 0;
      }
    });

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Habit Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Stats
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Total Habits',
                    '${habits.length}',
                    Icons.list_alt,
                    Colors.white,
                  ),
                  _buildStatCard(
                    'Completed Today',
                    '${habits.where((h) => h.isCompleted).length}',
                    Icons.check_circle,
                    Colors.greenAccent,
                  ),
                  _buildStatCard(
                    'Streak',
                    '${habits.map((h) => h.currentStreak).reduce((a, b) => a + b)}',
                    Icons.local_fire_department,
                    Colors.orangeAccent,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Habits List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: habits[index].isCompleted
                            ? _scaleAnimation.value
                            : 1.0,
                        child: HabitCard(
                          habit: habits[index],
                          onToggle: () => _toggleHabit(index),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new habit functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Add new habit feature coming soon!'),
              backgroundColor: Colors.indigo,
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 30),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onToggle;

  HabitCard({required this.habit, required this.onToggle});

  @override
  _HabitCardState createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: widget.habit.isCompleted
              ? widget.habit.color
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Habit Icon
              Hero(
                tag: 'habit-icon-${widget.habit.id}',
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.habit.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.habit.icon,
                    color: widget.habit.color,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Habit Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.habit.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Checkmark Button
              GestureDetector(
                onTap: () {
                  widget.onToggle();
                  if (widget.habit.isCompleted) {
                    _checkController.forward();
                  } else {
                    _checkController.reverse();
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.habit.isCompleted
                        ? widget.habit.color
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: widget.habit.isCompleted
                        ? [
                            BoxShadow(
                              color: widget.habit.color.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: AnimatedBuilder(
                    animation: _checkAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _checkAnimation.value,
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Progress Section
          Row(
            children: [
              Text(
                'Progress: ${widget.habit.currentStreak}/${widget.habit.totalDays}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Text(
                '${(widget.habit.progressPercentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.habit.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Animated Progress Bar
          AnimatedProgressBar(
            progress: widget.habit.progressPercentage,
            color: widget.habit.color,
          ),
          SizedBox(height: 16),
          // Week Progress Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: List.generate(7, (index) {
                  return Container(
                    margin: EdgeInsets.only(left: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.habit.weekProgress[index]
                          ? widget.habit.color
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color color;

  AnimatedProgressBar({required this.progress, required this.color});

  @override
  _AnimatedProgressBarState createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
      );
      _progressController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color.withOpacity(0.7),
                    widget.color,
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
