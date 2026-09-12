// ponytail: SATU-SATUNYA tempat icon set muncul. Ganti/tambah icon = edit
// file ini saja (call site pakai AppIcons.*, bukan Icons.* lagi).
//
// Font Phosphor di-vendor langsung (assets/fonts/Phosphor-{Regular,Fill}.ttf,
// lisensi MIT ada di Phosphor-LICENSE.txt) — TIDAK pakai paket phosphor_flutter
// karena 2.1.0 (terakhir) masih `extends IconData`, sedangkan IconData sudah
// `final class` di Flutter 3.44.4 → gagal compile.
// Phosphor dipilih karena punya glyph yang benar-benar cocok konten app:
// mosque, handsPraying, sunHorizon, shieldStar, starAndCrescent, fire.
// Konvensi nama sengaja meniru Material (home / homeOutlined) agar call site
// tetap familiar.
//
// Plain = state aktif (weight Fill), `*Outlined` = state non-aktif (Regular).
import 'package:flutter/widgets.dart';

class AppIcons {
  AppIcons._();

  static const acUnit = IconData(0xe5aa, fontFamily: 'Phosphor');
  static const addModerator = IconData(0xe4d0, fontFamily: 'Phosphor');
  static const alarmOn = IconData(0xe006, fontFamily: 'Phosphor');
  static const allInclusive = IconData(0xe634, fontFamily: 'Phosphor');
  static const arrowBack = IconData(0xe058, fontFamily: 'Phosphor');
  static const arrowForward = IconData(0xe06c, fontFamily: 'Phosphor');
  static const arrowForwardIos = IconData(0xe13a, fontFamily: 'Phosphor');
  static const autoAwesome = IconData(0xe6a2, fontFamily: 'PhosphorFill');
  static const autoAwesomeOutlined = IconData(0xe6a2, fontFamily: 'Phosphor');
  static const autoStories = IconData(0xe8f2, fontFamily: 'PhosphorFill');
  static const autoStoriesOutlined = IconData(0xe8f2, fontFamily: 'Phosphor');
  static const batteryAlert = IconData(0xe0c8, fontFamily: 'Phosphor');
  static const bedtime = IconData(0xe58e, fontFamily: 'Phosphor');
  static const bloodtypeOutlined = IconData(0xe210, fontFamily: 'Phosphor');
  static const blurOnOutlined = IconData(0xe190, fontFamily: 'Phosphor');
  static const bolt = IconData(0xe2de, fontFamily: 'Phosphor');
  static const brightness1Outlined = IconData(0xe18a, fontFamily: 'Phosphor');
  static const brightness2Outlined = IconData(0xe18c, fontFamily: 'Phosphor');
  static const brightness3 = IconData(0xe18e, fontFamily: 'Phosphor');
  static const brightness4 = IconData(0xe474, fontFamily: 'Phosphor');
  static const calendarMonth = IconData(0xe10a, fontFamily: 'PhosphorFill');
  static const calendarMonthOutlined = IconData(0xe10a, fontFamily: 'Phosphor');
  static const cancel = IconData(0xe4f8, fontFamily: 'Phosphor');
  static const cardGiftcard = IconData(0xe276, fontFamily: 'Phosphor');
  static const casino = IconData(0xe1ee, fontFamily: 'Phosphor');
  static const castle = IconData(0xe9d0, fontFamily: 'Phosphor');
  static const check = IconData(0xe182, fontFamily: 'Phosphor');
  static const checkCircle = IconData(0xe184, fontFamily: 'PhosphorFill');
  static const checkCircleRounded = IconData(0xe184, fontFamily: 'Phosphor');
  static const chevronLeft = IconData(0xe138, fontFamily: 'Phosphor');
  static const chevronRight = IconData(0xe13a, fontFamily: 'Phosphor');
  static const circleOutlined = IconData(0xe18a, fontFamily: 'Phosphor');
  static const close = IconData(0xe4f6, fontFamily: 'Phosphor');
  static const cloudDone = IconData(0xe1b0, fontFamily: 'Phosphor');
  static const cloudOff = IconData(0xe1b6, fontFamily: 'Phosphor');
  static const collectionsBookmark = IconData(0xe758, fontFamily: 'Phosphor');
  static const darkMode = IconData(0xe330, fontFamily: 'PhosphorFill');
  static const darkModeOutlined = IconData(0xe330, fontFamily: 'Phosphor');
  static const delete = IconData(0xe4a6, fontFamily: 'PhosphorFill');
  static const deleteOutline = IconData(0xe4a6, fontFamily: 'Phosphor');
  static const diamond = IconData(0xe1ec, fontFamily: 'Phosphor');
  static const doNotDisturbAltOutlined = IconData(0xe32c, fontFamily: 'Phosphor');
  static const doubleArrow = IconData(0xe098, fontFamily: 'Phosphor');
  static const downloadRounded = IconData(0xe20c, fontFamily: 'Phosphor');
  static const edit = IconData(0xe3b4, fontFamily: 'Phosphor');
  static const emojiEvents = IconData(0xe67e, fontFamily: 'Phosphor');
  static const expandMore = IconData(0xe136, fontFamily: 'Phosphor');
  static const explore = IconData(0xe1c8, fontFamily: 'Phosphor');
  static const favorite = IconData(0xe2a8, fontFamily: 'Phosphor');
  static const flag = IconData(0xe244, fontFamily: 'Phosphor');
  static const flare = IconData(0xe6a2, fontFamily: 'Phosphor');
  static const formatQuoteOutlined = IconData(0xe660, fontFamily: 'Phosphor');
  static const gMobiledata = IconData(0xe144, fontFamily: 'Phosphor');
  static const gpsFixed = IconData(0xe1d6, fontFamily: 'Phosphor');
  static const history = IconData(0xe1a0, fontFamily: 'Phosphor');
  static const hourglassSimple = IconData(0xe2ba, fontFamily: 'Phosphor');
  static const home = IconData(0xe2c2, fontFamily: 'PhosphorFill');
  static const homeOutlined = IconData(0xe2c2, fontFamily: 'Phosphor');
  static const infoOutline = IconData(0xe2ce, fontFamily: 'Phosphor');
  static const inventory2Outlined = IconData(0xe390, fontFamily: 'Phosphor');
  static const lightMode = IconData(0xe472, fontFamily: 'PhosphorFill');
  static const lightbulb = IconData(0xe2dc, fontFamily: 'Phosphor');
  static const localFireDepartment = IconData(0xe242, fontFamily: 'Phosphor');
  static const locationCity = IconData(0xe102, fontFamily: 'Phosphor');
  static const locationOff = IconData(0xe318, fontFamily: 'Phosphor');
  static const locationOn = IconData(0xe316, fontFamily: 'Phosphor');
  static const lock = IconData(0xe2fa, fontFamily: 'PhosphorFill');
  static const lockClock = IconData(0xe2fe, fontFamily: 'Phosphor');
  static const lockOutline = IconData(0xe2fa, fontFamily: 'Phosphor');
  static const logout = IconData(0xe42a, fontFamily: 'Phosphor');
  static const mapOutlined = IconData(0xe31a, fontFamily: 'Phosphor');
  static const menuBook = IconData(0xe0e6, fontFamily: 'PhosphorFill');
  static const menuBookOutlined = IconData(0xe0e6, fontFamily: 'Phosphor');
  static const militaryTech = IconData(0xecfc, fontFamily: 'Phosphor');
  static const mosque = IconData(0xecee, fontFamily: 'PhosphorFill');
  static const mosqueOutlined = IconData(0xecee, fontFamily: 'Phosphor');
  static const myLocation = IconData(0xe1d6, fontFamily: 'Phosphor');
  static const nightlight = IconData(0xe58e, fontFamily: 'Phosphor');
  static const nightsStay = IconData(0xe58e, fontFamily: 'Phosphor');
  static const notificationsActive = IconData(0xe5e8, fontFamily: 'PhosphorFill');
  static const notificationsActiveOutlined = IconData(0xe5e8, fontFamily: 'Phosphor');
  static const notificationsNoneRounded = IconData(0xe0ce, fontFamily: 'Phosphor');
  static const notificationsOutlined = IconData(0xe0ce, fontFamily: 'Phosphor');
  static const notificationsRounded = IconData(0xe0ce, fontFamily: 'Phosphor');
  static const paletteOutlined = IconData(0xe6c8, fontFamily: 'Phosphor');
  static const person = IconData(0xe4c2, fontFamily: 'PhosphorFill');
  static const personOutline = IconData(0xe4c2, fontFamily: 'Phosphor');
  static const phoneAndroid = IconData(0xe1e0, fontFamily: 'Phosphor');
  static const photoLibrary = IconData(0xe836, fontFamily: 'Phosphor');
  static const playCircleOutline = IconData(0xe3d2, fontFamily: 'Phosphor');
  static const powerSettingsNew = IconData(0xe3da, fontFamily: 'Phosphor');
  static const psychology = IconData(0xe74e, fontFamily: 'Phosphor');
  static const quiz = IconData(0xe3e8, fontFamily: 'Phosphor');
  static const radioButtonChecked = IconData(0xeb08, fontFamily: 'Phosphor');
  static const radioButtonCheckedRounded = IconData(0xeb08, fontFamily: 'Phosphor');
  static const radioButtonOff = IconData(0xe18a, fontFamily: 'Phosphor');
  static const radioButtonOffRounded = IconData(0xe18a, fontFamily: 'Phosphor');
  static const radioButtonUnchecked = IconData(0xe18a, fontFamily: 'Phosphor');
  static const refresh = IconData(0xe094, fontFamily: 'Phosphor');
  static const replay = IconData(0xe038, fontFamily: 'Phosphor');
  static const restartAlt = IconData(0xe038, fontFamily: 'Phosphor');
  static const schedule = IconData(0xe19a, fontFamily: 'PhosphorFill');
  static const scheduleOutlined = IconData(0xe19a, fontFamily: 'Phosphor');
  static const school = IconData(0xe62c, fontFamily: 'Phosphor');
  static const search = IconData(0xe30c, fontFamily: 'Phosphor');
  static const security = IconData(0xe40c, fontFamily: 'Phosphor');
  static const selfImprovement = IconData(0xecc8, fontFamily: 'Phosphor');
  static const send = IconData(0xe396, fontFamily: 'Phosphor');
  static const settings = IconData(0xe270, fontFamily: 'PhosphorFill');
  static const settingsOutlined = IconData(0xe270, fontFamily: 'Phosphor');
  static const share = IconData(0xe408, fontFamily: 'Phosphor');
  static const shield = IconData(0xe40a, fontFamily: 'PhosphorFill');
  static const shieldMoon = IconData(0xec34, fontFamily: 'Phosphor');
  static const shieldOutlined = IconData(0xe40a, fontFamily: 'Phosphor');
  static const smartphone = IconData(0xe1e0, fontFamily: 'Phosphor');
  static const spaOutlined = IconData(0xe6cc, fontFamily: 'Phosphor');
  static const star = IconData(0xe46a, fontFamily: 'Phosphor');
  static const stars = IconData(0xe6a4, fontFamily: 'Phosphor');
  static const sunDim = IconData(0xe474, fontFamily: 'Phosphor');
  static const timer = IconData(0xe492, fontFamily: 'Phosphor');
  static const touchApp = IconData(0xec90, fontFamily: 'Phosphor');
  static const trackChanges = IconData(0xe47c, fontFamily: 'Phosphor');
  static const trendingUp = IconData(0xe4ae, fontFamily: 'Phosphor');
  static const verified = IconData(0xe606, fontFamily: 'PhosphorFill');
  static const verifiedUser = IconData(0xe606, fontFamily: 'Phosphor');
  static const vibration = IconData(0xe4d8, fontFamily: 'Phosphor');
  static const volumeOffRounded = IconData(0xe45a, fontFamily: 'Phosphor');
  static const volumeUp = IconData(0xe44a, fontFamily: 'Phosphor');
  static const volumeUpRounded = IconData(0xe44a, fontFamily: 'Phosphor');
  static const volunteerActivism = IconData(0xe810, fontFamily: 'Phosphor');
  static const warningAmber = IconData(0xe4e0, fontFamily: 'Phosphor');
  static const warningAmberRounded = IconData(0xe4e0, fontFamily: 'Phosphor');
  static const waterDrop = IconData(0xe210, fontFamily: 'Phosphor');
  static const wbCloudy = IconData(0xe1aa, fontFamily: 'Phosphor');
  static const wbSunny = IconData(0xe472, fontFamily: 'Phosphor');
  static const wbTwilight = IconData(0xe5b6, fontFamily: 'Phosphor');
  static const whatshot = IconData(0xe242, fontFamily: 'Phosphor');
  static const wifiOff = IconData(0xe4f2, fontFamily: 'Phosphor');
  static const workspacePremium = IconData(0xe320, fontFamily: 'PhosphorFill');
  static const workspacePremiumOutlined = IconData(0xe320, fontFamily: 'Phosphor');
}
