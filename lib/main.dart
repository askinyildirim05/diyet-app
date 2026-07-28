import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const DiyetApp());
}

// ================= REKLAM KİMLİKLERİ =================
const kBannerAdId = 'ca-app-pub-5113050441647801/5523000977';
const kInterstitialAdId = 'ca-app-pub-5113050441647801/9270674297';

// ================= RENKLER =================
const kBg = Color(0xFFF4F1EA);
const kCard = Colors.white;
const kInk = Color(0xFF2E2A24);
const kMuted = Color(0xFF8A8175);
const kAccent = Color(0xFFB3541E);
const kGreen = Color(0xFF3E7D4E);
const kRed = Color(0xFFB3392E);
const kWater = Color(0xFF3E7AA8);
const kLine = Color(0xFFE8E2D6);

// ================= YİYECEK VERİTABANI =================
// [ad, porsiyon açıklaması, kalori]
const kFoods = [
  ["Yumurta (haşlanmış/sahanda)", "1 adet", 75],
  ["Omlet (2 yumurta)", "1 porsiyon", 180],
  ["Menemen", "1 porsiyon", 220],
  ["Sucuklu yumurta", "1 porsiyon", 350],
  ["Beyaz peynir", "30 gr", 80],
  ["Kaşar peyniri", "1 dilim", 90],
  ["Lor peyniri", "50 gr", 60],
  ["Zeytin", "5 adet", 25],
  ["Tereyağı", "1 tatlı kaşığı", 90],
  ["Bal", "1 tatlı kaşığı", 45],
  ["Reçel", "1 tatlı kaşığı", 40],
  ["Pekmez", "1 tatlı kaşığı", 60],
  ["Tahin", "1 tatlı kaşığı", 90],
  ["Domates", "1 orta boy", 20],
  ["Salatalık", "1 adet", 15],
  ["Yulaf (sütlü)", "1 kase", 200],
  ["Mısır gevreği (sütlü)", "1 kase", 220],
  ["Beyaz ekmek", "1 dilim", 70],
  ["Tam buğday ekmeği", "1 dilim", 65],
  ["Çavdar ekmeği", "1 dilim", 65],
  ["Kepek ekmeği", "1 dilim", 60],
  ["Simit", "yarım", 150],
  ["Poğaça", "1 adet", 230],
  ["Açma", "1 adet", 280],
  ["Börek (peynirli)", "1 dilim", 300],
  ["Mercimek çorbası", "1 kase", 130],
  ["Ezogelin çorbası", "1 kase", 140],
  ["Tarhana çorbası", "1 kase", 110],
  ["Yayla çorbası", "1 kase", 100],
  ["Domates çorbası", "1 kase", 90],
  ["Tavuk suyu çorbası", "1 kase", 80],
  ["Izgara tavuk göğsü", "100 gr", 165],
  ["Izgara tavuk but (derisiz)", "1 adet", 200],
  ["Tavuk sote", "1 porsiyon", 280],
  ["Hindi ızgara", "100 gr", 135],
  ["Izgara köfte", "3 adet", 220],
  ["Izgara dana eti", "100 gr", 250],
  ["Kuzu pirzola", "2 adet", 400],
  ["Adana kebap", "1 porsiyon", 450],
  ["Tavuk döner", "1 porsiyon", 400],
  ["Et döner", "1 porsiyon", 500],
  ["Et sote / kavurma", "1 porsiyon", 380],
  ["Izgara balık (levrek/çipura)", "1 porsiyon", 180],
  ["Hamsi tava", "1 porsiyon", 400],
  ["Ton balığı (süzülmüş)", "1 kutu", 120],
  ["Kuru fasulye", "1 kase", 280],
  ["Nohut yemeği", "1 kase", 260],
  ["Mercimek yemeği", "1 kase", 240],
  ["Zeytinyağlı fasulye", "1 porsiyon", 200],
  ["Zeytinyağlı enginar", "1 porsiyon", 180],
  ["Ispanak yemeği", "1 kase", 160],
  ["Sebze yemeği (karışık)", "1 kase", 150],
  ["Kabak yemeği", "1 kase", 120],
  ["Patlıcan musakka", "1 porsiyon", 350],
  ["İmam bayıldı", "1 porsiyon", 280],
  ["Zeytinyağlı dolma", "6 adet", 300],
  ["Etli yaprak sarma", "6 adet", 320],
  ["Haşlanmış brokoli", "1 kase", 55],
  ["Fırın sebze", "1 porsiyon", 130],
  ["Pirinç pilavı", "1 kase", 250],
  ["Bulgur pilavı", "1 kase", 230],
  ["Makarna (soslu)", "1 porsiyon", 350],
  ["Mantı (yoğurtlu)", "1 porsiyon", 450],
  ["Kısır", "1 kase", 300],
  ["Mercimek köftesi", "3 adet", 180],
  ["Haşlanmış patates", "1 orta boy", 110],
  ["Patates kızartması", "1 porsiyon", 400],
  ["Mevsim salata (yağsız)", "1 kase", 40],
  ["Çoban salata", "1 kase", 60],
  ["Yoğurt", "1 kase", 100],
  ["Cacık", "1 kase", 80],
  ["Ayran", "1 bardak", 40],
  ["Humus", "2 kaşık", 120],
  ["Lahmacun", "1 adet", 280],
  ["Kıymalı pide", "1 dilim", 180],
  ["Hamburger", "1 adet", 550],
  ["Pizza", "1 dilim", 280],
  ["Çiğ köfte dürüm", "1 adet", 350],
  ["Tost (kaşarlı)", "1 adet", 350],
  ["Dürüm döner", "1 adet", 500],
  ["Elma", "1 orta boy", 80],
  ["Muz", "1 orta boy", 105],
  ["Portakal", "1 orta boy", 65],
  ["Mandalina", "1 adet", 45],
  ["Armut", "1 orta boy", 85],
  ["Şeftali", "1 orta boy", 55],
  ["Karpuz", "1 ince dilim", 60],
  ["Kavun", "1 ince dilim", 50],
  ["Üzüm", "100 gr", 70],
  ["Çilek", "1 kase", 50],
  ["Kiraz", "10 adet", 50],
  ["Hurma", "1 adet", 25],
  ["Kuru incir", "1 adet", 50],
  ["Kuru kayısı", "3 adet", 45],
  ["Badem", "10 adet", 70],
  ["Ceviz", "3 tam adet", 100],
  ["Fındık", "1 avuç", 180],
  ["Antep fıstığı", "1 avuç", 160],
  ["Leblebi", "1 avuç", 90],
  ["Çay (şekersiz)", "1 bardak", 2],
  ["Türk kahvesi (sade)", "1 fincan", 7],
  ["Türk kahvesi (şekerli)", "1 fincan", 40],
  ["Filtre kahve (sade)", "1 kupa", 5],
  ["Süt", "1 bardak", 120],
  ["Kefir", "1 bardak", 100],
  ["Meyve suyu", "1 bardak", 110],
  ["Gazoz / Kola", "1 bardak", 105],
  ["Limonata", "1 bardak", 90],
  ["Sütlaç", "1 kase", 260],
  ["Kazandibi", "1 kase", 280],
  ["Puding", "1 kase", 220],
  ["Dondurma", "1 top", 120],
  ["Baklava", "1 dilim", 340],
  ["Künefe", "1 porsiyon", 600],
  ["Kek", "1 dilim", 250],
  ["Kurabiye", "2 adet", 130],
  ["Bisküvi", "2 adet", 90],
  ["Sütlü çikolata", "1 kare", 60],
  ["Bitter çikolata", "2 kare", 100],
  ["Helva (tahin)", "1 dilim", 230],
];

const kMeals = ["Sabah", "Öğle", "Akşam", "Ara Öğün"];
const kMealIcons = {"Sabah": "🌅", "Öğle": "☀️", "Akşam": "🌙", "Ara Öğün": "🍎"};
const kMealFrac = {"Sabah": 0.25, "Öğle": 0.35, "Akşam": 0.30, "Ara Öğün": 0.10};

const kPlanPools = {
  "Sabah": [
    "Yumurta (haşlanmış/sahanda)", "Omlet (2 yumurta)", "Beyaz peynir",
    "Lor peyniri", "Zeytin", "Tam buğday ekmeği", "Çavdar ekmeği",
    "Domates", "Salatalık", "Yulaf (sütlü)", "Süt", "Çay (şekersiz)"
  ],
  "Öğle": [
    "Izgara tavuk göğsü", "Izgara köfte", "Izgara balık (levrek/çipura)",
    "Hindi ızgara", "Mercimek çorbası", "Ezogelin çorbası", "Kuru fasulye",
    "Nohut yemeği", "Bulgur pilavı", "Sebze yemeği (karışık)",
    "Mevsim salata (yağsız)", "Çoban salata", "Yoğurt", "Ayran",
    "Tam buğday ekmeği"
  ],
  "Akşam": [
    "Izgara tavuk göğsü", "Izgara balık (levrek/çipura)", "Hindi ızgara",
    "Tavuk sote", "Zeytinyağlı fasulye", "Ispanak yemeği", "Kabak yemeği",
    "Zeytinyağlı enginar", "Haşlanmış brokoli", "Fırın sebze",
    "Mercimek çorbası", "Mevsim salata (yağsız)", "Çoban salata",
    "Yoğurt", "Cacık"
  ],
  "Ara Öğün": [
    "Elma", "Armut", "Portakal", "Mandalina", "Şeftali", "Çilek",
    "Badem", "Ceviz", "Yoğurt", "Kefir", "Süt", "Hurma",
    "Kuru kayısı", "Leblebi"
  ],
};

const kActivities = [
  ["Hareketsiz (masa başı, spor yok)", 1.2],
  ["Az hareketli (haftada 1-3 gün yürüyüş)", 1.375],
  ["Orta aktif (haftada 3-5 gün spor)", 1.55],
  ["Aktif (haftada 6-7 gün spor)", 1.725],
  ["Çok aktif (ağır iş / yoğun spor)", 1.9],
];

const kRates = [
  ["Haftada 0,25 kg (yavaş ve kalıcı)", 0.25],
  ["Haftada 0,5 kg (önerilen)", 0.5],
  ["Haftada 0,75 kg (hızlı)", 0.75],
  ["Haftada 1 kg (çok hızlı — dikkat)", 1.0],
];

const kGunler = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
const kAylar = [
  "", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
  "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
];

String fmtDate(DateTime d) =>
    "${d.day} ${kAylar[d.month]} ${d.year}, ${kGunler[d.weekday - 1]}";

int foodKcal(String ad) =>
    kFoods.firstWhere((f) => f[0] == ad)[2] as int;

String foodPorsiyon(String ad) =>
    kFoods.firstWhere((f) => f[0] == ad)[1] as String;

// ================= UYGULAMA =================
class DiyetApp extends StatelessWidget {
  const DiyetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diyet Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent, primary: kAccent),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg, foregroundColor: kInk, elevation: 0,
          titleTextStyle: TextStyle(color: kInk, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          color: kCard, elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: kLine),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccent, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  Map<String, dynamic> state = {"profile": null, "days": {}};
  int tabIndex = 0;
  DateTime currentDay = DateTime.now();
  bool loaded = false;
  Map<String, List<String>>? currentPlan;

  // profil form kontrolcüleri
  final cName = TextEditingController();
  final cAge = TextEditingController();
  final cHeight = TextEditingController();
  final cWeight = TextEditingController();
  final cTargetW = TextEditingController();
  String pGender = "Erkek";
  int pActivity = 0;
  int pRate = 1;

  final cWeightEntry = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _loadBanner();
    _loadInterstitial();
  }

  // ================= REKLAMLAR =================
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  InterstitialAd? _interstitial;
  int _adCounter = 0;

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: kBannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _bannerLoaded = true);
        },
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: kInterstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Her 6 yiyecek ekleyişte bir ve liste uygulanınca tam ekran reklam gösterir.
  void _maybeShowInterstitial() {
    _adCounter++;
    if (_adCounter % 6 != 0 || _interstitial == null) return;
    _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, e) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    _interstitial!.show();
    _interstitial = null;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitial?.dispose();
    cName.dispose();
    cAge.dispose();
    cHeight.dispose();
    cWeight.dispose();
    cTargetW.dispose();
    cWeightEntry.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('diyet_state');
    if (raw != null) {
      try {
        final data = jsonDecode(raw);
        if (data is Map<String, dynamic>) {
          state = data;
          state.putIfAbsent("days", () => {});
        }
      } catch (_) {}
    }
    if (state["profile"] != null) _fillProfileForm();
    setState(() {
      loaded = true;
      if (state["profile"] == null) tabIndex = 3; // önce profil
    });
  }

  void _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('diyet_state', jsonEncode(state));
  }

  String _key(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Map<String, dynamic> dayData(DateTime d) {
    final k = _key(d);
    final days = state["days"] as Map<String, dynamic>;
    if (!days.containsKey(k)) {
      days[k] = {
        "meals": {for (var m in kMeals) m: []},
        "water": 0,
        "weight": null,
      };
    }
    final dd = days[k] as Map<String, dynamic>;
    dd.putIfAbsent("water", () => 0);
    dd["meals"] ??= {for (var m in kMeals) m: []};
    for (var m in kMeals) {
      (dd["meals"] as Map).putIfAbsent(m, () => []);
    }
    return dd;
  }

  // ---- hesaplamalar (Mifflin-St Jeor) ----
  Map<String, dynamic>? calcTargets() {
    final p = state["profile"];
    if (p == null) return null;
    final w = (p["weight"] as num).toDouble();
    final h = (p["height"] as num).toDouble();
    final a = (p["age"] as num).toInt();
    double bmr;
    int floor;
    if (p["gender"] == "E") {
      bmr = 10 * w + 6.25 * h - 5 * a + 5;
      floor = 1500;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * a - 161;
      floor = 1200;
    }
    final tdee = bmr * (p["activity"] as num).toDouble();
    final deficit = (p["goal_rate"] as num).toDouble() * 7700 / 7;
    final target = (tdee - deficit).clamp(floor.toDouble(), 10000.0);
    return {
      "bmr": bmr.round(),
      "tdee": tdee.round(),
      "target": target.round(),
      "deficit": deficit.round(),
      "bmi": w / ((h / 100) * (h / 100)),
      "water_ml": ((w * 35) / 50).round() * 50,
      "protein": (target * 0.30 / 4).round(),
      "carb": (target * 0.40 / 4).round(),
      "fat": (target * 0.30 / 9).round(),
    };
  }

  String bmiText(double b) {
    if (b < 18.5) return "Zayıf";
    if (b < 25) return "Normal ✓";
    if (b < 30) return "Fazla kilolu";
    return "Obez";
  }

  // ================= GÖVDE =================
  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: kAccent)));
    }
    final t = calcTargets();
    return Scaffold(
      appBar: AppBar(
        title: const Text("🥗 Diyet Takip"),
        actions: [
          if (t != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7E8DD),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text("🎯 ${t["target"]} kk",
                  style: const TextStyle(color: kAccent, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: IndexedStack(
        index: tabIndex,
        children: [
          _buildToday(t),
          _buildWeight(),
          _buildPlan(t),
          _buildProfile(t),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_bannerLoaded && _bannerAd != null)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          NavigationBar(
            selectedIndex: tabIndex,
            onDestinationSelected: (i) => setState(() => tabIndex = i),
            backgroundColor: kCard,
            destinations: const [
              NavigationDestination(icon: Text("🍽", style: TextStyle(fontSize: 20)), label: "Beslenme"),
              NavigationDestination(icon: Text("⚖", style: TextStyle(fontSize: 20)), label: "Kilo"),
              NavigationDestination(icon: Text("📋", style: TextStyle(fontSize: 20)), label: "Liste"),
              NavigationDestination(icon: Text("👤", style: TextStyle(fontSize: 20)), label: "Profil"),
            ],
          ),
        ],
      ),
    );
  }

  // ================= BUGÜN (BESLENME) =================
  Widget _buildToday(Map<String, dynamic>? t) {
    final dd = dayData(currentDay);
    int total = 0;
    for (var m in kMeals) {
      for (var it in (dd["meals"][m] as List)) {
        total += (it["kcal"] as num).toInt();
      }
    }
    final isToday = _key(currentDay) == _key(DateTime.now());

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // tarih gezinme
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(
                        () => currentDay = currentDay.subtract(const Duration(days: 1)))),
                Expanded(
                  child: Column(children: [
                    Text(fmtDate(currentDay),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (isToday)
                      const Text("Bugün", style: TextStyle(color: kMuted, fontSize: 12)),
                  ]),
                ),
                TextButton(
                    onPressed: () => setState(() => currentDay = DateTime.now()),
                    child: const Text("Bugün")),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () =>
                        setState(() => currentDay = currentDay.add(const Duration(days: 1)))),
              ],
            ),
          ),
        ),

        // toplam kalori kartı
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              if (t != null) ...[
                Builder(builder: (_) {
                  final target = t["target"] as int;
                  final left = target - total;
                  final ok = left >= 0;
                  return Column(children: [
                    LinearProgressIndicator(
                      value: (total / target).clamp(0.0, 1.0),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(99),
                      backgroundColor: const Color(0xFFEEE7D9),
                      color: ok ? kAccent : kRed,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ok
                          ? "$total / $target kk — ✅ $left kk hakkın kaldı"
                          : "$total / $target kk — ⚠ Hedefi ${-left} kk aştın!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15,
                          color: total == 0 ? kInk : (ok ? kGreen : kRed)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Öneri: ${t["protein"]} gr protein · ${t["carb"]} gr karb · ${t["fat"]} gr yağ",
                      style: const TextStyle(color: kMuted, fontSize: 12),
                    ),
                  ]);
                }),
              ] else ...[
                Text("Toplam: $total kk",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const Text("Hedef için önce Profil sekmesini doldur",
                    style: TextStyle(color: kMuted, fontSize: 12)),
              ],
            ]),
          ),
        ),

        // su kartı
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("💧 Su Takibi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Builder(builder: (_) {
                final glasses = (dd["water"] as num).toInt();
                final goal = t != null ? ((t["water_ml"] as int) / 200).round() : 8;
                return Column(children: [
                  Row(children: [
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        dd["water"] = glasses + 1;
                        _save();
                      }),
                      icon: const Icon(Icons.add),
                      label: const Text("1 Bardak"),
                      style: ElevatedButton.styleFrom(backgroundColor: kWater),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: glasses > 0
                          ? () => setState(() {
                                dd["water"] = glasses - 1;
                                _save();
                              })
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    const Spacer(),
                    Text("$glasses / $goal bardak",
                        style: const TextStyle(
                            color: kWater, fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (glasses / goal).clamp(0.0, 1.0),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(99),
                    backgroundColor: const Color(0xFFEEE7D9),
                    color: kWater,
                  ),
                  if (glasses >= goal)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text("✅ Günlük su hedefin tamam!",
                          style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
                    ),
                ]);
              }),
            ]),
          ),
        ),

        // öğün kartları
        for (var m in kMeals) _mealCard(dd, m),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _mealCard(Map<String, dynamic> dd, String meal) {
    final items = dd["meals"][meal] as List;
    int sub = 0;
    for (var it in items) {
      sub += (it["kcal"] as num).toInt();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text("${kMealIcons[meal]} $meal",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Spacer(),
            Text("$sub kk", style: const TextStyle(color: kAccent, fontWeight: FontWeight.bold)),
          ]),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("Henüz bir şey eklenmedi",
                  style: TextStyle(color: kMuted, fontSize: 13)),
            ),
          for (int i = 0; i < items.length; i++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(items[i]["food"], style: const TextStyle(fontSize: 14)),
              subtitle: Text("${(items[i]["por"] as num)} porsiyon",
                  style: const TextStyle(fontSize: 12, color: kMuted)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("${items[i]["kcal"]} kk",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: kMuted),
                  onPressed: () => setState(() {
                    items.removeAt(i);
                    _save();
                  }),
                ),
              ]),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showFoodPicker(meal),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Ekle"),
            ),
          ),
        ]),
      ),
    );
  }

  // ---- yiyecek seçme penceresi ----
  void _showFoodPicker(String meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        String query = "";
        return StatefulBuilder(builder: (ctx, setSheet) {
          final results = kFoods
              .where((f) => (f[0] as String).toLowerCase().contains(query.toLowerCase()))
              .toList();
          return Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.72,
              child: Column(children: [
                Text("$meal — Yiyecek Ekle",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Ara... (örn: tavuk, simit, elma)",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: kBg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setSheet(() => query = v),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final f = results[i];
                      return ListTile(
                        dense: true,
                        title: Text(f[0] as String, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(f[1] as String,
                            style: const TextStyle(fontSize: 12, color: kMuted)),
                        trailing: Text("${f[2]} kk",
                            style: const TextStyle(
                                color: kAccent, fontWeight: FontWeight.bold)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _askPortion(meal, f);
                        },
                      );
                    },
                  ),
                ),
              ]),
            ),
          );
        });
      },
    );
  }

  void _askPortion(String meal, List f) {
    final cPortion = TextEditingController(text: "1");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: Text(f[0] as String, style: const TextStyle(fontSize: 16)),
        content: TextField(
          controller: cPortion,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: "Kaç porsiyon? (${f[1]})",
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
          ElevatedButton(
            onPressed: () {
              final por = double.tryParse(cPortion.text.replaceAll(",", ".")) ?? 0;
              if (por <= 0) return;
              setState(() {
                dayData(currentDay)["meals"][meal].add({
                  "food": f[0],
                  "por": por,
                  "kcal": ((f[2] as int) * por).round(),
                });
                _save();
              });
              Navigator.pop(ctx);
              _maybeShowInterstitial();
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }

  // ================= KİLO =================
  List<MapEntry<String, double>> _weightEntries() {
    final out = <MapEntry<String, double>>[];
    (state["days"] as Map<String, dynamic>).forEach((k, v) {
      final w = (v as Map)["weight"];
      if (w != null) out.add(MapEntry(k, (w as num).toDouble()));
    });
    out.sort((a, b) => a.key.compareTo(b.key));
    return out;
  }

  Widget _buildWeight() {
    final entries = _weightEntries();
    final p = state["profile"];
    final goalW = p?["target_weight"] as num?;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: cWeightEntry,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Bugünkü kilon (kg)",
                    hintText: "örn: 82.5",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final w = double.tryParse(cWeightEntry.text.replaceAll(",", "."));
                  if (w == null || w < 30 || w > 300) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Geçerli bir kilo gir (30-300)")));
                    return;
                  }
                  setState(() {
                    dayData(DateTime.now())["weight"] = w;
                    if (state["profile"] != null) state["profile"]["weight"] = w;
                    cWeightEntry.clear();
                    _save();
                  });
                },
                child: const Text("Kaydet"),
              ),
            ]),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Builder(builder: (_) {
              if (entries.isEmpty) {
                return const Text("Henüz kilo kaydı yok. Yukarıdan bugünkü kilonu gir.",
                    style: TextStyle(color: kMuted));
              }
              final firstW = entries.first.value, lastW = entries.last.value;
              final change = lastW - firstW;
              String goalLine = "";
              if (goalW != null) {
                final left = lastW - goalW.toDouble();
                goalLine = left > 0
                    ? "\n🎯 Hedef: ${goalW.toStringAsFixed(0)} kg — ${left.toStringAsFixed(1)} kg kaldı, devam!"
                    : "\n🎉 Hedef kilona ulaştın!";
              }
              return Text(
                "Başlangıç: ${firstW.toStringAsFixed(1)} kg → Şu an: ${lastW.toStringAsFixed(1)} kg "
                "(${change >= 0 ? '📈' : '📉'} ${change.toStringAsFixed(1)} kg)$goalLine",
                style: const TextStyle(fontSize: 14, height: 1.5),
              );
            }),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("📈 Kilo Grafiği",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                width: double.infinity,
                child: entries.length < 2
                    ? const Center(
                        child: Text("Grafik için en az 2 gün kayıt gerekli",
                            style: TextStyle(color: kMuted)))
                    : CustomPaint(
                        painter: WeightChartPainter(
                          entries.map((e) => e.value).toList(),
                          goalW?.toDouble(),
                        ),
                      ),
              ),
            ]),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("🗓 Son Kayıtlar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 6),
              for (var e in entries.reversed.take(14))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(children: [
                    Expanded(child: Text(fmtDate(DateTime.parse(e.key)))),
                    Text("${e.value.toStringAsFixed(1)} kg",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  // ================= DİYET LİSTESİ =================
  Widget _buildPlan(Map<String, dynamic>? t) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("📋 Otomatik Günlük Diyet Listesi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                t != null
                    ? "Hedefin: ${t["target"]} kk/gün · Dağılım: Sabah %25, Öğle %35, Akşam %30, Ara %10\nHer oluşturmada farklı bir menü çıkar."
                    : "Liste için önce Profil sekmesinden bilgilerini gir.",
                style: const TextStyle(color: kMuted, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(children: [
                ElevatedButton.icon(
                  onPressed: t == null ? null : _makePlan,
                  icon: const Text("🔀"),
                  label: const Text("Liste Oluştur"),
                ),
                const SizedBox(width: 8),
                if (currentPlan != null)
                  OutlinedButton.icon(
                    onPressed: _applyPlan,
                    icon: const Text("✔"),
                    label: const Text("Bugüne Uygula"),
                  ),
              ]),
            ]),
          ),
        ),
        if (currentPlan != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var m in kMeals) ...[
                  Text("${kMealIcons[m]} $m",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15, color: kAccent)),
                  const SizedBox(height: 4),
                  for (var ad in currentPlan![m]!)
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 2),
                      child: Text("• $ad — ${foodPorsiyon(ad)} (${foodKcal(ad)} kk)",
                          style: const TextStyle(fontSize: 13.5)),
                    ),
                  const SizedBox(height: 10),
                ],
                Builder(builder: (_) {
                  int tot = 0;
                  currentPlan!.forEach((_, items) {
                    for (var ad in items) {
                      tot += foodKcal(ad);
                    }
                  });
                  return Text(
                    "Toplam: ~$tot kk / Hedef: ${t?["target"] ?? '-'} kk\n"
                    "💧 Ayrıca ${t?["water_ml"] ?? 2000} ml su içmeyi unutma!",
                    style: const TextStyle(fontWeight: FontWeight.bold, height: 1.4),
                  );
                }),
              ]),
            ),
          ),
      ],
    );
  }

  void _makePlan() {
    final t = calcTargets()!;
    final target = t["target"] as int;
    final plan = <String, List<String>>{};
    for (var meal in kMeals) {
      final budget = target * kMealFrac[meal]!;
      final pool = List<String>.from(kPlanPools[meal]!)..shuffle();
      final items = <String>[];
      int total = 0;
      for (var ad in pool) {
        final kcal = foodKcal(ad);
        if (total + kcal <= budget * 1.05) {
          items.add(ad);
          total += kcal;
        }
        if (total >= budget * 0.85) break;
      }
      plan[meal] = items;
    }
    setState(() => currentPlan = plan);
  }

  void _applyPlan() {
    if (currentPlan == null) return;
    final dd = dayData(currentDay);
    int existing = 0;
    for (var m in kMeals) {
      existing += (dd["meals"][m] as List).length;
    }
    void doApply() {
      setState(() {
        for (var m in kMeals) {
          dd["meals"][m] = [
            for (var ad in currentPlan![m]!)
              {"food": ad, "por": 1, "kcal": foodKcal(ad)}
          ];
        }
        _save();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Diyet listesi güne uygulandı ✔")));
      _maybeShowInterstitial();
    }

    if (existing > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: kCard,
          title: const Text("Emin misin?"),
          content: Text("Bu günde zaten $existing kayıt var. Liste üzerine yazılsın mı?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  doApply();
                },
                child: const Text("Evet, uygula")),
          ],
        ),
      );
    } else {
      doApply();
    }
  }

  // ================= PROFİL =================
  void _fillProfileForm() {
    final p = state["profile"];
    cName.text = p["name"] ?? "";
    cAge.text = "${p["age"]}";
    cHeight.text = "${(p["height"] as num).toDouble().toStringAsFixed(0)}";
    cWeight.text = "${(p["weight"] as num).toDouble()}";
    if (p["target_weight"] != null) cTargetW.text = "${p["target_weight"]}";
    pGender = p["gender"] == "E" ? "Erkek" : "Kadın";
    for (int i = 0; i < kActivities.length; i++) {
      if (((kActivities[i][1] as double) - (p["activity"] as num).toDouble()).abs() < 0.001) {
        pActivity = i;
      }
    }
    for (int i = 0; i < kRates.length; i++) {
      if (((kRates[i][1] as double) - (p["goal_rate"] as num).toDouble()).abs() < 0.001) {
        pRate = i;
      }
    }
  }

  Widget _buildProfile(Map<String, dynamic>? t) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("👤 Profil Bilgileri",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _field(cName, "Adın"),
              Row(children: [
                Expanded(child: _field(cAge, "Yaşın", number: true)),
                const SizedBox(width: 8),
                Expanded(child: _field(cHeight, "Boy (cm)", number: true)),
              ]),
              Row(children: [
                Expanded(child: _field(cWeight, "Kilo (kg)", number: true)),
                const SizedBox(width: 8),
                Expanded(child: _field(cTargetW, "Hedef kilo (kg)", number: true)),
              ]),
              const SizedBox(height: 4),
              _dropdown<String>(
                "Cinsiyet",
                pGender,
                ["Erkek", "Kadın"],
                (v) => setState(() => pGender = v!),
              ),
              _dropdown<int>(
                "Aktivite seviyen",
                pActivity,
                List.generate(kActivities.length, (i) => i),
                (v) => setState(() => pActivity = v!),
                labelOf: (i) => kActivities[i][0] as String,
              ),
              _dropdown<int>(
                "Kilo verme hızı",
                pRate,
                List.generate(kRates.length, (i) => i),
                (v) => setState(() => pRate = v!),
                labelOf: (i) => kRates[i][0] as String,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.calculate),
                  label: const Text("Kaydet ve Hesapla"),
                ),
              ),
            ]),
          ),
        ),
        if (t != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Builder(builder: (_) {
                final p = state["profile"];
                String eta = "";
                if (p["target_weight"] != null &&
                    (p["target_weight"] as num) < (p["weight"] as num)) {
                  final weeks = ((p["weight"] as num) - (p["target_weight"] as num)) /
                      (p["goal_rate"] as num);
                  final etaD = DateTime.now().add(Duration(days: (weeks * 7).round()));
                  eta = "\n\n🎯 Bu tempoyla hedefe ~${weeks.round()} haftada ulaşırsın "
                      "(~${etaD.day} ${kAylar[etaD.month]} ${etaD.year})";
                }
                return Text(
                  "📊 VKİ (vücut kitle indeksi): ${(t["bmi"] as double).toStringAsFixed(1)} — ${bmiText(t["bmi"])}\n\n"
                  "🔥 Bazal metabolizma (BMR): ${t["bmr"]} kk\n"
                  "   Hiç hareket etmesen günde yakacağın kalori\n\n"
                  "⚡ Günlük harcama (TDEE): ${t["tdee"]} kk\n"
                  "   Aktivitenle birlikte toplam yakacağın\n\n"
                  "🥗 KİLO VERME HEDEFİN: ${t["target"]} kk/gün\n"
                  "   (günde ~${t["deficit"]} kk açık = haftada ${(p["goal_rate"] as num)} kg)\n\n"
                  "🥩 Günlük öneri: ${t["protein"]} gr protein · ${t["carb"]} gr karbonhidrat · ${t["fat"]} gr yağ\n\n"
                  "💧 Su hedefi: ${t["water_ml"]} ml/gün$eta",
                  style: const TextStyle(fontSize: 14, height: 1.35),
                );
              }),
            ),
          ),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              "ℹ️ Hesaplamalar Mifflin-St Jeor formülüne göredir. Bu uygulama tıbbi tavsiye vermez; "
              "hastalığın varsa diyetisyenine danış.",
              style: TextStyle(color: kMuted, fontSize: 12, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dropdown<T>(String label, T value, List<T> items, void Function(T?) onChanged,
      {String Function(T)? labelOf}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          for (var it in items)
            DropdownMenuItem(
              value: it,
              child: Text(labelOf != null ? labelOf(it) : "$it",
                  style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
            )
        ],
        onChanged: onChanged,
      ),
    );
  }

  void _saveProfile() {
    final age = int.tryParse(cAge.text) ?? 0;
    final height = double.tryParse(cHeight.text.replaceAll(",", ".")) ?? 0;
    final weight = double.tryParse(cWeight.text.replaceAll(",", ".")) ?? 0;
    final tw = double.tryParse(cTargetW.text.replaceAll(",", "."));
    if (age < 5 || age > 110 || height < 100 || height > 250 || weight < 30 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Değerleri kontrol et (yaş 5-110, boy 100-250, kilo 30-300)")));
      return;
    }
    setState(() {
      state["profile"] = {
        "name": cName.text.trim(),
        "gender": pGender == "Erkek" ? "E" : "K",
        "age": age,
        "height": height,
        "weight": weight,
        "target_weight": tw,
        "activity": kActivities[pActivity][1],
        "goal_rate": kRates[pRate][1],
      };
      _save();
      tabIndex = 0;
    });
    final t = calcTargets()!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Hesaplandı ✔ Günlük hedefin: ${t["target"]} kk — şimdi yediklerini ekle!")));
  }
}

// ================= KİLO GRAFİĞİ =================
class WeightChartPainter extends CustomPainter {
  final List<double> values;
  final double? goal;
  WeightChartPainter(this.values, this.goal);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = kAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final paintDot = Paint()..color = kAccent;
    final paintGoal = Paint()
      ..color = kGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double lo = values.reduce((a, b) => a < b ? a : b);
    double hi = values.reduce((a, b) => a > b ? a : b);
    if (goal != null) {
      if (goal! < lo) lo = goal!;
      if (goal! > hi) hi = goal!;
    }
    final span0 = (hi - lo) == 0 ? 1.0 : (hi - lo);
    lo -= span0 * 0.15;
    hi += span0 * 0.15;
    final span = hi - lo;

    const ml = 8.0, mb = 20.0, mt = 14.0;
    double xFor(int i) => ml + i * (size.width - ml - 8) / (values.length - 1);
    double yFor(double v) => mt + (hi - v) / span * (size.height - mt - mb);

    // hedef çizgisi (kesikli)
    if (goal != null) {
      final yg = yFor(goal!);
      double x = ml;
      while (x < size.width - 8) {
        canvas.drawLine(Offset(x, yg), Offset(x + 6, yg), paintGoal);
        x += 12;
      }
      textPainter.text = TextSpan(
          text: "Hedef ${goal!.toStringAsFixed(0)} kg",
          style: const TextStyle(color: kGreen, fontSize: 10, fontWeight: FontWeight.bold));
      textPainter.layout();
      textPainter.paint(canvas, Offset(ml + 4, yg - 14));
    }

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = xFor(i), y = yFor(values[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paintLine);

    for (int i = 0; i < values.length; i++) {
      final x = xFor(i), y = yFor(values[i]);
      canvas.drawCircle(Offset(x, y), 4, paintDot);
      if (values.length <= 12 || i == 0 || i == values.length - 1) {
        textPainter.text = TextSpan(
            text: values[i].toStringAsFixed(1),
            style: const TextStyle(color: kInk, fontSize: 10, fontWeight: FontWeight.bold));
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 18));
      }
    }
  }

  @override
  bool shouldRepaint(covariant WeightChartPainter old) => true;
}
