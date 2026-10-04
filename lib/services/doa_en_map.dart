// Pemetaan doa equran.id -> terjemahan INGGRIS.
//
// GENERATED — jangan diedit manual. Dibangun dari perbandingan teks ARAB antara
// katalog equran.id (227 doa, Indonesia) dan ummahapi.com (126 doa, Inggris).
//
// Cakupan: 41 dari 227 doa. Sumber Inggris TIDAK memuat versi Inggris untuk 186
// doa sisanya, jadi entri ini TAMBAHAN opsional — bukan pengganti katalog.
//
// Aturan pemasangan (ketat, supaya tidak salah pasang):
//  1. Arab harus identik setelah normalisasi harakat, atau mirip >= 92%.
//  2. Arab itu harus UNIK di kedua katalog. Frasa umum seperti بسم الله
//     (Bismillah, 7 huruf) muncul di banyak doa berbeda; memetakannya akan
//     menempelkan "Before Eating" ke doa wudhu dan doa masuk rumah. Karena itu
//     doa pendek nan umum sengaja TIDAK dipetakan.
//
// Kunci pencocokan = `arNorm` (huruf Arab saja, harakat dibuang) supaya cocok
// dengan normalizeArabic() di doa_api.dart. `tags` + `nama` disimpan sebagai
// jaring pengaman: kalau equran.id menomori ulang katalognya, pencocokan Arab
// masih menentukan pasangan yang sama.

class DoaEnEntry {
  final String title, translation, transliteration, source;
  const DoaEnEntry({
    required this.title,
    required this.translation,
    required this.transliteration,
    required this.source,
  });
}

/// Normalisasi Arab: buang harakat/simbol, sisakan huruf.
///
/// Disamakan persis dengan sisi pembangkit (Python) agar kunci `arNorm`
/// cocok: `re.sub(r'[^\u0621-\u064A]', '', s)`.
String normalizeArabic(String s) =>
    s.replaceAll(RegExp(r'[^\u0621-\u064A]'), '');

/// Arab (ternormalisasi) -> terjemahan Inggris.
const doaEnByArabic = <String, DoaEnEntry>{
  'باسمكاللهمأموتوأحيا': DoaEnEntry(
    title: 'Before Sleeping',
    translation: 'In Your name, O Allah, I die and I live.',
    transliteration: 'Bismika Allahumma amutu wa ahya',
    source: 'Sahih Al-Bukhari 11:113',
  ),
  'الحمدللهالذيأحيانابعدماأماتناوإليهالنشور': DoaEnEntry(
    title: 'Upon Waking Up',
    translation: 'All praise is for Allah who gave us life after having taken it from us, and unto Him is the resurrection.',
    transliteration: 'Alhamdu lillahilladhi ahyana ba\'da ma amatana wa ilaihin-nushur',
    source: 'Sahih Al-Bukhari 11:113',
  ),
  'أشهدأنلاإلـهإلااللهوحدهلاشريكلهوأشهدأنمحمداعبدهورسوله': DoaEnEntry(
    title: 'After Wudu',
    translation: 'I bear witness that there is no deity worthy of worship except Allah alone, with no partner, and I bear witness that Muhammad is His slave and messenger.',
    transliteration: 'Ash-hadu an la ilaha illallahu wahdahu la shareeka lahu wa ash-hadu anna Muhammadan \'abduhu wa rasuluh',
    source: 'Sahih Muslim 1:234',
  ),
  'الحمدللهالذيكسانيهـذاالثوبورزقنيهمنغيرحولمنيولاقوة': DoaEnEntry(
    title: 'When Putting On Clothes',
    translation: 'All praise is for Allah who clothed me with this and provided it for me without any might or power from myself.',
    transliteration: 'Alhamdu lillahilladhi kasani hadha wa razaqanihi min ghayri hawlin minni wa la quwwah',
    source: 'Abu Dawud 4:41, At-Tirmidhi 5:521',
  ),
  'اللهمصيبانافعا': DoaEnEntry(
    title: 'When It Rains',
    translation: 'O Allah, let it be a beneficial rain.',
    transliteration: 'Allahumma sayyiban nafi\'a',
    source: 'Sahih Al-Bukhari',
  ),
  'باركاللهلكوباركعليكوجمعبينكمافيخير': DoaEnEntry(
    title: 'Dua at a Wedding',
    translation: 'May Allah bless you, and shower His blessings upon you, and join you together in goodness.',
    transliteration: 'Barakallahu laka wa baraka \'alayka wa jama\'a baynakuma fi khayr',
    source: 'Abu Dawud 2:228, At-Tirmidhi 3:221',
  ),
  'اللهمإنيأسألكخيرهاوخيرماجبلتهاعليهوأعوذبكمنشرهاوشرماجبلتهاعليه': DoaEnEntry(
    title: 'Dua on Seeing Spouse',
    translation: 'O Allah, I ask You for her goodness and the goodness of the nature You have created in her, and I seek refuge in You from her evil and the evil of the nature You have created in her.',
    transliteration: 'Allahumma inni as\'aluka khayrahā wa khayra ma jabaltaha \'alayhi wa a\'udhu bika min sharriha wa sharri ma jabaltaha \'alayh',
    source: 'Abu Dawud 2:248, Ibn Majah 1:617',
  ),
  'بسماللهاللهمجنبناالشيطانوجنبالشيطانمارزقتنا': DoaEnEntry(
    title: 'Dua Before Intercourse',
    translation: 'In the name of Allah. O Allah, keep the devil away from us and keep the devil away from what You provide for us. (If a child is conceived, the devil will not harm it.)',
    transliteration: 'Bismillah, Allahumma jannibnash-shaytana wa jannibish-shaytana ma razaqtana',
    source: 'Sahih Al-Bukhari 7:94, Sahih Muslim 2:1058',
  ),
  'ربإنيمسنيالضروأنتأرحمالراحمين': DoaEnEntry(
    title: 'Dua of Prophet Ayyub (Job)',
    translation: 'My Lord, adversity has touched me, and You are the Most Merciful of the merciful.',
    transliteration: 'Rabbi anni massaniyad-durru wa anta arhamur-rahimin',
    source: 'Quran 21:83',
  ),
  'اللهمربالناسأذهبالباساشفأنتالشافيلاشفاءإلاشفاؤكشفاءلايغادرسقما': DoaEnEntry(
    title: 'Dua for Healing',
    translation: 'O Allah, Lord of mankind, remove the affliction. Cure, for You are the One who cures. There is no cure except Your cure, a cure that leaves no illness behind.',
    transliteration: 'Allahumma Rabban-nasi, adhibil-ba\'sa, ishfi antash-Shafi, la shifa\'a illa shifa\'uka, shifa\'an la yughadiru saqama',
    source: 'Sahih Al-Bukhari 7:379, Sahih Muslim',
  ),
  'اللهملاسهلإلاماجعلتهسهلاوأنتتجعلالحزنإذاشئتسهلا': DoaEnEntry(
    title: 'Dua for Ease in Difficulty',
    translation: 'O Allah, there is no ease except in that which You have made easy, and You make the difficult easy if You wish.',
    transliteration: 'Allahumma la sahla illa ma ja\'altahu sahla wa anta taj\'alul-hazna idha shi\'ta sahla',
    source: 'Ibn Hibban, Ibn As-Sunni',
  ),
  'لاإلـهإلاأنتسبحانكإنيكنتمنالظالمين': DoaEnEntry(
    title: 'Dua of Yunus (Jonah)',
    translation: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
    transliteration: 'La ilaha illa anta subhanaka inni kuntu minadh-dhalimeen',
    source: 'Quran 21:87, At-Tirmidhi',
  ),
  'إناللهوإناإليهراجعوناللهمأجرنيفيمصيبتيوأخلفليخيرامنها': DoaEnEntry(
    title: 'Inna Lillahi (Upon a Calamity)',
    translation: 'Surely to Allah we belong and to Him we shall return. O Allah, reward me in my calamity and replace it with something better.',
    transliteration: 'Inna lillahi wa inna ilayhi raji\'un, Allahumma-jurni fi musibati wa akhlif li khayran minha',
    source: 'Sahih Muslim 2:632',
  ),
  'الحمدللهالذيبنعمتهتتمالصالحات': DoaEnEntry(
    title: 'Praising Allah Upon Receiving a Blessing',
    translation: 'All praise is for Allah, by whose blessing all good things are completed.',
    transliteration: 'Alhamdu lillahilladhi bi-ni\'matihi tatimus-salihat',
    source: 'Ibn Majah 2:1265, Al-Hakim',
  ),
  'اللهماكفنيبحلالكعنحرامكوأغننيبفضلكعمنسواك': DoaEnEntry(
    title: 'Dua for Provision (Rizq)',
    translation: 'O Allah, suffice me with what You have made lawful against what You have made unlawful, and make me independent of all others besides You through Your bounty.',
    transliteration: 'Allahummak-fini bihalali \'an haramika wa aghnini bifadlika \'amman siwak',
    source: 'At-Tirmidhi 5:560',
  ),
  'أستودعاللهدينكوأمانتكوخواتيمعملك': DoaEnEntry(
    title: 'Dua for the Traveler (From Family at Home)',
    translation: 'I entrust Allah with your religion, your trust, and the ends of your deeds.',
    transliteration: 'Astawdi\'ullah dinaka wa amanataka wa khawatima \'amalik',
    source: 'Abu Dawud 3:74, At-Tirmidhi 5:499',
  ),
  'اللهمربالسماواتالسبعوماأظللنوربالأرضينالسبعوماأقللنوربالشياطينوماأضللنوربالرياحوماذرينأسألكخيرهـذهالقريةوخيرأهلهاوخيرمافيهاوأعوذبكمنشرهاوشرأهلهاوشرمافيها': DoaEnEntry(
    title: 'Entering a Town or City',
    translation: 'O Allah, Lord of the seven heavens and all that they envelop, Lord of the seven earths and all that they carry, Lord of the devils and all whom they misguide, Lord of the winds and all whom they whisk away. I ask You for the goodness of this town, the goodness of its people and the goodness of what is in it. I seek refuge in You from its evil, the evil of its people and the evil of what is in it.',
    transliteration: 'Allahumma Rabbas-samawatis-sab\'i wa ma adhlalna, wa Rabbal-aradeenas-sab\'i wa ma aqlalna, wa Rabbash-shayateeni wa ma adlalna, wa Rabbar-riyahi wa ma dharayna, as\'aluka khayra hadhihil-qaryati wa khayra ahliha wa khayra ma fiha, wa a\'udhu bika min sharriha wa sharri ahliha wa sharri ma fiha',
    source: 'Al-Hakim 2:100, An-Nasai',
  ),
  'لاإلـهإلااللهوحدهلاشريكلهلهالملكولهالحمديحييويميتوهوحيلايموتبيدهالخيروهوعلىكلشيءقدير': DoaEnEntry(
    title: 'Dua at the Market',
    translation: 'None has the right to be worshipped except Allah, alone, without partner. To Him belongs all sovereignty and all praise. He gives life and causes death. He is living and does not die. In His hand is all goodness and He is over all things omnipotent. (Allah will write a million good deeds for whoever says this at the market.)',
    transliteration: 'La ilaha illallahu wahdahu la shareeka lah, lahul-mulku wa lahul-hamdu yuhyi wa yumitu wa huwa hayyun la yamutu biyadihil-khayru wa huwa \'ala kulli shay\'in qadir',
    source: 'At-Tirmidhi 5:491',
  ),
  'اللهمأحسنتخلقيفأحسنخلقي': DoaEnEntry(
    title: 'Dua for Good Character',
    translation: 'O Allah, You have made my physical form beautiful, so beautify my character too.',
    transliteration: 'Allahumma ahsanta khalqi fa-ahsin khuluqi',
    source: 'Ahmad, Ibn Hibban',
  ),
  'ربارحمهماكماربيانيصغيرا': DoaEnEntry(
    title: 'Dua for Parents',
    translation: 'My Lord, have mercy upon them as they brought me up when I was small.',
    transliteration: 'Rabbir-hamhuma kama rabbayani sagheera',
    source: 'Quran 17:24',
  ),
  'ربناهبلنامنأزواجناوذرياتناقرةأعينواجعلناللمتقينإماما': DoaEnEntry(
    title: 'Dua for a Righteous Spouse and Offspring',
    translation: 'Our Lord, grant us from among our spouses and offspring comfort to our eyes and make us a leader for the righteous.',
    transliteration: 'Rabbana hab lana min azwajina wa dhurriyyatina qurrata a\'yunin waj\'alna lil-muttaqina imama',
    source: 'Quran 25:74',
  ),
  'باركاللهلكفيالموهوبلكوشكرتالواهبوبلغأشدهورزقتبره': DoaEnEntry(
    title: 'Dua Upon Seeing a Newborn',
    translation: 'May Allah bless you in what has been gifted to you, may you give thanks to the Giver, may he reach maturity, and may you be granted his piety.',
    transliteration: 'Barakallahu laka fil-mawhubu laka wa shakarta-l-wahiba wa balagha ashuddahu wa ruziqta birrah',
    source: 'Ibn As-Sunni, Al-Bayhaqi',
  ),
  'أعيذكبكلماتاللهالتامةمنكلشيطانوهامةومنكلعينلامة': DoaEnEntry(
    title: 'Dua for Newborn Protection',
    translation: 'I seek refuge for you in the perfect words of Allah from every devil and every poisonous reptile and from every evil eye.',
    transliteration: 'U\'idhuka bikalimatillahit-tammati min kulli shaytanin wa hammatin wa min kulli \'aynin lammah',
    source: 'Sahih Al-Bukhari 4:119',
  ),
  'يامقلبالقلوبثبتقلبىعلىدينك': DoaEnEntry(
    title: 'Dua for Steadfastness on the Truth',
    translation: 'O Turner of hearts, keep my heart firm upon Your religion.',
    transliteration: 'Ya Muqallibal-qulub, thabbit qalbi \'ala dinik',
    source: 'At-Tirmidhi 4:447, Ahmad',
  ),
  'اللهمإنيأعوذبكمنعلملاينفعومنقلبلايخشعومننفسلاتشبعومندعوةلايستجابلها': DoaEnEntry(
    title: 'Seeking Refuge from Useless Knowledge',
    translation: 'O Allah, I seek refuge in You from knowledge that does not benefit, from a heart that does not fear, from a soul that is not satisfied, and from a supplication that is not answered.',
    transliteration: 'Allahumma inni a\'udhu bika min \'ilmin la yanfa\'u wa min qalbin la yakhsha\'u wa min nafsin la tashba\'u wa min da\'watin la yustajabu laha',
    source: 'Sahih Muslim 4:2088, Abu Dawud',
  ),
  'ربزدنيعلما': DoaEnEntry(
    title: 'Increase in Knowledge',
    translation: 'My Lord, increase me in knowledge.',
    transliteration: 'Rabbi zidni \'ilma',
    source: 'Quran 20:114',
  ),
  'اللهمانفعنيبماعلمتنيوعلمنيماينفعنيوزدنيعلما': DoaEnEntry(
    title: 'Dua for Beneficial Knowledge',
    translation: 'O Allah, benefit me with what You have taught me, teach me what will benefit me, and increase me in knowledge.',
    transliteration: 'Allahumman-fa\'ni bima \'allamtani wa \'allimni ma yanfa\'uni wa zidni \'ilma',
    source: 'At-Tirmidhi 5:742, Ibn Majah 1:92',
  ),
  'رباجعلنيمقيمالصلاةومنذريتيربناوتقبلدعاء': DoaEnEntry(
    title: 'Dua of Prophet Ibrahim for His Offspring',
    translation: 'My Lord, make me an establisher of prayer, and from my descendants. Our Lord, and accept my supplication.',
    transliteration: 'Rabbij\'alni muqimas-salati wa min dhurriyyati, rabbana wa taqabbal du\'a',
    source: 'Quran 14:40',
  ),
  'حسبياللهلاإلـهإلاهوعليهتوكلتوهوربالعرشالعظيم': DoaEnEntry(
    title: 'Hasbiyallah',
    translation: 'Allah is sufficient for me. There is no deity worthy of worship except Him. I place my trust in Him and He is the Lord of the Great Throne. (Whoever says this 7 times morning and evening, Allah will take care of whatever worries him.)',
    transliteration: 'Hasbiyallahu la ilaha illa huwa \'alayhi tawakkaltu wa huwa Rabbul-\'Arshil-\'Adheem',
    source: 'Abu Dawud 4:321',
  ),
  'بسماللهتوكلتعلىاللهلاحولولاقوةإلابالله': DoaEnEntry(
    title: 'Leaving the Home',
    translation: 'In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.',
    transliteration: 'Bismillah, tawakkaltu \'alallah, wa la hawla wa la quwwata illa billah',
    source: 'Abu Dawud 4:325, At-Tirmidhi 5:490',
  ),
  'اللهمربهـذهالدعوةالتامةوالصلاةالقائمةآتمحمداالوسيلةوالفضيلةوابعثهمقامامحموداالذيوعدته': DoaEnEntry(
    title: 'Dua After Adhan',
    translation: 'O Allah, Lord of this perfect call and the prayer that is to come, grant Muhammad the privilege and the distinction, and raise him to a praised station that You have promised him.',
    transliteration: 'Allahumma Rabba hadhihid-da\'watit-tammati was-salatil-qa\'ima, ati Muhammadanil-wasilata wal-fadilata wab\'ath-hu maqaman mahmudanil-ladhi wa\'adtah',
    source: 'Sahih Al-Bukhari 1:614',
  ),
  'بسماللهأولهوآخره': DoaEnEntry(
    title: 'Forgetting Bismillah Before Eating',
    translation: 'In the name of Allah at its beginning and at its end.',
    transliteration: 'Bismillahi awwalahu wa akhirah',
    source: 'Abu Dawud 3:347, At-Tirmidhi 4:288',
  ),
  'الحمدللهالذيأطعمنيهـذاورزقنيهمنغيرحولمنيولاقوة': DoaEnEntry(
    title: 'After Eating',
    translation: 'All praise is for Allah who fed me this and provided it for me without any might or power from myself.',
    transliteration: 'Alhamdu lillahilladhi at\'amani hadha wa razaqanihi min ghayri hawlin minni wa la quwwah',
    source: 'Abu Dawud, At-Tirmidhi, Ibn Majah',
  ),
  'اللهمأطعممنأطعمنيواسقمنسقاني': DoaEnEntry(
    title: 'Dua When Invited to Eat',
    translation: 'O Allah, feed the one who has fed me, and give drink to the one who has given me drink.',
    transliteration: 'Allahumma at\'im man at\'amani wasqi man saqani',
    source: 'Sahih Muslim 3:126',
  ),
  'أفطرعندكمالصائمونوأكلطعامكمالأبراروصلتعليكمالملائكة': DoaEnEntry(
    title: 'Dua for the Host',
    translation: 'May the fasting break their fast with you, may the righteous eat your food, and may the angels send blessings upon you.',
    transliteration: 'Aftara \'indakumus-sa\'imuna wa akala ta\'amakumul-abrar wa sallat \'alaykumul-mala\'ikah',
    source: 'Abu Dawud 3:367, Ibn Majah 1:556',
  ),
  'أعوذبكلماتاللهالتامةمنكلشيطانوهامةومنكلعينلامة': DoaEnEntry(
    title: 'Seeking Protection from Evil Eye',
    translation: 'I seek refuge in the perfect words of Allah from every devil and every poisonous reptile, and from every evil eye.',
    transliteration: 'A\'udhu bikalimatillahit-tammati min kulli shaytanin wa hammatin wa min kulli \'aynin lammah',
    source: 'Sahih Al-Bukhari 4:119',
  ),
  'ربناآتنافيالدنياحسنةوفيالآخرةحسنةوقناعذابالنار': DoaEnEntry(
    title: 'Dua for Best of This World and Next',
    translation: 'Our Lord, give us good in this world and good in the next, and protect us from the punishment of the Fire.',
    transliteration: 'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adhaban-nar',
    source: 'Quran 2:201, Sahih Al-Bukhari 8:95',
  ),
  'اللهأكبر': DoaEnEntry(
    title: 'Allahu Akbar After Prayer',
    translation: 'Allah is the Greatest.',
    transliteration: 'Allahu Akbar',
    source: 'Sahih Muslim 1:418',
  ),
  'أستغفراللهالعظيمالذيلاإلـهإلاهوالحيالقيوموأتوبإليه': DoaEnEntry(
    title: 'Seeking Forgiveness',
    translation: 'I seek the forgiveness of Allah the Mighty, whom there is none worthy of worship except Him, the Living, the Sustainer, and I repent to Him.',
    transliteration: 'Astaghfirullaha al-\'Adheem alladhi la ilaha illa Huwal-Hayyul-Qayyum wa atubu ilayh',
    source: 'Abu Dawud, At-Tirmidhi',
  ),
  'سبحاناللهوالحمدللهولاإلـهإلااللهواللهأكبر': DoaEnEntry(
    title: 'Complete Tasbih, Tahmid, Takbir',
    translation: 'Glory be to Allah, all praise is due to Allah, there is no deity worthy of worship except Allah, and Allah is the Greatest.',
    transliteration: 'SubhanAllahi wal-hamdu lillahi wa la ilaha illallahu wallahu akbar',
    source: 'Sahih Muslim 4:2072',
  ),
  'سبحانكاللهموبحمدكأشهدأنلاإلـهإلاأنتأستغفركوأتوبإليك': DoaEnEntry(
    title: 'Dua Upon Completing the Quran',
    translation: 'Glory be to You O Allah and all praise, I bear witness that there is no deity worthy of worship except You. I seek Your forgiveness and I repent to You.',
    transliteration: 'SubhanakaAllahumma wa bihamdika ash-hadu an la ilaha illa anta astaghfiruka wa atubu ilayk',
    source: 'An-Nasai, At-Tirmidhi',
  ),
};
