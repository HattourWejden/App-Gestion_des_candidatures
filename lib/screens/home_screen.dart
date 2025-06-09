import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../constants/app_routes.dart';
import '../constants/colors.dart';
import '../models/job_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _jobsStream;
  List<Job> _filteredJobs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _jobsStream = _firestore.collection('jobs')
      .orderBy('postedDate', descending: true)
      .limit(_limit)
      .snapshots();
  }

  List<Job> _mapDocumentsToJobs(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Job(
        id: doc.id,
        title: data['title'] ?? '',
        company: data['company'] ?? '',
        location: data['location'] ?? '',
        description: data['description'] ?? '',
        requirements: List<String>.from(data['requirements'] ?? []),
        isFavorite: data['isFavorite'] ?? false,
        postedDate: (data['postedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isActive: data['isActive'] ?? true,
      );
    }).toList();
  }

  Future<void> _loadMoreJobs() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final query = _firestore.collection('jobs')
        .orderBy('postedDate', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(_limit);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        _lastDocument = snapshot.docs.last;
        final newJobs = _mapDocumentsToJobs(snapshot);
        setState(() => _filteredJobs.addAll(newJobs));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
Future<void> _toggleFavorite(Job job) async {
  if (_currentUser == null) {
    Navigator.pushNamed(context, AppRoutes.login);
    return;
  }

  try {
    await _firestore.runTransaction((transaction) async {
      // Update job favorite status
      transaction.update(
        _firestore.collection('jobs').doc(job.id),
        {'isFavorite': !job.isFavorite},
      );

      // Update user favorites
      final userFavRef = _firestore.collection('userFavorites').doc(_currentUser!.uid);
      final userFavDoc = await transaction.get(userFavRef);
      
      if (userFavDoc.exists) {
        final data = userFavDoc.data() as Map<String, dynamic>;
        final jobs = List<String>.from(data['jobs'] ?? []);
        
        if (job.isFavorite) {
          jobs.remove(job.id);
        } else {
          jobs.add(job.id);
        }
        
        transaction.update(userFavRef, {'jobs': jobs});
      } else {
        transaction.set(userFavRef, {
          'jobs': [job.id],
          'userId': _currentUser!.uid,
        });
      }
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: ${e.toString()}')),
    );
  }
}

  List<Job> _filterJobs(List<Job> jobs, String query) {
    if (query.isEmpty) return jobs;
    return jobs.where((job) {
      return job.title.toLowerCase().contains(query.toLowerCase()) ||
             job.company.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _showAddJobDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Offre'),
        content: const AddJobForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle form submission
              Navigator.pop(context);
            },
            child: const Text('Publier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres d\'emploi'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              if (_currentUser == null) {
                Navigator.pushNamed(context, AppRoutes.login);
              } else {
                Navigator.pushNamed(context, AppRoutes.favorites);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (_currentUser == null) {
                Navigator.pushNamed(context, AppRoutes.login);
              } else {
                Navigator.pushNamed(context, AppRoutes.profile);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _jobsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final jobs = _mapDocumentsToJobs(snapshot.data!);
                _lastDocument = snapshot.data!.docs.last;
                _filteredJobs = _filterJobs(jobs, _searchController.text);

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification.metrics.pixels ==
                            scrollNotification.metrics.maxScrollExtent &&
                        !_isLoading &&
                        _hasMore) {
                      _loadMoreJobs();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: _filteredJobs.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _filteredJobs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final job = _filteredJobs[index];
                      return JobCard(
                        job: job,
                        onFavoritePressed: () => _toggleFavorite(job),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _currentUser != null
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryGreen,
              onPressed: () => _showAddJobDialog(context),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onFavoritePressed;

  const JobCard({
    super.key,
    required this.job,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.jobDetail,
            arguments: job,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      job.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: job.isFavorite ? AppColors.primaryGreen : null,
                    ),
                    onPressed: onFavoritePressed,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(job.company),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(job.location),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        job.isActive ? Icons.check_circle : Icons.pending,
                        size: 16,
                        color: job.isActive ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(job.postedDate),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddJobForm extends StatefulWidget {
  const AddJobForm({super.key});

  @override
  State<AddJobForm> createState() => _AddJobFormState();
}

class _AddJobFormState extends State<AddJobForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final List<String> _requirements = [];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _addRequirement() {
    if (_requirementsController.text.isNotEmpty) {
      setState(() {
        _requirements.add(_requirementsController.text);
        _requirementsController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre du poste'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ce champ est requis' : null,
            ),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Entreprise'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ce champ est requis' : null,
            ),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Localisation'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _requirementsController,
                    decoration: const InputDecoration(
                      labelText: 'Exigences',
                      hintText: 'Ajouter une exigence',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addRequirement,
                ),
              ],
            ),
            if (_requirements.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Exigences:'),
                  ..._requirements.map((req) => ListTile(
                        leading: const Icon(Icons.circle, size: 8),
                        title: Text(req),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          onPressed: () {
                            setState(() => _requirements.remove(req));
                          },
                        ),
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}