# Quick Uninstaller: নিকট-মেয়াদি ফিচার ও ড্রয়ার ডিজাইন বিশ্লেষণ

## ১. ডকুমেন্টের উদ্দেশ্য

এই ডকুমেন্টে বর্তমান কোডবেস ও Android native integration পর্যালোচনা করে এমন কিছু বাস্তবসম্মত ফিচার ও navigation drawer-এর নকশা প্রস্তাব করা হয়েছে, যেগুলো ছোট থেকে মাঝারি পরিসরের কাজের মধ্যে বাস্তবায়ন করা সম্ভব। লক্ষ্য হলো অ্যাপটিকে তার মূল পরিচয়—দ্রুত, হালকা ও নিরাপদ app uninstaller—অক্ষুণ্ণ রেখে আরও ব্যবহারযোগ্য করা।

এই প্রস্তাবে বড় ধরনের cloud account, device-to-device sync, antivirus, root-only silent uninstall, অপ্রয়োজনীয় social feature বা জটিল subscription system রাখা হয়নি।

---

## ২. বর্তমান প্রজেক্টের সারসংক্ষেপ

Quick Uninstaller বর্তমানে Flutter-ভিত্তিক, Android-কেন্দ্রিক একটি app manager। Flutter UI-এর সঙ্গে `MethodChannel` ব্যবহার করে Kotlin native layer যুক্ত করা হয়েছে।

### বর্তমানে কার্যকর মূল সুবিধা

- User app এবং system app আলাদা tab-এ দেখানো
- App name দিয়ে search
- নাম, APK size ও install date অনুযায়ী ascending/descending sort
- Long press করে একাধিক user app নির্বাচন
- নির্বাচিত app-গুলো ধারাবাহিকভাবে uninstall করার flow
- Single app uninstall
- App launch
- Android App Info/Details screen খোলা
- Google Play listing খোলা
- Home-screen shortcut তৈরির অনুরোধ
- App icon lazy-load এবং native memory cache
- App uninstall হলে broadcast শুনে list update
- Device-এর মোট ও খালি internal storage দেখানো
- সর্বশেষ sort preference local cache-এ রাখা
- Dark Material 3 visual foundation

### বর্তমান architecture

- Feature-based folder structure
- Presenter + immutable UI state
- Repository/use-case/data-source separation
- Dependency injection (`get_it`)
- Android-specific operation-এর জন্য একটি native MethodChannel
- Firebase dependencies ও কিছু shared service উপস্থিত, যদিও core uninstall UI-তে সেগুলোর দৃশ্যমান ব্যবহার সীমিত

### গুরুত্বপূর্ণ বর্তমান সীমাবদ্ধতা

1. App entry point সরাসরি `UninstallerPage` দেখায়। `MainPage` বর্তমানে ব্যবহার হয় না।
2. `MainPage`-এর Home, Tracker, Events ও Audio destination একই `UninstallerPage` দেখায়; Settings-ও পূর্ণভাবে wired নয়। এগুলো এই অ্যাপের domain-এর সঙ্গেও সামঞ্জস্যপূর্ণ নয়।
3. Home ও Onboarding page placeholder অবস্থায় আছে।
4. UI string সরাসরি widget/state-এ hard-coded; বাংলা/ইংরেজি localization এখনও কার্যকর নয়।
5. Search শুধু app name-এ কাজ করে; package name-এ নয়।
6. প্রদর্শিত app size মূলত base APK file-এর size; app data, cache, split APK বা মোট installed footprint নয়। UI-তে এটিকে total storage usage হিসেবে বোঝালে বিভ্রান্তি হতে পারে।
7. System app tab মূলত তথ্য ও action-এর জন্য; সাধারণ Android device-এ system app uninstall করা যায় না।
8. Uninstall করতে Android-এর system confirmation প্রতিটি app-এর জন্য আসবে। Root/device-owner ছাড়া সত্যিকারের silent bulk uninstall বাস্তবসম্মত নয়।
9. Refresh করলে storage পুনরায় load হচ্ছে না; বর্তমান flow-তে app list refresh এবং memory refresh আলাদা lifecycle-এ রয়েছে।
10. App চালু করা বা Play Store খোলার মতো action ব্যর্থ হলে বেশিরভাগ ক্ষেত্রে user-facing কারণ দেখানো হয় না।

---

## ৩. Product direction

অ্যাপটির সবচেয়ে উপযোগী positioning হবে:

> “Installed apps দ্রুত খুঁজুন, অপ্রয়োজনীয় app শনাক্ত করুন এবং নিরাপদভাবে এক বা একাধিক app uninstall করুন।”

এই positioning অনুযায়ী app list-ই primary screen থাকবে। Drawer হবে secondary navigation এবং settings/information hub। Bottom navigation এই single-purpose utility app-এর জন্য প্রয়োজনীয় নয়।

### প্রস্তাবিত navigation model

- Primary screen: All Apps / Uninstaller
- Primary in-context actions: Search, filter, sort, selection, uninstall
- Drawer destinations: Uninstaller, Recently Installed, Large Apps, Settings, Help, Privacy Policy, About
- App-specific actions: বর্তমান bottom sheet-এই থাকবে

এতে user-এর মূল কাজ এক tap দূরেই থাকবে এবং drawer অপ্রয়োজনীয়ভাবে app action duplicate করবে না।

---

## ৪. নিকট-মেয়াদি ফিচার প্রস্তাব

## P0 — প্রথম রিলিজেই করা উচিত

### ৪.১ Filter system

বর্তমান sort bottom sheet-এর পাশাপাশি একটি Filter bottom sheet যোগ করা যায়।

প্রস্তাবিত filter:

- User apps / System apps — বর্তমান tab বজায় রাখা যেতে পারে
- Installed in: Last 7 days, Last 30 days, Any time
- Size: Under 50 MB, 50–200 MB, Over 200 MB
- Launchable apps only
- Search query: app name অথবা package name

প্রথম iteration-এ multi-filter state local memory-তে রাখা যথেষ্ট। পরে “Remember filters” setting যোগ করা যেতে পারে। Active filter থাকলে app bar-এর filter icon-এ badge/dot দেখানো উচিত।

**কেন বাস্তবসম্মত:** বর্তমান entity-তে install date, app size, system flag ও package name ইতিমধ্যে আছে। নতুন permission ছাড়াই অধিকাংশ filtering সম্ভব।

### ৪.২ Search উন্নত করা

- App name-এর পাশাপাশি package name search
- Search field খোলার সময় autofocus
- Search result count
- “No apps found” state-এ Clear search button
- Search text trim করা; বর্তমান search UI খোলার জন্য single-space query ব্যবহারের পরিবর্তে আলাদা `isSearchVisible` state রাখা

**উপকার:** power user package ID দিয়ে app খুঁজতে পারবে এবং search state আরও পরিষ্কার হবে।

### ৪.৩ Uninstall selection summary ও নিরাপত্তা

Uninstall শুরু করার আগে একটি confirmation sheet দেখানো উচিত:

- নির্বাচিত app সংখ্যা
- app-গুলোর নামের সংক্ষিপ্ত তালিকা
- নির্বাচিত APK size-এর মোট যোগফল
- স্পষ্ট বার্তা: Android প্রতিটি app-এর জন্য confirmation চাইতে পারে
- Primary action: `Start uninstall`
- Secondary action: `Cancel`

Uninstall শেষে summary:

- সফলভাবে সরানো হয়েছে কতটি
- cancel/failed কতটি
- `Done` এবং প্রয়োজনে `Retry remaining`

**সতর্কতা:** “X MB space will be freed” নিশ্চিত ভাষায় বলা যাবে না, কারণ বর্তমান size কেবল APK-এর আনুমানিক size। “Selected APK size” বা “Approx. app package size” লেখা নিরাপদ।

### ৪.৪ Empty, error ও action feedback state

আলাদা state প্রয়োজন:

- কোনো user app নেই
- কোনো system app নেই
- search/filter-এ ফল নেই
- app list load ব্যর্থ
- launch intent নেই
- Play Store/browser খোলা যায়নি
- app details খোলা যায়নি
- shortcut unsupported/failed
- uninstall cancel হয়েছে

প্রতিটি recoverable error-এ `Retry` বা সংশ্লিষ্ট action থাকা উচিত। Silent catch কমিয়ে presenter থেকে user-friendly message পাঠানো উচিত।

### ৪.৫ Refresh আচরণ ঠিক করা

Refresh action একসঙ্গে নিচের কাজ করবে:

- User app reload
- System app cache invalidate/reload
- Storage info reload
- Search/filter/selection reset করা হবে কি না—এটি consistent policy দ্বারা নির্ধারিত হবে; প্রস্তাব হলো selection clear, কিন্তু search/filter বজায় রাখা
- Refresh চলাকালে icon disable বা ছোট progress indicator

### ৪.৬ Localization foundation

প্রথমে সব hard-coded UI string `lib/l10n/app_en.arb` এবং `lib/l10n/app_bn.arb`-এ স্থানান্তর করা উচিত। Minimum language:

- English
- বাংলা

Settings-এ language option:

- System default
- English
- বাংলা

Localization যোগ করার পরে project instruction অনুযায়ী `flutter gen-l10n` চালাতে হবে।

### ৪.৭ Drawer ও বর্তমান navigation cleanup

- Root scaffold-এ Material 3 `NavigationDrawer` বা custom Drawer ব্যবহার
- App bar-এ leading hamburger icon
- অপ্রাসঙ্গিক Home/Tracker/Events/Audio bottom destinations বাদ দেওয়া
- `MainPage`-কে নতুন shell হিসেবে ব্যবহার করা অথবা `UninstallerPage`-এর ওপর একটি পরিষ্কার shell তৈরি করা
- Back press behavior: drawer খোলা থাকলে আগে drawer বন্ধ হবে; selection mode থাকলে selection clear হবে; তারপর app exit flow

---

## P1 — P0 স্থিতিশীল হওয়ার পর

### ৪.৮ Recently Installed smart view

আলাদা data source দরকার নেই; বর্তমান `installDate` ব্যবহার করে recent apps দেখানো যায়।

- Default: গত 30 দিনে install হওয়া user apps
- Newest-first sort
- 7 days / 30 days toggle
- এখান থেকেও selection ও uninstall
- Drawer-এ optional count badge

এই view user-কে সদ্য install করা কিন্তু অপ্রয়োজনীয় app দ্রুত খুঁজতে সাহায্য করবে।

### ৪.৯ Large Apps smart view

বর্তমান APK size data ব্যবহার করে largest user apps-এর view:

- Largest-first list
- Quick chips: `> 100 MB`, `> 250 MB`, `> 500 MB`
- Multi-select uninstall
- Size limitation সম্পর্কে info tooltip

**নামকরণ:** “Large APKs” technical হলেও নির্ভুল। Consumer-friendly UI-তে “Large apps” রাখা যায়, তবে info text-এ বলা উচিত size আনুমানিক package size।

### ৪.১০ App details preview

Bottom sheet-এ বর্তমান action list-এর ওপরে/আলাদা details sheet-এ:

- App icon ও name
- Package name
- Version
- Install date
- Approximate APK size
- User/System badge
- Copy package name

এরপর Launch, Android App Info, Play Store ও Uninstall action। “Copy package name” Flutter Clipboard দিয়েই করা সম্ভব।

### ৪.১১ Settings screen

প্রথম version-এর Settings খুব ছোট রাখা উচিত:

**Appearance**

- Theme: System / Dark / Light; বর্তমানে শুধু dark theme আছে, তাই Light theme বাস্তবায়ন ছাড়া option দেখানো উচিত নয়

**Language**

- System / English / বাংলা

**App list**

- Default tab: User apps / System apps
- Remember last tab
- Remember filters
- Show system apps toggle; বন্ধ থাকলে System Apps tab লুকানো যাবে

**Uninstall**

- Always show selection confirmation

Setting persistence-এর জন্য বিদ্যমান local cache service যথেষ্ট হতে পারে।

### ৪.১২ Share app information

বর্তমান `share_plus` dependency ব্যবহার করে app info share করা যায়:

- App name
- Package name
- Play Store URL

এটি per-app bottom sheet action হবে; drawer item নয়।

### ৪.১৩ Accessibility ও UX polish

- Icon button-এ tooltip/semantic label
- Minimum 48×48 tap target
- Text scale বাড়লেও drawer ও app tile overflow না হওয়া
- Selected state শুধু রঙের ওপর নির্ভর না করে check icon/border ব্যবহার
- Error/success রঙের contrast যাচাই
- Reduce motion/system animation preference সম্মান করা
- Loading shimmer-এর পাশাপাশি screen-reader status

---

## P2 — সময় থাকলে, কিন্তু এখনও নিকট-মেয়াদি

### ৪.১৪ Favorites / Keep list

যেসব app user ভুলেও uninstall selection-এ নিতে চায় না, সেগুলো local “Keep list”-এ রাখা:

- App action: `Add to Keep list`
- Keep badge
- Select All করলে protected app বাদ যাবে
- Settings বা drawer থেকে Keep list দেখা

এটি uninstall safety বাড়ায় এবং শুধু package name-এর local set সংরক্ষণ করলেই প্রথম সংস্করণ সম্ভব। “Favorites” অপেক্ষা “Keep list” নামটি উদ্দেশ্য স্পষ্ট করে।

### ৪.১৫ Uninstall history

শুধু app-এর মাধ্যমে সফলভাবে অপসারিত package-এর local history:

- App name
- Package name
- Uninstall date/time
- Play Store-এ পুনরায় খোলার action
- Clear history

**সীমাবদ্ধতা:** এটি device-এর পূর্ণ uninstall history নয়; কেবল Quick Uninstaller session থেকে নিশ্চিত হওয়া event। এই ভাষা UI-তে স্পষ্ট থাকতে হবে।

### ৪.১৬ Storage summary card

Drawer header বা list-এর ওপরে full storage visualization না দিয়ে Uninstaller screen-এ একটি compact expandable summary দেওয়া যেতে পারে:

- Used vs free internal storage
- Linear progress
- Free storage text
- Last refreshed time

Storage card চাপলে Large Apps filter/view খোলা যেতে পারে।

---

## ৫. যেসব ফিচার এখন না করাই ভালো

### Silent one-tap bulk uninstall

সাধারণ Android app system confirmation bypass করতে পারে না। Root বা enterprise device-owner flow ছাড়া এটি promise করা উচিত নয়। বর্তমান sequential uninstall flow-কে “batch-assisted uninstall” হিসেবে ভাবা সঠিক।

### App cache/data পরিষ্কার করা

অন্য app-এর cache/data programmatically পরিষ্কার করা সাধারণ third-party app-এর জন্য সীমাবদ্ধ। ব্যবহারকারীকে Android App Info screen-এ পাঠানোই বাস্তবসম্মত।

### Exact total app storage usage

বর্তমান APK file length, total app + data + cache usage-এর সমান নয়। platform capability নিশ্চিত না করে exact storage reclaimed দেখানো যাবে না।

### RAM booster, antivirus বা battery optimizer

এগুলো core product scope থেকে বিচ্যুত করবে, অতিরিক্ত permission/policy risk তৈরি করবে এবং user trust কমাতে পারে।

### Cloud account ও sync

Keep list/history-এর মতো feature local রাখাই যথেষ্ট। নিকট-মেয়াদে authentication, backend এবং privacy overhead যুক্ত করার যৌক্তিকতা নেই।

---

## ৬. Drawer-এর প্রস্তাবিত information architecture

Drawer-এর প্রস্থ screen width-এর প্রায় 84–88%, সর্বোচ্চ 360 dp। Material 3 shape অনুসারে ডান পাশে 20–24 dp rounded corner ব্যবহার করা যায়।

### Drawer item order

#### Header

- App logo
- `Quick Uninstaller`
- `Fast & simple app manager` / localized subtitle
- Compact storage indicator: `42.6 GB free of 128 GB`

#### Manage

1. **All Apps** — বর্তমান main uninstaller screen
2. **Recently Installed** — P1 smart view
3. **Large Apps** — P1 smart view
4. **Keep List** — কেবল P2 feature বাস্তবায়িত হলে
5. **Uninstall History** — কেবল P2 feature বাস্তবায়িত হলে

#### Preferences

6. **Settings**

#### Support

7. **Help & Tips**
8. **Privacy Policy**
9. **Share Quick Uninstaller**
10. **About**

Drawer footer:

- `Version 1.0.0`

### Progressive disclosure rule

যে screen এখনও বাস্তবায়িত হয়নি সেটি drawer-এ disabled “Coming soon” item হিসেবে রাখা উচিত নয়। শুধু কার্যকর destination দেখাতে হবে। ফলে প্রথম release-এ drawer হতে পারে:

- All Apps
- Settings
- Help & Tips
- Privacy Policy
- Share App
- About

Recently Installed ও Large Apps প্রস্তুত হলে Manage section-এ যোগ হবে।

---

## ৭. Drawer-এর visual design

বর্তমান dark palette-এর সঙ্গে সামঞ্জস্য রেখে:

- Drawer background: `#1A1A1A`
- Header/card surface: `#242424`
- Selected item background: orange accent-এর 12–16% opacity
- Selected icon/text: `#FF9800`
- Primary text: `#E0E0E0`
- Secondary text: `#9E9E9E`
- Divider: `#404040`
- Destructive action drawer-এ না রাখা; uninstall কেবল app context/selection flow-তে থাকবে

### Header layout

- Top safe area + 20 dp horizontal padding
- 52–56 dp app logo
- 16–18 sp semibold title
- 12–13 sp subtitle
- নিচে 6 dp rounded storage progress bar
- Storage bar orange accent; free-space text secondary color

Header অতিরিক্ত লম্বা করা উচিত নয়; 150–180 dp-এর মধ্যে রাখা ভালো যাতে ছোট screen-এ destination-গুলো দৃশ্যমান থাকে।

### Navigation item style

- Item height: 48–52 dp
- Horizontal margin: 12 dp
- Border radius: 12–14 dp
- Leading icon: 22–24 dp
- Icon ও label-এর gap: 16 dp
- Section label: 11–12 sp, uppercase না হলেও চলে; বাংলা localization-এ natural casing
- Selected destination-এ orange vertical indicator অথবা tinted pill—দুটির একটি; একই সঙ্গে দুটো heavy indicator নয়
- Badge কেবল অর্থবহ count থাকলে, যেমন Recently Installed count

### Interaction

- Hamburger চাপলে drawer open
- Drawer item চাপলে drawer আগে close, তারপর destination change
- একই destination চাপলে শুধু drawer close
- System back drawer close করবে
- Scrim opacity প্রায় 45–55%
- Gesture দিয়ে edge swipe open রাখা যায়
- Screen transition subtle fade/short slide; utility app হিসেবে heavy animation নয়

### Text wireframe

```text
┌──────────────────────────────────┐
│  [Logo]  Quick Uninstaller       │
│          Fast & simple manager   │
│                                  │
│  Free storage                    │
│  ███████████░░░  42.6 / 128 GB  │
├──────────────────────────────────┤
│  MANAGE                          │
│  ▌ [Apps]    All Apps            │  ← selected
│    [Clock]   Recently Installed  │
│    [Storage] Large Apps          │
├──────────────────────────────────┤
│  PREFERENCES                     │
│    [Gear]    Settings            │
├──────────────────────────────────┤
│  SUPPORT                         │
│    [?]       Help & Tips         │
│    [Shield]  Privacy Policy      │
│    [Share]   Share App           │
│    [Info]    About               │
│                                  │
│  Version 1.0.0                   │
└──────────────────────────────────┘
```

### App bar পরিবর্তন

বর্তমান delete-sweep icon-এর স্থানে hamburger ব্যবহার করলে brand cue হারাতে পারে। প্রস্তাবিত বিন্যাস:

- Leading: hamburger
- Title block: `Uninstaller` + app count
- Actions: filter, sort, refresh
- Narrow device-এ filter/sort overflow menu-তে নেওয়া যায়
- Selection mode-এ drawer বন্ধ থাকবে; leading close/back, title selected count, trailing Select all

---

## ৮. Screen-by-screen আচরণ

### All Apps

- User/System segmented tab
- Search, filter, sort
- App count
- Storage summary
- Long press selection
- Bottom/floating uninstall action

### Recently Installed

- শুধু user apps
- 7/30 days filter chip
- Newest first default
- একই app tile ও selection component reuse

### Large Apps

- শুধু user apps
- Largest first default
- Size threshold chip
- Approximate size disclaimer
- একই selection/uninstall flow reuse

### Settings

- Language
- Theme (Light theme তৈরি হলে)
- Default/remembered app-list behavior
- Uninstall confirmation preference

### Help & Tips

- Multiple uninstall কীভাবে কাজ করে
- কেন Android প্রতিবার confirmation দেখায়
- System app কেন uninstall হয় না
- প্রদর্শিত size কেন আনুমানিক
- Package visibility ব্যবহারের কারণ

### Privacy Policy

Repository-তে বিদ্যমান privacy policy URL/local asset app-এর ভেতরের web view বা external browser-এ খোলা যায়। External browser ব্যবহার করলে নতুন heavy dependency দরকার নেই।

### About

- App logo/name
- Version/build number (`package_info_plus` ইতিমধ্যে আছে)
- Short description
- Privacy Policy
- Open-source licenses (`showLicensePage`)
- Rate app / Check on Google Play, listing উপলব্ধ হলে

---

## ৯. বাস্তবায়নের প্রস্তাবিত ধাপ

### Phase 1 — Navigation ও foundation

- Root app shell নির্ধারণ
- অপ্রাসঙ্গিক bottom navigation অপসারণ/অব্যবহৃত রাখা নয়
- Drawer component ও All Apps destination
- Settings, Help, Privacy, About basic pages
- Localization foundation
- Hard-coded string migration

### Phase 2 — Core list UX

- Explicit search visibility state
- Name + package search
- Filter state ও bottom sheet
- Empty/error state
- Unified refresh
- Action failure feedback

### Phase 3 — Uninstall safety

- Selection confirmation sheet
- Approximate selected APK size
- Completion summary ও retry remaining
- Cancel/failure state পরিষ্কার করা

### Phase 4 — Smart views

- Recently Installed
- Large Apps
- Shared reusable app-list scaffold

### Phase 5 — Optional local productivity

- Keep List
- Uninstall History
- Share app information

---

## ১০. Architecture recommendation

নতুন destination-এর জন্য একই `UninstallerPage` copy না করে reusable list foundation তৈরি করা ভালো। সম্ভাব্য বিভাজন:

- `AppListScaffold`: app bar, list, selection ও action shell
- `AppQuery`/filter model: tab, search, date range, size range, sort
- `AppCollectionType`: all, recent, large, keepList
- একটিমাত্র installed-app source of truth
- Derived view হিসেবে filtered/sorted list
- Drawer selection state shell presenter/router-এ
- Settings-এর জন্য আলাদা feature/presenter/repository

বর্তমান presenter-এ search, tab, sorting, app loading, icon loading, action এবং uninstall orchestration সব একসঙ্গে আছে। নিকট-মেয়াদি পরিবর্তনে সম্পূর্ণ rewrite দরকার নেই, কিন্তু smart view যোগ করার আগে query/filter logic pure helper বা dedicated model-এ বের করলে duplication কমবে।

Drawer নিজে app data load করবে না। Storage header-এর data shared state/service থেকে পড়বে, যাতে drawer খোলার সময় native query বারবার না চলে।

---

## ১১. Privacy ও Play policy বিবেচনা

- `QUERY_ALL_PACKAGES` app-এর core functionality-এর সঙ্গে সরাসরি সম্পর্কিত রাখতে হবে। Store listing, privacy policy ও in-app explanation একই ভাষায় এই প্রয়োজন ব্যাখ্যা করবে।
- Installed app list অপ্রয়োজনীয়ভাবে Firebase/remote backend-এ পাঠানো উচিত নয়। সব filtering/history local রাখা ভালো।
- Analytics ব্যবহার করলে app/package name event parameter হিসেবে পাঠানো উচিত নয়। Aggregate action count যথেষ্ট।
- Crash report-এ package list বা user-selected package accidentally যুক্ত না হয় তা নিশ্চিত করতে হবে।
- Drawer-এর Help/Privacy section trust-building surface হিসেবে কাজ করবে।

---

## ১২. Manual acceptance checklist

Project policy অনুযায়ী Flutter test file না লিখে নিচের manual scenario যাচাই করা যাবে:

- Cold start-এ All Apps সঠিকভাবে খোলে
- Drawer open/close, scrim tap, swipe ও back behavior ঠিক
- Current destination selected state দৃশ্যমান
- Drawer item থেকে navigation-এর পর drawer বন্ধ হয়
- বাংলা ও English-এ drawer text overflow করে না
- Large text/font scale-এ item usable থাকে
- User/System tab count ঠিক
- App name ও package name search ঠিক
- একাধিক filter একসঙ্গে কাজ করে
- Refresh-এর পরে list ও storage update হয়
- Selection mode-এ drawer/hamburger behavior conflict করে না
- System app select/uninstall করা যায় না
- Batch flow-এ cancel, success ও failure সঠিক summary দেয়
- App uninstall শেষে list/count/storage refresh হয়
- Play Store অনুপস্থিত হলে browser fallback কাজ করে
- Non-launchable app-এ পরিষ্কার feedback আসে
- Offline অবস্থায় local app list কাজ করে
- Privacy Policy ও About page খোলে
- Small screen, gesture navigation ও display cutout-এ layout ঠিক থাকে

---

## ১৩. চূড়ান্ত অগ্রাধিকার

সবচেয়ে বেশি user value এবং সবচেয়ে কম ঝুঁকির ভিত্তিতে পরবর্তী কাজের ক্রম:

1. Navigation cleanup + functional drawer
2. Localization (English/বাংলা)
3. Search by package name + explicit search state
4. Filters
5. Uninstall confirmation ও result summary
6. Empty/error/action feedback
7. Unified refresh ও storage update
8. Recently Installed
9. Large Apps
10. Settings polish
11. Keep List
12. Local Uninstall History

এই roadmap অনুসরণ করলে প্রথম কয়েকটি পরিবর্তনেই অ্যাপটি placeholder navigation থেকে একটি পরিষ্কার, বিশ্বাসযোগ্য ও ব্যবহারযোগ্য utility product-এ পরিণত হবে; একই সঙ্গে পরবর্তী smart view-গুলোর জন্য reusable foundation তৈরি হবে।
