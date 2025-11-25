import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsSection extends StatefulWidget {
  const AdsSection({super.key});

  @override
  State<AdsSection> createState() => _AdsSectionState();
}

class _AdsSectionState extends State<AdsSection> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // ⚠️ IMPORTANT: Use this TEST ID for development.
  // If you use your real ID while testing, your account will be banned.
  // REPLACE with your Real ID only when building for the Play Store.
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-8732422930809097/2155648792' // Android Test ID
      : 'ca-app-pub-3940256099942544/2934735716'; // iOS Test ID

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          print('Ad failed to load: $err');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If ad hasn't loaded yet, return empty space or a placeholder
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(height: 50); // Keeps layout stable
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}