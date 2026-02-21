// data/ethiopia_location_data.dart
class EthiopiaLocationData {

  static final List<String> country = ['ኢትዮጲያ'];

  static final Map<String, Map<String, List<String>>> amregions = {
    // አዲስ አበባ (Addis Ababa)
    'Addis Ababa': {
      'አዲስ አበባ': [
        'አራዳ',
        'ቂርቆስ',
        'ጉለሌ',
        'ልደታ',
        'ኮልፌ ቀራኒዮ',
        'ንፋስ ስልክ ላፍቶ',
        'የካ',
        'ቦሌ',
        'አቃቂ ቃሊቲ',
        'አዲስ ከተማ',
        'ለሚ ኩራ'
      ],
    },

    // ኦሮሚያ (Oromia)
    'ኦሮሚያ': {
      'አዳማ': ['አዳማ 01', 'አዳማ 02', 'አዳማ 03', 'አዳማ 04', 'አዳማ 05'],
      'ጅማ': ['መንደራ ኮቺ', 'ሄርማታ መርካቶ', 'ቦሳ አዲስ', 'ጅረን', 'አጋሮ'],
      'ቢሾፍቱ': ['ኬታ', 'ቢሾፍቱ ከተማ', 'ጎሮ', 'ዱከም'],
      'አምቦ': ['አምቦ ከተማ', 'ጉደር', 'ጀልዱ'],
      'ሻሸመኔ': ['ሻሸመኔ ከተማ', 'ኩየራ', 'አርሲ ነገሌ'],
      'ነቀምተ': ['ነቀምተ ከተማ', 'ጊዳ አያና', 'ሳሲጋ'],
      'የአዲስ አበባ አካባቢ': ['ሰበታ', 'ሆለታ', 'ቡራዩ', 'ሱሉልታ'],
      'የሐረር አካባቢ': ['አወደይ', 'ሂርና', 'ባቢሌ'],
      'ባሌ': ['ጎባ', 'ሮቤ', 'ዶዶላ', 'ጊኒር'],
      'አርሲ': ['አሰላ', 'በኮጂ', 'ኢተያ', 'ደራ'],
      'ቦራና': ['ያቤሎ', 'ሞያሌ', 'መጋዶ'],
      'ምስራቅ ሐረርጌ': ['ሐረር ከተማ', 'የድሬዳዋ አካባቢ', 'ከርሳ'],
      'ምዕራብ ሐረርጌ': ['ቺሮ', 'ምየሶ', 'ዶባ'],
      'ኢሉባቦር': ['መቱ', 'ጎሬ', 'በደሌ'],
      'የጅማ ዞን': ['አጋሮ', 'ሸበ', 'ሰርቦ'],
      'ከለም ወለጋ': ['ደምቢዶሎ', 'ሳይዮ', 'ነጆ'],
      'ሰሜን ሸዋ': ['ፊቼ', 'ኩዩ', 'ውቸሌ'],
    },

    // አማራ (Amhara)
    'አማራ': {
      'ባሕር ዳር': ['በላይ ዘለቀ', 'ጊሽ አባይ', 'ጣና ክፍለ ከተማ', 'ዘጌ', 'ሹም አቦ'],
      'ጎንደር': ['ማራኪ', 'አዘዞ', 'አራዳ', 'ቁስቋም', 'እምባቦ'],
      'ደሴ ከተማ አስተዳደር': ['ባንባዉሃ', 'ኩታበር', 'ቦራ'],
      'ደብረ ማርቆስ': ['አባይ ማዶ', 'ህዳር 11', 'ደብረ ወርቅ'],
      'ደብረ ብርሃን': ['ደብረ ብርሃን ከተማ', 'እነማይ', 'ሸዋ ሮቢት'],
      'ወልዲያ': ['ወልዲያ ከተማ', 'መርሳ', 'ኮቦ'],
      'ደቡብ ወሎ ዞን': ['ቃሉ','አርጎባ ልዩ ወረዳ'],
      'ኮምቦልቻ': ['ኮምቦልቻ ከተማ', 'ባቲ', 'ደሴ ዙሪያ'],
      'ደብረ ታቦር': ['ደብረ ታቦር ከተማ', 'ወረታ', 'ፋርታ'],
      'ላሊበላ': ['ላሊበላ ከተማ', 'ላስታ', 'ቡኛ'],
      'ደቡብ ጎንደር': ['ደብረ ታቦር', 'አዲስ ዘመን', 'ንፋስ ምቾ'],
      'ሰሜን ጎንደር': ['ጎንደር ከተማ', 'መተማ', 'ታች አርማቺሆ'],
      'ምስራቅ ጎጃም': ['ደብረ ማርቆስ', 'ደጀን', 'ብቸና'],
      'ምዕራብ ጎጃም': ['ፊኖቴ ሰላም', 'ዱርበቴ', 'ጅጋ'],
    },

    // ትግራይ (Tigray)
    'ትግራይ': {
      'መቐለ': ['ሀውልቲ', 'ሰሜን', 'ኩህያ', 'አዲ ሃኪ', 'ቀዳማይ ወያነ'],
      'አዲግራት': ['ውቅሮ', 'ሀውዜን', 'ስንቃታ', 'አዲ ጉዶም'],
      'አክሱም': ['አክሱም ከተማ', 'አድዋ', 'ይሀ'],
      'ሸረረ': ['ሸረረ ከተማ', 'እንዳ ሥላሴ', 'ማይ ጸብሪ'],
      'አድዋ': ['አድዋ ከተማ', 'እንጢቆ', 'ነበለት'],
      'ሑመራ': ['ሑመራ ከተማ', 'ራውያን', 'ማይ ካድራ'],
      'አላማታ': ['አላማታ ከተማ', 'ኮረም', 'ማይጨው'],
      'እንደርታ': ['የመቐለ አካባቢ', 'ህንጣሎ', 'ዋጅራት'],
      'ራያ አዘቦ': ['አላማታ', 'ኮቦ', 'ራያ ኮቦ'],
    },

    // ደቡብ (SNNPR)
    'ደቡብ': {
      'ሀዋሳ': ['ታቦር', 'መሃል ከተማ', 'አዲስ ከተማ', 'ጡላ', 'መነሃርያ'],
      'ወላይታ ሶዶ': ['ጊዶ', 'ፋና', 'ባሌ', 'ጉኑኖ', 'ቦዲቲ'],
      'አርባ ምንጭ': ['አርባ ምንጭ ከተማ', 'ስቀላ', 'ላንተ'],
      'ዲላ': ['ዲላ ከተማ', 'ወናጎ', 'ይርጋ ቸፌ'],
      'ሆሳና': ['ሆሳና ከተማ', 'ጊቤ', 'አንለሞ'],
      'ወራቤ': ['ወራቤ ከተማ', 'ቡታጅራ', 'መስቀን'],
      'ጅንካ': ['ጅንካ ከተማ', 'ኬይ አፈር', 'ማጎ'],
      'በንች ማጂ': ['ምዝን አማን', 'ሸ በንች', 'ጉራፈርዳ'],
      'ጋሞ ጎፋ': ['አርባ ምንጭ', 'ቸንቻ', 'ካምባ'],
      'ሲዳማ': ['ሀዋሳ', 'ይርጋለም', 'አለታ ዎንዶ'],
      'ጌዴኦ': ['ዲላ', 'ይርጋ ቸፌ', 'ወናጎ'],
      'ካፋ': ['ቦንጋ', 'ውሽ ውሽ', 'ግምቦ'],
      'ሀድያ': ['ሆሳና', 'ጊቤ', 'ሶሮሮ'],
      'ከምባታ ተምባሮ': ['ዱራሜ', 'ከዲዳ ጋሜላ', 'ዶዮገና'],
      'ስልጤ': ['ወራቤ', 'ቡታጅራ', 'አልቾ'],
    },

    // ሀረሪ (Harari)
    'ሀረሪ': {
      'ሐረር': ['አባዲር', 'ጁጎል', 'ሐኪም', 'ሸንኮር', 'አርጎበሪ', 'ሱቁታትበሪ', 'ጊድር ማጋላ'],
    },

    // ድሬደዋ (Dire Dawa)
    'ድሬደዋ': {
      'ድሬዳዋ': [
        'ጉርጉራ',
        'ደቻቱ',
        'ለጋሃራ',
        'ሳቢያን',
        'መልካ ጀብዱ',
        'ቢላል',
        'ከዚራ',
        'አዲስ ከተማ'
      ],
    },

    // ጋምቤላ (Gambela)
    'ጋምቤላ': {
      'ጋምቤላ': ['ጋምቤላ ከተማ', 'ኢታንግ', 'ጎግ', 'አቦቦ', 'ጆር'],
      'ጎደሬ': ['ጎደሬ', 'መንገሽ'],
      'አኮቦ': ['አኮቦ', 'ጅካው'],
    },

    // ቤኒሻንጉል-ጉምዝ (Benishangul-Gumuz)
    'ቤኒሻንጉል-ጉምዝ': {
      'አሶሳ': ['አሶሳ ከተማ', 'ባምባሲ', 'ኦዳ', 'ከሽማንዶ'],
      'መተከል': ['ጊልጊል በለስ', 'ድባቴ', 'ጉባ', 'ማንድራ'],
      'ካማሺ': ['ካማሺ ከተማ', 'ያሶ', 'ስርባ አባይ'],
      'ፓወ': ['ፓወ', 'ቡላ', 'ዳንጉር'],
    },

    // አፋር (Afar)
    'አፋር': {
      'ሰመራ': ['ሰመራ ከተማ', 'ሎጊያ', 'ገዋኔ'],
      'አዋሽ': ['አዋሽ ከተማ', 'መልካ ወረር', 'ቡሬ ሙዳይቱ'],
      'ዱብቲ': ['ዱብቲ ከተማ', 'አሳይታ', 'አፋምቦ'],
      'ገዋኔ': ['ገዋኔ ከተማ', 'ቡሬ ሞዳይቶ', 'ኢዋ'],
      'ተንዳሆ': ['ተንዳሆ', 'ዱላቻ', 'ሀዶ'],
    },

    // ሶማሌ (Somali)
    'ሶማሌ': {
      'ጅጅጋ': ['ጅጅጋ ከተማ', 'አዋሬ', 'ከብሪ በያህ'],
      'ጎደ': ['ጎደ ከተማ', 'ዶሎ', 'ፍልቱ'],
      'ከብሪ ዳሃር': ['ከብሪ ዳሃር ከተማ', 'ሸኮሽ', 'ሽላቮ'],
      'ደገሀቡር': ['ደገሀቡር ከተማ', 'ጉናጋዶ', 'ቢከ'],
      'ዋርደር': ['ዋርደር ከተማ', 'ገላዲ', 'ቦህ'],
      'ሽኒሌ': ['ሽኒሌ ከተማ', 'አይሻ', 'ኤረር'],
    },
  };

  static final Map<String, Map<String, List<String>>> regions = {
    // አዲስ አበባ (Addis Ababa)
    'Addis Ababa': {
      'Addis Ababa': [
        'Arada',
        'Kirkos',
        'Gulele',
        'Lideta',
        'Kolfe Keranio',
        'Nifas Silk-Lafto',
        'Yeka',
        'Bole',
        'Akaki Kaliti',
        'Addis Ketema',
        'Lemi Kura'
      ],
    },

    // ኦሮሚያ (Oromia)
    'Oromia': {
      'Adama': ['Adama 01', 'Adama 02', 'Adama 03', 'Adama 04', 'Adama 05'],
      'Jimma': ['Mendera Kochi', 'Hermata Merkato', 'Bosa Addis', 'Jiren', 'Agaro'],
      'Bishoftu': ['Keta', 'Bishoftu City', 'Goro', 'Dukem'],
      'Ambo': ['Ambo Town', 'Guder', 'Jeldu'],
      'Shashamane': ['Shashamane City', 'Kuyera', 'Arsi Negele'],
      'Nekemte': ['Nekemte Town', 'Gida Ayana', 'Sasiga'],
      'Addis Ababa Surrounding': ['Sebeta', 'Holeta', 'Burayu', 'Sululta'],
      'Harar Surrounding': ['Aweday', 'Hirna', 'Babile'],
      'Bale': ['Goba', 'Robe', 'Dodola', 'Ginir'],
      'Arsi': ['Asella', 'Bekoji', 'Iteya', 'Dera'],
      'Borana': ['Yabelo', 'Moyale', 'Megado'],
      'East Hararghe': ['Harar City', 'Dire Dawa Surrounding', 'Kersa'],
      'West Hararghe': ['Chiro', 'Mieso', 'Doba'],
      'Illubabor': ['Metu', 'Gore', 'Bedele'],
      'Jimma Zone': ['Agaro', 'Shebe', 'Serbo'],
      'Kelem Welega': ['Dembidolo', 'Sayyo', 'Nejo'],
      'North Shewa': ['Fiche', 'Kuyu', 'Wuchale'],
    },

    // አማራ (Amhara)
    'Amhara': {
      'Bahir Dar': ['Belay Zeleke', 'Gish Abay', 'Tana Subcity', 'Zegie', 'Shum Abo'],
      'Gondar': ['Maraki', 'Azezo', 'Arada', 'Qusquam', 'Embabo'],
      'Dessie Town Administration': ['banbawuha', 'Kutaber', 'Bora'],
      'Debre Markos': ['Abay Mado', 'Hidar 11', 'Debre Work'],
      'Debre Birhan': ['Debre Birhan Town', 'Enemay', 'Shewa Robit'],
      'Woldia': ['Woldia Town', 'Mersa', 'Kobo'],
      'South Wollo Zone': ['Kalu', 'Argoba Special Woreda',],
      'Kombolcha': ['Kombolcha Town', 'Bati','Dessie Zuria'],
      'Debre Tabor': ['Debre Tabor Town', 'Woreta', 'Farta'],
      'South Gondar': ['Debre Tabor', 'Addis Zemen', 'Nefas Mewcha'],
      'North Gondar': ['Gondar City', 'Metema', 'Tach Armachiho'],
      'East Gojjam': ['Debre Markos', 'Dejen', 'Bichena'],
      'West Gojjam': ['Finote Selam', 'Durbete', 'Jiga'],
    },

    // ትግራይ (Tigray)
    'Tigray': {
      'Mekelle': ['Hawelti', 'Semien', 'Quiha', 'Adi Haki', 'Kedamay Weyane'],
      'Adigrat': ['Wukro', 'Hawzen', 'Sinkata', 'Adi Gudom'],
      'Axum': ['Axum Town', 'Adwa', 'Yeha'],
      'Shire': ['Shire Town', 'Inda Selassie', 'Mai Tsebri'],
      'Adwa': ['Adwa Town', 'Enticho', 'Nebelet'],
      'Humera': ['Humera Town', 'Rawyan', 'May Kadra'],
      'Alamata': ['Alamata Town', 'Korem', 'Maichew'],
      'Enderta': ['Mekelle Surrounding', 'Hintalo', 'Wajirat'],
      'Raya Azebo': ['Alamata', 'Kobo', 'Raya Kobo'],
    },

    // ደቡብ (SNNPR)
    'SNNPR': {
      'Hawassa': ['Tabour', 'Mehal Ketema', 'Addis Ketema', 'Tulla', 'Menehariya'],
      'Wolaita Sodo': ['Gido', 'Fana', 'Bale', 'Gununo', 'Boditi'],
      'Arba Minch': ['Arba Minch Town', 'Sikela', 'Lante'],
      'Dilla': ['Dilla Town', 'Wonago', 'Yirga Chefe'],
      'Hossana': ['Hossana Town', 'Gibee', 'Anlemo'],
      'Worabe': ['Worabe Town', 'Butajira', 'Meskan'],
      'Jinka': ['Jinka Town', 'Key Afer', 'Mago'],
      'Bench Maji': ['Mizan Aman', 'She Bench', 'Guraferda'],
      'Gamo Gofa': ['Arba Minch', 'Chencha', 'Kamba'],
      'Sidama': ['Hawassa', 'Yirgalem', 'Aleta Wondo'],
      'Gedeo': ['Dilla', 'Yirga Chefe', 'Wenago'],
      'Kaffa': ['Bonga', 'Wush Wush', 'Gimbo'],
      'Hadiya': ['Hossana', 'Gibee', 'Sororo'],
      'Kembata Tembaro': ['Durame', 'Kedida Gamela', 'Doyogena'],
      'Siltie': ['Worabe', 'Butajira', 'Alicho'],
    },

    // ሀረሪ (Harari)
    'Harari': {
      'Harar': ['Abadir', 'Jugol', 'Hakim', 'Shenkor', 'Argobberi', 'Suqutatberi', 'Gidir Magala'],
    },

    // ድሬደዋ (Dire Dawa)
    'Dire Dawa': {
      'Dire Dawa': [
        'Gurgura',
        'Dechatu',
        'Legahara',
        'Sabian',
        'Melka Jebdu',
        'Bilal',
        'Kezira',
        'Addis Ketema'
      ],
    },

    // ጋምቤላ (Gambela)
    'Gambela': {
      'Gambela': ['Gambela Town', 'Itang', 'Gog', 'Abobo', 'Jor'],
      'Godere': ['Godere', 'Mengesh'],
      'Akobo': ['Akobo', 'Jikaw'],
    },

    // ቤኒሻንጉል-ጉምዝ (Benishangul-Gumuz)
    'Benishangul-Gumuz': {
      'Assosa': ['Assosa Town', 'Bambasi', 'Oda', 'Keshmando'],
      'Metekel': ['Gilgil Beles', 'Dibate', 'Guba', 'Mandra'],
      'Kamashi': ['Kamashi Town', 'Yaso', 'Sirba Abay'],
      'Pawe': ['Pawe', 'Bula', 'Dangur'],
    },

    // አፋር (Afar)
    'Afar': {
      'Semera': ['Semera Town', 'Logia', 'Gewane'],
      'Awash': ['Awash Town', 'Melka Werer', 'Bure Mudaytu'],
      'Dubti': ['Dubti Town', 'Asayita', 'Afambo'],
      'Gewane': ['Gewane Town', 'Bure Modaito', 'Ewa'],
      'Tendaho': ['Tendaho', 'Dulacha', 'Hado'],
    },

    // ሶማሌ (Somali)
    'Somali': {
      'Jijiga': ['Jijiga Town', 'Aware', 'Kebri Beyah'],
      'Gode': ['Gode Town', 'Dolo', 'Filtu'],
      'Kebri Dahar': ['Kebri Dahar Town', 'Shekosh', 'Shilavo'],
      'Degehabur': ['Degehabur Town', 'Gunagado', 'Bike'],
      'Warder': ['Warder Town', 'Geladi', 'Boh'],
      'Shinile': ['Shinile Town', 'Aysha', 'Erer'],
    },
  };

  static List<String> getRegions() => regions.keys.toList();
  static List<String> getamRegions() => amregions.keys.toList();

  static List<String> getCities(String region) {
    return regions[region]?.keys.toList() ?? [];
  }
  static List<String> getamCities(String region) {
    return amregions[region]?.keys.toList() ?? [];
  }

  static List<String> getSubCities(String region, String city) {
    return regions[region]?[city] ?? [];
  }
  static List<String> getamSubCities(String region, String city) {
    return amregions[region]?[city] ?? [];
  }

  // Additional helper methods
  static List<String> getAllCities() {
    List<String> allCities = [];
    regions.forEach((region, cities) {
      allCities.addAll(cities.keys);
    });
    return allCities.toSet().toList(); // Remove duplicates
  }
  // Additional helper methods
  static List<String> getAllCitiesam() {
    List<String> allCities = [];
    amregions.forEach((region, cities) {
      allCities.addAll(cities.keys);
    });
    return allCities.toSet().toList(); // Remove duplicates
  }

  static String? findRegionOfCity(String city) {
    for (var region in regions.keys) {
      if (regions[region]!.containsKey(city)) {
        return region;
      }
    }
    return null;
  }
  static String? findRegionOfCityam(String city) {
    for (var region in amregions.keys) {
      if (amregions[region]!.containsKey(city)) {
        return region;
      }
    }
    return null;
  }
}