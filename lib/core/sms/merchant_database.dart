/// Built-in merchant → category name database.
///
/// Keys are uppercase-normalised merchant names matching what
/// [TransactionParser.normalizeKey] produces.
///
/// Values are category NAMES that match the seeded [CategoryModel.name] values
/// so the engine can look up the correct category ID at runtime.
library;

const Map<String, String> kMerchantCategoryNames = {
  // ── Food & Dining ─────────────────────────────────────────────────────────
  'SWIGGY': 'Food & Dining',
  'ZOMATO': 'Food & Dining',
  'MCDONALDS': 'Food & Dining',
  'KFC': 'Food & Dining',
  'DOMINOS': 'Food & Dining',
  'PIZZA HUT': 'Food & Dining',
  'BURGER KING': 'Food & Dining',
  'SUBWAY': 'Food & Dining',
  'STARBUCKS': 'Food & Dining',
  'CAFE COFFEE DAY': 'Food & Dining',
  'HALDIRAMS': 'Food & Dining',
  'BOX8': 'Food & Dining',
  'FRESHMENU': 'Food & Dining',
  'EATSURE': 'Food & Dining',
  'DUNZO': 'Food & Dining',

  // ── Grocery ───────────────────────────────────────────────────────────────
  // (Grocery is "Shopping" in the default seed — use closest match)
  'BIGBASKET': 'Shopping',
  'BLINKIT': 'Shopping',
  'ZEPTO': 'Shopping',
  'DMART': 'Shopping',
  'RELIANCE FRESH': 'Shopping',
  'DELHIVERY': 'Shopping',
  'GROFERS': 'Shopping',
  'MILKBASKET': 'Shopping',
  'LICIOUS': 'Shopping',
  'FRESHTOHOME': 'Shopping',

  // ── Transport ─────────────────────────────────────────────────────────────
  'UBER': 'Transport',
  'OLA': 'Transport',
  'RAPIDO': 'Transport',
  'YULU': 'Transport',
  'BOUNCE': 'Transport',
  'VOGO': 'Transport',
  'FASTAG': 'Transport',
  'PETROL': 'Transport',
  'BPCL': 'Transport',
  'HPCL': 'Transport',
  'INDIAN OIL': 'Transport',
  'PARKING': 'Transport',
  'METRO': 'Transport',
  'BMTC': 'Transport',
  'BEST BUS': 'Transport',

  // ── Travel ────────────────────────────────────────────────────────────────
  'IRCTC': 'Travel',
  'MAKEMYTRIP': 'Travel',
  'GOIBIBO': 'Travel',
  'CLEARTRIP': 'Travel',
  'YATRA': 'Travel',
  'INDIGO': 'Travel',
  'AIR INDIA': 'Travel',
  'SPICEJET': 'Travel',
  'VISTARA': 'Travel',
  'AKASA': 'Travel',
  'OYO': 'Travel',
  'TREEBO': 'Travel',
  'FABHOTELS': 'Travel',

  // ── Shopping ─────────────────────────────────────────────────────────────
  'AMAZON': 'Shopping',
  'FLIPKART': 'Shopping',
  'MEESHO': 'Shopping',
  'SNAPDEAL': 'Shopping',
  'TATA CLIQ': 'Shopping',
  'AJIO': 'Clothing',
  'MYNTRA': 'Clothing',
  'NYKAA': 'Beauty & Care',
  'MAMAEARTH': 'Beauty & Care',
  'PURPLLE': 'Beauty & Care',
  'LAKME': 'Beauty & Care',

  // ── Health ────────────────────────────────────────────────────────────────
  'APOLLO': 'Health',
  'APOLLO PHARMACY': 'Health',
  'MEDPLUS': 'Health',
  'NETMEDS': 'Health',
  'PHARMEASY': 'Health',
  '1MG': 'Health',
  'PRACTO': 'Health',
  'HEALTHIANS': 'Health',
  'DR LAL': 'Health',
  'SRL DIAGNOSTICS': 'Health',
  'THYROCARE': 'Health',
  'MANIPAL': 'Health',
  'FORTIS': 'Health',
  'MAX HOSPITAL': 'Health',

  // ── Subscriptions ─────────────────────────────────────────────────────────
  'NETFLIX': 'Subscriptions',
  'HOTSTAR': 'Subscriptions',
  'DISNEY': 'Subscriptions',
  'SPOTIFY': 'Subscriptions',
  'APPLE MUSIC': 'Subscriptions',
  'YOUTUBE': 'Subscriptions',
  'AMAZON PRIME': 'Subscriptions',
  'PRIMEVIDEO': 'Subscriptions',
  'ZEE5': 'Subscriptions',
  'SONYLIV': 'Subscriptions',
  'VOOT': 'Subscriptions',
  'MXPLAYER': 'Subscriptions',
  'JIOCINEMA': 'Subscriptions',
  'LINKEDIN': 'Subscriptions',
  'HEADSPACE': 'Subscriptions',
  'DUOLINGO': 'Subscriptions',

  // ── Utilities ─────────────────────────────────────────────────────────────
  'AIRTEL': 'Utilities',
  'JIO': 'Utilities',
  'BSNL': 'Utilities',
  'VI': 'Utilities',
  'VODAFONE': 'Utilities',
  'IDEA': 'Utilities',
  'BESCOM': 'Utilities',
  'TATA POWER': 'Utilities',
  'ADANI ELECTRICITY': 'Utilities',
  'MAHADISCOM': 'Utilities',
  'IGL': 'Utilities',
  'MGL': 'Utilities',
  'BBMP': 'Utilities',

  // ── Education ─────────────────────────────────────────────────────────────
  'BYJUS': 'Education',
  'VEDANTU': 'Education',
  'UNACADEMY': 'Education',
  'COURSERA': 'Education',
  'UDEMY': 'Education',
  'WHITEHAT JR': 'Education',
  'SIMPLILEARN': 'Education',
  'UPGRAD': 'Education',

  // ── Entertainment ─────────────────────────────────────────────────────────
  'BOOKMYSHOW': 'Entertainment',
  'PAYTM MOVIES': 'Entertainment',
  'INOX': 'Entertainment',
  'PVR': 'Entertainment',
  'CARNIVAL': 'Entertainment',
  'STEAM': 'Entertainment',
  'PLAYSTATION': 'Entertainment',
  'XBOX': 'Entertainment',

  // ── Sports & Fitness ──────────────────────────────────────────────────────
  'CULT FIT': 'Sports & Fitness',
  'CULTFIT': 'Sports & Fitness',
  'GYM': 'Sports & Fitness',
  'CROSSFIT': 'Sports & Fitness',
  'DECATHLON': 'Sports & Fitness',

  // ── Gifts ─────────────────────────────────────────────────────────────────
  'ARCHIES': 'Gifts',
  'FERNS N PETALS': 'Gifts',
  'IGIFTFLOWER': 'Gifts',
};

/// Keyword → category name fallback (used when merchant is not in the DB).
/// Keys are lowercase substrings to match against the normalised merchant name.
const Map<String, String> kKeywordCategoryNames = {
  // Food
  'restaurant': 'Food & Dining',
  'cafe': 'Food & Dining',
  'kitchen': 'Food & Dining',
  'food': 'Food & Dining',
  'bakery': 'Food & Dining',
  'dhaba': 'Food & Dining',
  'biryani': 'Food & Dining',
  'pizz': 'Food & Dining',
  'burger': 'Food & Dining',
  'curry': 'Food & Dining',

  // Grocery
  'mart': 'Shopping',
  'superstore': 'Shopping',
  'grocery': 'Shopping',
  'vegetable': 'Shopping',

  // Transport
  'cab': 'Transport',
  'taxi': 'Transport',
  'petrol': 'Transport',
  'fuel': 'Transport',
  'parking': 'Transport',
  'toll': 'Transport',
  'bus': 'Transport',
  'auto': 'Transport',

  // Travel
  'hotel': 'Travel',
  'resort': 'Travel',
  'airline': 'Travel',
  'flight': 'Travel',
  'railway': 'Travel',

  // Health
  'hospital': 'Health',
  'clinic': 'Health',
  'pharmacy': 'Health',
  'medical': 'Health',
  'health': 'Health',
  'lab': 'Health',
  'diagnostic': 'Health',
  'doctor': 'Health',
  'dental': 'Health',

  // Utilities
  'electric': 'Utilities',
  'water bill': 'Utilities',
  'gas bill': 'Utilities',
  'broadband': 'Utilities',
  'recharge': 'Utilities',
  'mobile bill': 'Utilities',

  // Subscriptions
  'subscription': 'Subscriptions',
  'premium': 'Subscriptions',
  'membership': 'Subscriptions',
  'renewal': 'Subscriptions',

  // Education
  'school': 'Education',
  'college': 'Education',
  'university': 'Education',
  'tuition': 'Education',
  'coaching': 'Education',
  'course': 'Education',

  // Entertainment
  'cinema': 'Entertainment',
  'movie': 'Entertainment',
  'theatre': 'Entertainment',
  'game': 'Entertainment',

  // Shopping
  'store': 'Shopping',
  'shop': 'Shopping',
  'retail': 'Shopping',
  'mall': 'Shopping',
  'market': 'Shopping',
  'bazaar': 'Shopping',

  // Sports
  'gym': 'Sports & Fitness',
  'fitness': 'Sports & Fitness',
  'sport': 'Sports & Fitness',
};
