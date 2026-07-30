import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:android_intent_plus/android_intent.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  initNotifications();
  runApp(const DiyetApp());
}

// ================= BİLDİRİMLER =================
final FlutterLocalNotificationsPlugin notifPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  try {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    await notifPlugin.initialize(settings);
  } catch (_) {}
}

Future<int> scheduleReminders(bool enabled, {int waterMinutes = 180}) async {
  try {
    await notifPlugin.cancelAll();
    if (!enabled) return 0;
    final androidImpl = notifPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    try {
      await androidImpl?.requestExactAlarmsPermission();
    } catch (_) {}
    const details = NotificationDetails(
      android: AndroidNotificationDetails('hatirlatma', 'Hatırlatmalar',
          importance: Importance.high, priority: Priority.high),
    );
    Future<void> daily(int id, int h, int m, String title, String body) async {
      final now = tz.TZDateTime.now(tz.local);
      var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
      if (t.isBefore(now)) t = t.add(const Duration(days: 1));
      try {
        await notifPlugin.zonedSchedule(id, title, body, t, details,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            matchDateTimeComponents: DateTimeComponents.time);
      } catch (_) {
        // tam alarm izni yoksa yaklaşık moda geç (yine de bildirir)
        try {
          await notifPlugin.zonedSchedule(id, title, body, t, details,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.time);
        } catch (_) {}
      }
    }

    await daily(1, 8, 0, "🍳 Kahvaltı zamanı!",
        "Güne iyi başla — kahvaltını yaptıysan uygulamada işaretle ✓");
    await daily(2, 12, 30, "☀️ Öğle yemeği zamanı!",
        "Öğününü yediysen ✓ koy, kalorisini kaydetmeyi unutma");
    await daily(3, 19, 0, "🌙 Akşam yemeği zamanı!",
        "Hafif bir akşam yemeği hedefe hızlı götürür");
    await daily(7, 21, 0, "📝 Günü kapat",
        "Bugünkü öğünlerini ve kilonu kaydettin mi?");
    // su hatırlatmaları: 08:00 - 22:00 arası, kullanıcının seçtiği aralıkla
    if (waterMinutes > 0) {
      int id = 100;
      int t = 8 * 60;
      while (t <= 22 * 60 && id < 125) {
        await daily(id, t ~/ 60, t % 60, "💧 Su zamanı!",
            "Bir bardak su iç — hedefe birlikte ulaşalım");
        id++;
        t += waterMinutes;
      }
    }
    // kaç bildirim kuruldu? (teşhis için)
    final pending = await notifPlugin.pendingNotificationRequests();
    return pending.length;
  } catch (_) {
    return -1;
  }
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
  ["Tereyağı", "1 tatlı kaşığı (10 gr)", 75],
  ["Bal", "1 tatlı kaşığı (10 gr)", 30],
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
  ["Haşlanmış patates", "1 orta boy (150 gr)", 130],
  ["Patates kızartması", "1 porsiyon", 400],
  ["Mevsim salata (yağsız)", "1 kase", 40],
  ["Çoban salata", "1 kase", 60],
  ["Yoğurt", "1 kase", 100],
  ["Cacık", "1 kase", 80],
  ["Ayran", "1 bardak (200 ml)", 60],
  ["Humus", "2 kaşık", 120],
  ["Lahmacun", "1 adet", 280],
  ["Kıymalı pide", "1 dilim (80 gr)", 200],
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
  ["Kuru kayısı", "3 adet (~25 gr)", 55],
  ["Badem", "10 adet", 70],
  ["Ceviz", "3 tam adet (~25 gr iç)", 160],
  ["Fındık", "1 avuç", 180],
  ["Antep fıstığı", "1 avuç", 160],
  ["Leblebi", "1 avuç (30 gr)", 110],
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
  ["Baklava", "1 dilim (60 gr)", 270],
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

const kQuotes = [
  "Küçük adımlar, büyük değişimler yaratır 🌱",
  "Bugün verdiğin karar, yarının aynası 💪",
  "Hedefine her gün bir lokma daha yakınsın 🎯",
  "Su iç, hareket et, kendine iyi bak 💧",
  "Mükemmel olmana gerek yok, devam etmen yeter 🚀",
  "Sağlıklı tabak = sağlıklı sen 🥗",
  "Vazgeçmek yok, sadece yavaşlamak var 🐢",
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
  Map<String, dynamic> state = {"profile": null, "days": <String, dynamic>{}, "recent": []};
  bool onboardSeen = true;
  bool notifOn = false;
  int tabIndex = 0;
  DateTime currentDay = DateTime.now();
  bool loaded = false;
  List<Map<String, List<String>>> currentPlans = [];
  int planDays = 1;

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
  final cWaterGap = TextEditingController(text: "3");
  String waterGapUnit = "saat";

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
    cWaterGap.dispose();
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
          state.putIfAbsent("days", () => <String, dynamic>{});
          state.putIfAbsent("recent", () => []);
        }
      } catch (_) {}
    }
    onboardSeen = prefs.getBool('onboard_seen') ?? false;
    notifOn = state["notif"] == true;
    // eski saat ayarını dakikaya çevir
    if (state["water_notif_min"] == null) {
      state["water_notif_min"] =
          ((state["water_notif_h"] as num? ?? 3).toInt()) * 60;
    }
    final wm = (state["water_notif_min"] as num? ?? 180).toInt();
    if (wm > 0 && wm % 60 == 0) {
      waterGapUnit = "saat";
      cWaterGap.text = "${wm ~/ 60}";
    } else if (wm > 0) {
      waterGapUnit = "dk";
      cWaterGap.text = "$wm";
    }
    // Hatirlatmalar tamamen kaldirildi (OPPO vb. telefonlarda alarm engeli)
    notifOn = false;
    state["notif"] = false;
    try {
      notifPlugin.cancelAll();
    } catch (_) {}
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
    final days = Map<String, dynamic>.from(state["days"] as Map);
    state["days"] = days;
    if (!days.containsKey(k)) {
      days[k] = {
        "meals": {for (var m in kMeals) m: []},
        "water": 0,
        "weight": null,
      };
    }
    final dd = Map<String, dynamic>.from(days[k] as Map);
    days[k] = dd;
    dd.putIfAbsent("water", () => 0);
    // eski bardak verisini ml'ye çevir
    dd.putIfAbsent(
        "water_ml", () => ((dd["water"] ?? 0) as num).toInt() * 200);
    // su kayıt listesi (tek tek silinebilir)
    if (dd["water_log"] == null) {
      final ml = (dd["water_ml"] as num? ?? 0).toInt();
      dd["water_log"] = ml > 0
          ? [
              {"ml": ml, "t": "--:--"}
            ]
          : <Map<String, dynamic>>[];
    }
    dd.putIfAbsent("done", () => <String, bool>{});
    dd["meals"] ??= {for (var m in kMeals) m: []};
    for (var m in kMeals) {
      (dd["meals"] as Map).putIfAbsent(m, () => []);
    }
    return dd;
  }

  // ---- yiyecek ekleme (hata olursa kullanıcıya göster) ----
  void addFood(String meal, String ad, double por) {
    try {
      final kcal = (foodKcal(ad) * por).round();
      final meals = dayData(currentDay)["meals"] as Map;
      (meals[meal] as List).add({"food": ad, "por": por, "kcal": kcal});
      _pushRecent(ad);
      _save();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          content: Text("✔ $ad eklendi ($kcal kk)")));
      _maybeShowInterstitial();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Eklenemedi: $e")));
    }
  }

  // ---- son eklenen yiyecekler ----
  List<String> get recentFoods =>
      List<String>.from(state["recent"] as List? ?? []);

  void _pushRecent(String ad) {
    final r = recentFoods..remove(ad);
    r.insert(0, ad);
    state["recent"] = r.take(8).toList();
  }

  // ---- günlük seri (streak) ----
  int calcStreak() {
    bool hasFood(DateTime day) {
      final dd = (state["days"] as Map)[_key(day)];
      if (dd == null) return false;
      final meals = dd["meals"] as Map?;
      if (meals == null) return false;
      for (var m in kMeals) {
        if ((meals[m] as List? ?? []).isNotEmpty) return true;
      }
      return false;
    }

    int s = 0;
    var d = DateTime.now();
    if (!hasFood(d)) d = d.subtract(const Duration(days: 1));
    while (hasFood(d)) {
      s++;
      d = d.subtract(const Duration(days: 1));
    }
    return s;
  }

  // ---- son 7 günün kalori toplamları ----
  List<int> weekTotals() {
    final out = <int>[];
    for (int i = 6; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final dd = (state["days"] as Map)[_key(d)];
      int sum = 0;
      if (dd != null) {
        final meals = dd["meals"] as Map? ?? {};
        for (var m in kMeals) {
          for (var it in (meals[m] as List? ?? [])) {
            sum += (it["kcal"] as num).toInt();
          }
        }
      }
      out.add(sum);
    }
    return out;
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
    if (!onboardSeen) return _buildOnboard();
    final streak = calcStreak();
    return Scaffold(
      appBar: AppBar(
        title: const Text("🥗 Diyet Takip"),
        actions: [
          if (streak > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F0E6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text("🔥 $streak gün",
                  style: const TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
            ),
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

  // ================= KARŞILAMA (İLK AÇILIŞ) =================
  Widget _buildOnboard() {
    final pages = [
      ["🥗", "Hoş Geldin!", "Diyet Takip ile yediklerini kaydet,\nkalori hedefini bilimsel formülle öğren,\nsağlıklı kiloya ulaş."],
      ["📊", "Her Şey Otomatik", "121 Türk yemeği kalorisiyle hazır.\nSu takibi, kilo grafiği, haftalık özet\nhepsi cebinde."],
      ["📋", "Sana Özel Diyet Listesi", "Hedef kalorine göre günlük menü\notomatik oluşturulur. Tek tıkla güne uygula!"],
    ];
    int page = 0;
    final controller = PageController();
    return StatefulBuilder(builder: (ctx, setSB) {
      return Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: (i) => setSB(() => page = i),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(pages[i][0], style: const TextStyle(fontSize: 90)),
                      const SizedBox(height: 24),
                      Text(pages[i][1],
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: kInk)),
                      const SizedBox(height: 14),
                      Text(pages[i][2],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: kMuted, height: 1.5)),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < pages.length; i++)
                  Container(
                    margin: const EdgeInsets.all(4),
                    width: page == i ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: page == i ? kAccent : const Color(0xFFD8D0BF),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (page < pages.length - 1) {
                      controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    } else {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('onboard_seen', true);
                      setState(() {
                        onboardSeen = true;
                        tabIndex = 3;
                      });
                    }
                  },
                  child: Text(
                    page < pages.length - 1 ? "İleri" : "Başlayalım 🚀",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  // ================= AYLIK TAKVİM SEÇİCİ =================
  void _showMonthPicker() {
    int viewY = currentDay.year;
    int viewM = currentDay.month;
    bool dayHasData(DateTime d) {
      final dd = (state["days"] as Map)[_key(d)];
      if (dd == null) return false;
      final meals = dd["meals"] as Map? ?? {};
      for (var m in kMeals) {
        if ((meals[m] as List? ?? []).isNotEmpty) return true;
      }
      return dd["weight"] != null;
    }

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(builder: (ctx, setDlg) {
        final first = DateTime(viewY, viewM, 1);
        final daysInMonth = DateTime(viewY, viewM + 1, 0).day;
        final startOffset = first.weekday - 1; // Pzt=0
        final today = DateTime.now();
        return AlertDialog(
          backgroundColor: kCard,
          contentPadding: const EdgeInsets.all(12),
          title: Row(children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setDlg(() {
                viewM--;
                if (viewM < 1) {
                  viewM = 12;
                  viewY--;
                }
              }),
            ),
            Expanded(
              child: Text("${kAylar[viewM]} $viewY",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setDlg(() {
                viewM++;
                if (viewM > 12) {
                  viewM = 1;
                  viewY++;
                }
              }),
            ),
          ]),
          content: SizedBox(
            width: 300,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                for (var g in kGunler)
                  Expanded(
                    child: Text(g,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11,
                            color: kMuted,
                            fontWeight: FontWeight.bold)),
                  ),
              ]),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 0; i < startOffset; i++) const SizedBox(),
                  for (int d = 1; d <= daysInMonth; d++)
                    Builder(builder: (_) {
                      final date = DateTime(viewY, viewM, d);
                      final isSel = _key(date) == _key(currentDay);
                      final isToday = _key(date) == _key(today);
                      final has = dayHasData(date);
                      return InkWell(
                        onTap: () {
                          setState(() => currentDay = date);
                          Navigator.pop(dlgCtx);
                        },
                        borderRadius: BorderRadius.circular(99),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSel
                                ? kAccent
                                : (isToday
                                    ? const Color(0xFFF7E8DD)
                                    : Colors.transparent),
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("$d",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSel || isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSel ? Colors.white : kInk)),
                              if (has)
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isSel ? Colors.white : kGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => currentDay = DateTime.now());
                Navigator.pop(dlgCtx);
              },
              child: const Text("Bugüne dön"),
            ),
          ],
        );
      }),
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
                  child: InkWell(
                    onTap: _showMonthPicker,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.calendar_month,
                              size: 16, color: kAccent),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(fmtDate(currentDay),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ]),
                        Text(
                            isToday
                                ? "Bugün · takvim için dokun"
                                : "Takvim için dokun",
                            style: const TextStyle(color: kMuted, fontSize: 11)),
                      ]),
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () =>
                        setState(() => currentDay = currentDay.add(const Duration(days: 1)))),
              ],
            ),
          ),
        ),

        // motivasyon sözü
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              kQuotes[DateTime.now().day % kQuotes.length],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontStyle: FontStyle.italic, color: Color(0xFF5A5347), fontSize: 13),
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
                  final pct = (total / target).clamp(0.0, 1.0);
                  return Row(children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: CircularProgressIndicator(
                              value: pct,
                              strokeWidth: 11,
                              backgroundColor: const Color(0xFFEEE7D9),
                              color: ok ? kAccent : kRed,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("$total",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 21,
                                      color: kInk)),
                              const Text("kalori",
                                  style:
                                      TextStyle(color: kMuted, fontSize: 11)),
                              Text("%${(pct * 100).round()}",
                                  style: TextStyle(
                                      color: ok ? kAccent : kRed,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hedef: $target kk",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              ok
                                  ? "✅ $left kk hakkın kaldı"
                                  : "⚠ Hedefi ${-left} kk aştın!",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: total == 0
                                      ? kMuted
                                      : (ok ? kGreen : kRed)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "🥩 ${t["protein"]}g protein\n🍞 ${t["carb"]}g karbonhidrat\n🥑 ${t["fat"]}g yağ",
                              style: const TextStyle(
                                  color: kMuted, fontSize: 12, height: 1.5),
                            ),
                          ]),
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

        // haftalık kalori grafiği
        if (t != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("📊 Son 7 Gün",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: CalorieWeekPainter(weekTotals(), t["target"] as int),
                  ),
                ),
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
                final ml = (dd["water_ml"] as num? ?? 0).toInt();
                final goal = t != null ? t["water_ml"] as int : 2000;
                final log = dd["water_log"] as List? ?? [];
                void addWater(int amt) {
                  final now = TimeOfDay.now();
                  setState(() {
                    dd["water_ml"] = ml + amt;
                    log.add({
                      "ml": amt,
                      "t":
                          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}"
                    });
                    _save();
                  });
                }

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        for (var amt in [100, 200, 330, 500])
                          ElevatedButton(
                            onPressed: () => addWater(amt),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kWater,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8)),
                            child: Text("+$amt",
                                style: const TextStyle(fontSize: 13)),
                          ),
                      ]),
                      const SizedBox(height: 4),
                      const Text("☝ bardak ≈ 200 ml · küçük şişe = 330 ml · büyük şişe = 500 ml",
                          style: TextStyle(color: kMuted, fontSize: 10.5)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (ml / goal).clamp(0.0, 1.0),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(99),
                            backgroundColor: const Color(0xFFEEE7D9),
                            color: kWater,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text("$ml / $goal ml",
                            style: const TextStyle(
                                color: kWater,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        ml >= goal
                            ? "✅ Günlük su hedefin tamam, harikasın!"
                            : "≈ ${(ml / 250).toStringAsFixed(1)} bardak içtin — ${goal - ml} ml kaldı",
                        style: TextStyle(
                            color: ml >= goal ? kGreen : kMuted,
                            fontWeight:
                                ml >= goal ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12.5),
                      ),
                      if (log.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text("Bugünkü kayıtlar (silmek için ✕):",
                            style: TextStyle(
                                color: kMuted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          for (int i = 0; i < log.length; i++)
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 2, top: 2, bottom: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F0F6),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text("💧 ${log[i]["ml"]} ml ${log[i]["t"]}",
                                    style: const TextStyle(
                                        fontSize: 11.5, color: kWater)),
                                InkWell(
                                  onTap: () => setState(() {
                                    dd["water_ml"] = (ml -
                                            (log[i]["ml"] as num).toInt())
                                        .clamp(0, 100000);
                                    log.removeAt(i);
                                    _save();
                                  }),
                                  borderRadius: BorderRadius.circular(99),
                                  child: const Padding(
                                    padding: EdgeInsets.all(3),
                                    child: Icon(Icons.close,
                                        size: 14, color: kMuted),
                                  ),
                                ),
                              ]),
                            ),
                        ]),
                      ],
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
    final doneMap = dd["done"] as Map? ?? {};
    final isEaten = doneMap[meal] == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text("${kMealIcons[meal]} $meal",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => setState(() {
                (dd["done"] as Map)[meal] = !isEaten;
                _save();
              }),
              borderRadius: BorderRadius.circular(99),
              child: Icon(
                isEaten ? Icons.check_circle : Icons.circle_outlined,
                color: isEaten ? kGreen : kMuted,
                size: 22,
              ),
            ),
            const Spacer(),
            Text("$sub kk", style: const TextStyle(color: kAccent, fontWeight: FontWeight.bold)),
          ]),
          if (isEaten)
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text("✔ Yedim",
                  style: TextStyle(color: kGreen, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
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
      builder: (sheetCtx) => FoodPickerSheet(
        meal: meal,
        recent: recentFoods,
        onAdd: (ad, por) {
          Navigator.pop(sheetCtx);
          addFood(meal, ad, por);
        },
      ),
    );
  }

  // ================= KİLO =================
  List<MapEntry<String, double>> _weightEntries() {
    final out = <MapEntry<String, double>>[];
    Map<String, dynamic>.from(state["days"] as Map).forEach((k, v) {
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
              const Text("📋 Akıllı Diyet Listesi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                t != null
                    ? "Hedefin: ${t["target"]} kk/gün · Dağılım: Sabah %25, Öğle %35, Akşam %30, Ara %10\n"
                        "🧠 Planlayıcı önceki listeleri hatırlar — aynı yemekleri üst üste tekrar etmez."
                    : "Liste için önce Profil sekmesinden bilgilerini gir.",
                style: const TextStyle(color: kMuted, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(children: [
                ChoiceChip(
                  label: const Text("1 Günlük"),
                  selected: planDays == 1,
                  selectedColor: const Color(0xFFF7E8DD),
                  onSelected: (_) => setState(() => planDays = 1),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("7 Günlük (Haftalık)"),
                  selected: planDays == 7,
                  selectedColor: const Color(0xFFF7E8DD),
                  onSelected: (_) => setState(() => planDays = 7),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                ElevatedButton.icon(
                  onPressed: t == null ? null : _makePlans,
                  icon: const Text("🔀"),
                  label: const Text("Liste Oluştur"),
                ),
                const SizedBox(width: 8),
                if (currentPlans.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: _applyPlans,
                    icon: const Text("✔"),
                    label: Text(planDays == 1 ? "Bugüne Uygula" : "7 Güne Uygula"),
                  ),
              ]),
            ]),
          ),
        ),
        for (int di = 0; di < currentPlans.length; di++)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  "🗓 ${fmtDate(currentDay.add(Duration(days: di)))}${di == 0 ? '  (Bugün)' : ''}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                const SizedBox(height: 8),
                for (var m in kMeals) ...[
                  Text("${kMealIcons[m]} $m",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14, color: kAccent)),
                  const SizedBox(height: 4),
                  for (var ad in currentPlans[di][m]!)
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 2),
                      child: Text("• $ad — ${foodPorsiyon(ad)} (${foodKcal(ad)} kk)",
                          style: const TextStyle(fontSize: 13.5)),
                    ),
                  const SizedBox(height: 8),
                ],
                Builder(builder: (_) {
                  int tot = 0;
                  currentPlans[di].forEach((_, items) {
                    for (var ad in items) {
                      tot += foodKcal(ad);
                    }
                  });
                  return Text("Gün toplamı: ~$tot kk / Hedef: ${t?["target"] ?? '-'} kk",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5));
                }),
              ]),
            ),
          ),
        if (currentPlans.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "💧 Her gün ${t?["water_ml"] ?? 2000} ml su içmeyi unutma!\n"
                "✔ 'Uygula' dersen liste${planDays == 7 ? 'ler bugünden itibaren 7 güne' : ' bugüne'} işlenir, sen sadece yedikçe işaretlersin.",
                style: const TextStyle(color: kMuted, fontSize: 12.5, height: 1.4),
              ),
            ),
          ),
      ],
    );
  }

  void _makePlans() {
    final t = calcTargets()!;
    final target = t["target"] as int;
    final history = List<String>.from(state["plan_history"] as List? ?? []);
    final used = <String>{};
    final plans = <Map<String, List<String>>>[];

    List<String> pickMeal(String meal, double budget) {
      final base = List<String>.from(kPlanPools[meal]!)..shuffle();
      // öncelik: bu listede ve geçmiş listelerde kullanılmamış olanlar
      final fresh =
          base.where((a) => !used.contains(a) && !history.contains(a)).toList();
      final notUsed = base.where((a) => !used.contains(a)).toList();
      final pool = fresh.length >= 3
          ? fresh
          : (notUsed.length >= 3 ? notUsed : base);
      final items = <String>[];
      int total = 0;
      for (var ad in pool) {
        final kcal = foodKcal(ad);
        if (total + kcal <= budget * 1.05) {
          items.add(ad);
          total += kcal;
          used.add(ad);
        }
        if (total >= budget * 0.85) break;
      }
      return items;
    }

    for (int day = 0; day < planDays; day++) {
      final plan = <String, List<String>>{};
      for (var meal in kMeals) {
        plan[meal] = pickMeal(meal, target * kMealFrac[meal]!);
      }
      plans.add(plan);
    }
    setState(() => currentPlans = plans);
  }

  void _applyPlans() {
    if (currentPlans.isEmpty) return;
    int existing = 0;
    for (int i = 0; i < currentPlans.length; i++) {
      final dd = dayData(currentDay.add(Duration(days: i)));
      for (var m in kMeals) {
        existing += (dd["meals"][m] as List).length;
      }
    }
    void doApply() {
      setState(() {
        final usedFoods = <String>[];
        for (int i = 0; i < currentPlans.length; i++) {
          final dd = dayData(currentDay.add(Duration(days: i)));
          for (var m in kMeals) {
            dd["meals"][m] = [
              for (var ad in currentPlans[i][m]!)
                {"food": ad, "por": 1, "kcal": foodKcal(ad)}
            ];
            usedFoods.addAll(currentPlans[i][m]!);
          }
        }
        // hafıza: kullanılan yemekleri kaydet (son 40)
        final history = List<String>.from(state["plan_history"] as List? ?? []);
        for (var f in usedFoods) {
          history.remove(f);
          history.add(f);
        }
        state["plan_history"] =
            history.length > 40 ? history.sublist(history.length - 40) : history;
        state["plans_applied"] =
            (state["plans_applied"] as num? ?? 0).toInt() + currentPlans.length;
        _save();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(planDays == 1
              ? "Diyet listesi bugüne uygulandı ✔"
              : "7 günlük liste uygulandı ✔")));
      _maybeShowInterstitial();
    }

    if (existing > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: kCard,
          title: const Text("Emin misin?"),
          content: Text(
              "Bu günlerde toplam $existing kayıt var. Liste üzerine yazılsın mı?"),
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
              const SizedBox(height: 8),
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
        _buildBadges(),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              "ℹ️ Kalori hedefi Mifflin-St Jeor formülüne, yiyecek kalorileri Türkomp/USDA besin veritabanlarının "
              "ortalama değerlerine göredir; marka ve pişirme şekline göre ±%10 değişebilir. "
              "Bu uygulama tıbbi tavsiye vermez; hastalığın varsa diyetisyenine danış.",
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

  // ================= ROZETLER =================
  Widget _buildBadges() {
    final daysMap = state["days"] as Map;
    bool anyFood = false;
    int totalWaterMl = 0;
    int waterGoalDays = 0;
    final t = calcTargets();
    final waterGoal = t != null ? t["water_ml"] as int : 2000;
    daysMap.forEach((_, dd) {
      final ml = ((dd["water_ml"] ?? ((dd["water"] ?? 0) as num).toInt() * 200) as num)
          .toInt();
      totalWaterMl += ml;
      if (ml >= waterGoal) waterGoalDays++;
      final meals = dd["meals"] as Map? ?? {};
      for (var m in kMeals) {
        if ((meals[m] as List? ?? []).isNotEmpty) anyFood = true;
      }
    });
    final streak = calcStreak();
    final entries = _weightEntries();
    double lost = 0;
    if (entries.length >= 2) {
      lost = entries.first.value - entries.last.value;
    }
    final plansApplied = (state["plans_applied"] as num? ?? 0).toInt();
    bool goalReached = false;
    final prof = state["profile"];
    if (prof != null && prof["target_weight"] != null && entries.isNotEmpty) {
      goalReached =
          entries.last.value <= (prof["target_weight"] as num).toDouble();
    }

    final badges = <List<Object>>[
      ["🍽", "İlk Adım", "İlk yiyecek kaydı", anyFood],
      ["🔥", "3 Günlük Seri", "3 gün üst üste kayıt", streak >= 3],
      ["⚡", "Haftalık Seri", "7 gün üst üste kayıt", streak >= 7],
      ["💧", "Su Dostu", "Toplam 10 litre su", totalWaterMl >= 10000],
      ["💦", "Su Şampiyonu", "3 gün su hedefi tamam", waterGoalDays >= 3],
      ["⚖", "Tartının Hakimi", "İlk kilo kaydı", entries.isNotEmpty],
      ["📋", "Liste Ustası", "İlk diyet listesi", plansApplied >= 1],
      ["🗓", "Planlı Yaşam", "7 günlük plan uygula", plansApplied >= 7],
      ["🏆", "5 Kilo Gitti!", "5 kg verdin", lost >= 5],
      ["🎯", "Hedef Tamam!", "Hedef kiloya ulaştın", goalReached],
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("🏅 Rozetlerin",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var b in badges)
                Opacity(
                  opacity: b[3] as bool ? 1 : 0.35,
                  child: Container(
                    width: 105,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (b[3] as bool)
                          ? const Color(0xFFF7E8DD)
                          : const Color(0xFFF2EFE8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kLine),
                    ),
                    child: Column(children: [
                      Text(b[0] as String, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 4),
                      Text(b[1] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11.5)),
                      Text(b[2] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: kMuted, fontSize: 9.5)),
                    ]),
                  ),
                ),
            ],
          ),
        ]),
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

// ================= HAFTALIK KALORİ GRAFİĞİ =================
class CalorieWeekPainter extends CustomPainter {
  final List<int> values;
  final int target;
  CalorieWeekPainter(this.values, this.target);

  @override
  void paint(Canvas canvas, Size size) {
    double maxV = target.toDouble() * 1.25;
    for (var v in values) {
      if (v > maxV) maxV = v.toDouble();
    }
    if (maxV <= 0) maxV = 1;

    const mb = 18.0, mt = 8.0;
    final barW = (size.width - 20) / 7 * 0.55;
    final goalPaint = Paint()
      ..color = kGreen
      ..strokeWidth = 1.5;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // hedef çizgisi
    final yg = mt + (1 - target / maxV) * (size.height - mt - mb);
    double dx = 0;
    while (dx < size.width) {
      canvas.drawLine(Offset(dx, yg), Offset(dx + 5, yg), goalPaint);
      dx += 10;
    }

    for (int i = 0; i < 7; i++) {
      final v = values[i];
      final x = 10 + i * (size.width - 20) / 7 + ((size.width - 20) / 7 - barW) / 2;
      final h = v / maxV * (size.height - mt - mb);
      final over = v > target;
      final paint = Paint()
        ..color = v == 0
            ? const Color(0xFFEEE7D9)
            : (over ? kRed : (v >= target * 0.8 ? kGreen : kAccent));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - mb - h, barW, h),
            const Radius.circular(4)),
        paint,
      );
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      textPainter.text = TextSpan(
          text: kGunler[day.weekday - 1],
          style: const TextStyle(color: kMuted, fontSize: 9));
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x + barW / 2 - textPainter.width / 2, size.height - mb + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CalorieWeekPainter old) => true;
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

// ================= TÜRKÇE UYUMLU ARAMA =================
String trLower(String s) =>
    s.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

// ================= YİYECEK SEÇME PENCERESİ (KALICI) =================
class FoodPickerSheet extends StatefulWidget {
  final String meal;
  final List<String> recent;
  final void Function(String ad, double por) onAdd;
  const FoodPickerSheet(
      {super.key,
      required this.meal,
      required this.recent,
      required this.onAdd});

  @override
  State<FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends State<FoodPickerSheet> {
  String query = "";
  List? picked; // seçilen yiyecek [ad, porsiyon, kcal]
  final cPortion = TextEditingController(text: "1");

  @override
  void dispose() {
    cPortion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: picked == null ? _buildList() : _buildPortion(),
      ),
    );
  }

  Widget _buildList() {
    final results = kFoods
        .where((f) => trLower(f[0] as String).contains(trLower(query)))
        .toList();
    return Column(children: [
      Text("${kMealIcons[widget.meal]} ${widget.meal} — Yiyecek Seç",
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
        onChanged: (v) => setState(() => query = v),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: ListView(children: [
          if (query.isEmpty && widget.recent.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text("⭐ Son eklediklerin",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: kMuted)),
            ),
            for (var ad in widget.recent)
              ListTile(
                dense: true,
                leading: const Text("🕘", style: TextStyle(fontSize: 16)),
                title: Text(ad, style: const TextStyle(fontSize: 14)),
                trailing: Text("${foodKcal(ad)} kk",
                    style: const TextStyle(
                        color: kAccent, fontWeight: FontWeight.bold)),
                onTap: () => setState(
                    () => picked = kFoods.firstWhere((f) => f[0] == ad)),
              ),
            const Divider(),
          ],
          if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text("Sonuç bulunamadı 🔍",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kMuted)),
            ),
          for (var f in results)
            ListTile(
              dense: true,
              title: Text(f[0] as String,
                  style: const TextStyle(fontSize: 14)),
              subtitle: Text(f[1] as String,
                  style: const TextStyle(fontSize: 12, color: kMuted)),
              trailing: Text("${f[2]} kk",
                  style: const TextStyle(
                      color: kAccent, fontWeight: FontWeight.bold)),
              onTap: () => setState(() => picked = f),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
                "Kalori değerleri Türkomp ve USDA besin veritabanlarının ortalamalarına göre yaklaşıktır",
                textAlign: TextAlign.center,
                style: TextStyle(color: kMuted, fontSize: 10)),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildPortion() {
    final p = picked!;
    final por = double.tryParse(cPortion.text.replaceAll(",", ".")) ?? 0;
    final kk = ((p[2] as int) * por).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => picked = null),
          ),
          Expanded(
            child: Text(p[0] as String,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
        const SizedBox(height: 6),
        Text("1 porsiyon = ${p[1]} · ${p[2]} kk",
            style: const TextStyle(color: kMuted, fontSize: 13)),
        const SizedBox(height: 16),
        const Text("Kaç porsiyon yedin?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (var ps in ["0.5", "1", "1.5", "2", "3"])
            ChoiceChip(
              label: Text(ps),
              selected: cPortion.text == ps,
              selectedColor: const Color(0xFFF7E8DD),
              onSelected: (_) => setState(() => cPortion.text = ps),
            ),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: cPortion,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: "veya elle yaz (${p[1]})",
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Text("Toplam: $kk kalori",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: kAccent)),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Ekle",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (por <= 0) return;
              widget.onAdd(p[0] as String, por);
            },
          ),
        ),
      ],
    );
  }
}
