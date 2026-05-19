import 'package:flutter/material.dart';

/// Resolves persisted Material icon code points to const [IconData] values.
abstract final class MaterialIconResolver {
  static const IconData fallback = Icons.category_rounded;

  static final Map<int, IconData> _iconsByCodePoint = {
    // Goals
    Icons.savings_rounded.codePoint: Icons.savings_rounded,
    Icons.home_rounded.codePoint: Icons.home_rounded,
    Icons.directions_car_rounded.codePoint: Icons.directions_car_rounded,
    Icons.flight_rounded.codePoint: Icons.flight_rounded,
    Icons.school_rounded.codePoint: Icons.school_rounded,
    Icons.phone_iphone_rounded.codePoint: Icons.phone_iphone_rounded,
    Icons.laptop_mac_rounded.codePoint: Icons.laptop_mac_rounded,
    Icons.health_and_safety_rounded.codePoint: Icons.health_and_safety_rounded,
    Icons.diamond_rounded.codePoint: Icons.diamond_rounded,
    Icons.celebration_rounded.codePoint: Icons.celebration_rounded,
    Icons.shopping_bag_rounded.codePoint: Icons.shopping_bag_rounded,
    Icons.sports_esports_rounded.codePoint: Icons.sports_esports_rounded,

    // Accounts
    Icons.payments_rounded.codePoint: Icons.payments_rounded,
    Icons.account_balance_rounded.codePoint: Icons.account_balance_rounded,
    Icons.credit_card_rounded.codePoint: Icons.credit_card_rounded,
    Icons.account_balance_wallet_rounded.codePoint:
        Icons.account_balance_wallet_rounded,
    Icons.currency_rupee_rounded.codePoint: Icons.currency_rupee_rounded,
    Icons.attach_money_rounded.codePoint: Icons.attach_money_rounded,
    Icons.euro_rounded.codePoint: Icons.euro_rounded,
    Icons.monetization_on_rounded.codePoint: Icons.monetization_on_rounded,
    Icons.wallet_rounded.codePoint: Icons.wallet_rounded,
    Icons.contactless_rounded.codePoint: Icons.contactless_rounded,
    Icons.qr_code_rounded.codePoint: Icons.qr_code_rounded,
    Icons.phone_android_rounded.codePoint: Icons.phone_android_rounded,
    Icons.business_rounded.codePoint: Icons.business_rounded,
    Icons.work_rounded.codePoint: Icons.work_rounded,
    Icons.trending_up_rounded.codePoint: Icons.trending_up_rounded,
    Icons.local_atm_rounded.codePoint: Icons.local_atm_rounded,

    // Categories
    Icons.restaurant_rounded.codePoint: Icons.restaurant_rounded,
    Icons.fastfood_rounded.codePoint: Icons.fastfood_rounded,
    Icons.local_cafe_rounded.codePoint: Icons.local_cafe_rounded,
    Icons.lunch_dining_rounded.codePoint: Icons.lunch_dining_rounded,
    Icons.shopping_cart_rounded.codePoint: Icons.shopping_cart_rounded,
    Icons.local_mall_rounded.codePoint: Icons.local_mall_rounded,
    Icons.checkroom_rounded.codePoint: Icons.checkroom_rounded,
    Icons.train_rounded.codePoint: Icons.train_rounded,
    Icons.pedal_bike_rounded.codePoint: Icons.pedal_bike_rounded,
    Icons.movie_rounded.codePoint: Icons.movie_rounded,
    Icons.music_note_rounded.codePoint: Icons.music_note_rounded,
    Icons.sports_basketball_rounded.codePoint: Icons.sports_basketball_rounded,
    Icons.local_hospital_rounded.codePoint: Icons.local_hospital_rounded,
    Icons.fitness_center_rounded.codePoint: Icons.fitness_center_rounded,
    Icons.spa_rounded.codePoint: Icons.spa_rounded,
    Icons.medication_rounded.codePoint: Icons.medication_rounded,
    Icons.auto_stories_rounded.codePoint: Icons.auto_stories_rounded,
    Icons.science_rounded.codePoint: Icons.science_rounded,
    Icons.home_work_rounded.codePoint: Icons.home_work_rounded,
    Icons.bolt_rounded.codePoint: Icons.bolt_rounded,
    Icons.water_drop_rounded.codePoint: Icons.water_drop_rounded,
    Icons.phone_rounded.codePoint: Icons.phone_rounded,
    Icons.wifi_rounded.codePoint: Icons.wifi_rounded,
    Icons.laptop_rounded.codePoint: Icons.laptop_rounded,
    Icons.business_center_rounded.codePoint: Icons.business_center_rounded,
    Icons.card_giftcard_rounded.codePoint: Icons.card_giftcard_rounded,
    Icons.pets_rounded.codePoint: Icons.pets_rounded,
    Icons.subscriptions_rounded.codePoint: Icons.subscriptions_rounded,
    Icons.face_retouching_natural_rounded.codePoint:
        Icons.face_retouching_natural_rounded,
    Icons.real_estate_agent_rounded.codePoint: Icons.real_estate_agent_rounded,
    Icons.category_rounded.codePoint: Icons.category_rounded,
    Icons.swap_horiz_rounded.codePoint: Icons.swap_horiz_rounded,
  };

  static IconData fromCodePoint(int codePoint) =>
      _iconsByCodePoint[codePoint] ?? fallback;
}
