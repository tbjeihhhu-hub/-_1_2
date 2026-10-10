import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TawseelakApp());
}

const Color gold = Color(0xFFFFBF00);
const Color dark = Color(0xFF101114);
const Color background = Color(0xFFF5F5F7);

const String developerName = 'علاوي ال حمادي';
const String developerPhone = '07880254887';
const String appName = 'توصيلك';

const List<String> provinces = [
  'بغداد',
  'البصرة',
  'نينوى',
  'أربيل',
  'النجف',
  'كربلاء',
  'ذي قار',
  'ميسان',
  'المثنى',
  'القادسية',
  'بابل',
  'واسط',
  'ديالى',
  'الأنبار',
  'صلاح الدين',
  'كركوك',
  'دهوك',
  'السليمانية',
];

const List<String> accountTypes = [
  'زبون',
  'مندوب',
  'صاحب دلفري',
  'صاحب ماركت',
  'صاحب مطعم',
  'صاحب ماركة / متجر',
  'سائق تكسي',
  'مقدم خدمات',
];

class ServiceItem {
  final String name;
  final IconData icon;
  final String category;

  const ServiceItem(this.name, this.icon, this.category);
}

const List<ServiceItem> serviceItems = [
  ServiceItem('تكسي ومشاوير', Icons.local_taxi, 'نقل'),
  ServiceItem('مطاعم ووجبات', Icons.restaurant, 'طعام'),
  ServiceItem('ماركت ومواد غذائية', Icons.shopping_cart, 'تسوق'),
  ServiceItem('ماركات وملابس', Icons.checkroom, 'تسوق'),
  ServiceItem('خضروات وفواكه', Icons.eco, 'تسوق'),
  ServiceItem('صيدليات', Icons.local_pharmacy, 'صحة'),
  ServiceItem('عالم الأطفال', Icons.child_care, 'تسوق'),
  ServiceItem('بنزين ووقود', Icons.local_gas_station, 'سيارات'),
  ServiceItem('تصليح سيارات', Icons.build, 'سيارات'),
  ServiceItem('سطحة وسحب سيارات', Icons.car_repair, 'سيارات'),
  ServiceItem('اشتراك بطارية', Icons.battery_charging_full, 'سيارات'),
  ServiceItem('بنچر وإطارات', Icons.tire_repair, 'سيارات'),
  ServiceItem('خدمات المنزل', Icons.home_repair_service, 'المنزل'),
  ServiceItem('سباك', Icons.plumbing, 'المنزل'),
  ServiceItem('كهربائي', Icons.electrical_services, 'المنزل'),
  ServiceItem('تنظيف', Icons.cleaning_services, 'المنزل'),
  ServiceItem('ماء وثلج', Icons.water_drop, 'توصيل'),
  ServiceItem('طرود ومستندات', Icons.inventory_2, 'توصيل'),
  ServiceItem('غسيل وكي', Icons.local_laundry_service, 'المنزل'),
  ServiceItem('حلاقة وعناية', Icons.content_cut, 'خدمات'),
  ServiceItem('موبايلات وصيانة', Icons.phone_android, 'تقنية'),
  ServiceItem('إنترنت وشبكات', Icons.wifi, 'تقنية'),
  ServiceItem('مستلزمات الحيوانات', Icons.pets, 'تسوق'),
  ServiceItem('خدمات أخرى', Icons.more_horiz, 'خدمات'),
];

class TawseelakApp extends StatelessWidget {
  const TawseelakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '$appName - $developerName',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: gold),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: dark,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedTab = 0;
  String selectedRole = 'زبون';
  String selectedProvince = 'القادسية';
  String paymentMethod = 'نقداً عند الاستلام';
  String searchText = '';

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final businessController = TextEditingController();

  final pickupController = TextEditingController();
  final destinationController = TextEditingController();
  final detailsController = TextEditingController();
  final budgetController = TextEditingController();

  List<Map<String, dynamic>> orders = [];
  Map<String, dynamic> profiles = {};

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final decodedOrders =
          jsonDecode(prefs.getString('tawseelak_orders') ?? '[]');

      final decodedProfiles =
          jsonDecode(prefs.getString('tawseelak_profiles') ?? '{}');

      if (!mounted) return;

      setState(() {
        orders = (decodedOrders as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        profiles = Map<String, dynamic>.from(decodedProfiles);

        loadProfileFields();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        orders = [];
        profiles = {};
      });
    }
  }

  void loadProfileFields() {
    final profile = profiles[selectedRole];

    nameController.text =
        profile is Map ? (profile['name'] ?? '') : '';

    phoneController.text =
        profile is Map ? (profile['phone'] ?? '') : '';

    addressController.text =
        profile is Map ? (profile['address'] ?? '') : '';

    businessController.text =
        profile is Map ? (profile['business'] ?? '') : '';

    selectedProvince =
        profile is Map && provinces.contains(profile['province'])
            ? profile['province']
            : 'القادسية';
  }

  void showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      showMessage('يرجى كتابة الاسم والهاتف والمنطقة');
      return;
    }

    profiles[selectedRole] = {
      'role': selectedRole,
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'province': selectedProvince,
      'business': businessController.text.trim(),
    };

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'tawseelak_profiles',
      jsonEncode(profiles),
    );

    showMessage('تم حفظ بيانات الحساب على هذا الجهاز');
  }

  Future<void> createOrder(String serviceName) async {
    if (pickupController.text.trim().isEmpty ||
        detailsController.text.trim().isEmpty) {
      showMessage('يرجى كتابة عنوانك وتفاصيل الطلب');
      return;
    }

    final order = <String, dynamic>{
      'id': 'TWS-${DateTime.now().millisecondsSinceEpoch}',
      'date': DateTime.now().toIso8601String(),
      'service': serviceName,
      'role': selectedRole,
      'customer': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'province': selectedProvince,
      'pickup': pickupController.text.trim(),
      'destination': destinationController.text.trim(),
      'details': detailsController.text.trim(),
      'budget': budgetController.text.trim(),
      'payment': paymentMethod,
      'status': 'طلب محفوظ محلياً',
    };

    orders.insert(0, order);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'tawseelak_orders',
      jsonEncode(orders),
    );

    pickupController.clear();
    destinationController.clear();
    detailsController.clear();
    budgetController.clear();

    if (!mounted) return;

    setState(() {
      selectedTab = 2;
    });

    showMessage('تم حفظ الطلب بنجاح');
  }

  void changeRole(String role) {
    setState(() {
      selectedRole = role;
      loadProfileFields();
    });
  }

  Widget textField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: gold,
                radius: 27,
                child: Icon(
                  Icons.delivery_dining,
                  size: 33,
                  color: dark,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'توصيلك',
                      style: TextStyle(
                        color: gold,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'علاوي ال حمادي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'كلشي تحتاجه، يصلك بلمحة!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'تسوق، مطاعم، تكسي، توصيل طلبات، '
            'وقود، وصيانة سيارات وخدمات منزلية.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: dark,
              ),
              onPressed: () {
                setState(() => selectedTab = 1);
              },
              child: const Text('إنشاء حساب'),
            ),
          ),
        ],
      ),
    );
  }

  Widget homePage() {
    final filteredServices = serviceItems.where((service) {
      return service.name.contains(searchText);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        buildHeader(),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) {
            setState(() => searchText = value);
          },
          decoration: const InputDecoration(
            hintText: 'ابحث عن خدمة...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'خدمات توصيلك',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredServices.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, index) {
            final service = filteredServices[index];

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => openOrderForm(service),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      service.icon,
                      size: 36,
                      color: dark,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        service.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Divider(),
        const Text(
          'حقوق التطبيق محفوظة',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        const Text(
          developerName,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        OutlinedButton.icon(
          onPressed: showDeveloperInfo,
          icon: const Icon(Icons.support_agent),
          label: const Text('التواصل مع المطور'),
        ),
      ],
    );
  }

  void openOrderForm(ServiceItem service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
              height: MediaQuery.of(sheetContext).size.height * 0.85,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Icon(service.icon, size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'طلب ${service.name}',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedProvince,
                    decoration: const InputDecoration(
                      labelText: 'المحافظة',
                    ),
                    items: provinces.map((province) {
                      return DropdownMenuItem(
                        value: province,
                        child: Text(province),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedProvince = value;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  textField(pickupController, 'عنوان الاستلام'),
                  const SizedBox(height: 12),
                  textField(destinationController, 'عنوان التوصيل'),
                  const SizedBox(height: 12),
                  textField(
                    detailsController,
                    'تفاصيل الطلب',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  textField(
                    budgetController,
                    'الميزانية بالدينار العراقي (اختياري)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'طريقة الدفع',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'نقداً عند الاستلام',
                        child: Text('نقداً عند الاستلام'),
                      ),
                      DropdownMenuItem(
                        value: 'اتفاق مباشر',
                        child: Text('اتفاق مباشر'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) paymentMethod = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: dark,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      createOrder(service.name);
                    },
                    child: const Text('تأكيد الطلب'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget accountPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'حسابي',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: selectedRole,
          decoration: const InputDecoration(
            labelText: 'نوع الحساب',
          ),
          items: accountTypes.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) changeRole(value);
          },
        ),
        const SizedBox(height: 12),
        textField(nameController, 'الاسم الكامل'),
        const SizedBox(height: 12),
        textField(
          phoneController,
          'رقم الهاتف',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedProvince,
          decoration: const InputDecoration(
            labelText: 'المحافظة',
          ),
          items: provinces.map((province) {
            return DropdownMenuItem(
              value: province,
              child: Text(province),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedProvince = value);
            }
          },
        ),
        const SizedBox(height: 12),
        textField(addressController, 'المدينة والمنطقة'),
        if ([
          'صاحب دلفري',
          'صاحب ماركت',
          'صاحب مطعم',
          'صاحب ماركة / متجر',
          'مقدم خدمات',
        ].contains(selectedRole)) ...[
          const SizedBox(height: 12),
          textField(businessController, 'اسم المحل أو النشاط'),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: dark,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: saveProfile,
            child: const Text('حفظ الحساب'),
          ),
        ),
        const SizedBox(height: 25),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.verified_user, size: 35),
                SizedBox(height: 10),
                Text(
                  'توصيلك',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(developerName),
                SizedBox(height: 5),
                Text('جميع الحقوق محفوظة ©'),
                SizedBox(height: 8),
                Text(developerPhone),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'تنبيه: الحسابات في هذه النسخة تجريبية، '
          'ولا يوجد تحقق من الهوية أو كلمة المرور. '
          'لا تدخل بيانات دفع أو معلومات سرية.',
          style: TextStyle(
            color: Colors.black54,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget ordersPage() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        Text(
          'طلباتي (${orders.length})',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),
        if (orders.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Text('لا توجد طلبات محفوظة حتى الآن.'),
            ),
          ),
        ...orders.map((order) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['service'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('رقم الطلب: ${order['id']}'),
                  Text('المحافظة: ${order['province']}'),
                  Text('الزبون: ${order['customer']}'),
                  Text('الهاتف: ${order['phone']}'),
                  Text('الاستلام: ${order['pickup']}'),
                  Text('الوجهة: ${order['destination']}'),
                  Text('التفاصيل: ${order['details']}'),
                  Text('الدفع: ${order['payment']}'),
                  const SizedBox(height: 8),
                  const Text(
                    'الحالة: محفوظ محلياً',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          );
        }),
        if (orders.isNotEmpty)
          TextButton.icon(
            onPressed: clearOrders,
            icon: const Icon(Icons.delete_outline),
            label: const Text('مسح الطلبات'),
          ),
      ],
    );
  }

  Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tawseelak_orders');

    if (!mounted) return;

    setState(() => orders = []);
    showMessage('تم مسح الطلبات');
  }

  void showDeveloperInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('توصيلك'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إدارة وتطوير'),
                SizedBox(height: 5),
                Text(
                  developerName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('واتساب المطور:'),
                SelectableText(developerPhone),
                SizedBox(height: 12),
                Text('جميع الحقوق محفوظة ©'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    businessController.dispose();
    pickupController.dispose();
    destinationController.dispose();
    detailsController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              CircleAvatar(
                backgroundColor: gold,
                child: Icon(
                  Icons.delivery_dining,
                  color: dark,
                  size: 29,
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'توصيلك',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'علاوي ال حمادي',
                    style: TextStyle(
                      fontSize: 11,
                      color: gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: showDeveloperInfo,
              icon: const Icon(Icons.support_agent),
              tooltip: 'التواصل مع المطور',
            ),
          ],
        ),
        body: IndexedStack(
          index: selectedTab,
          children: [
            homePage(),
            accountPage(),
            ordersPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: (index) {
            setState(() => selectedTab = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'حسابي',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'طلباتي',
            ),
          ],
        ),
      ),
    );
  }
}