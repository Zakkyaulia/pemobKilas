---
name: Kilas Civic Pulse
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#434656'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#737687'
  outline-variant: '#c3c5d9'
  surface-tint: '#004fe5'
  primary: '#0048d4'
  on-primary: '#ffffff'
  primary-container: '#1e60ff'
  on-primary-container: '#f2f2ff'
  inverse-primary: '#b6c4ff'
  secondary: '#006a61'
  on-secondary: '#ffffff'
  secondary-container: '#86f2e4'
  on-secondary-container: '#006f66'
  tertiary: '#7a4c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#9c6200'
  on-tertiary-container: '#fff1e4'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b6c4ff'
  on-primary-fixed: '#00164f'
  on-primary-fixed-variant: '#003bb0'
  secondary-fixed: '#89f5e7'
  secondary-fixed-dim: '#6bd8cb'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#005049'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
  canvas-base: '#F8FAFC'
  surface-subtle: '#F1F5F9'
  surface-pure: '#FFFFFF'
  status-facility: '#EF4444'
  status-condition: '#F59E0B'
  status-announcement: '#1E60FF'
  status-resolved: '#10B981'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system embodies a fast-paced, youth-driven civic utility for the Universitas Andalas student body. The emotional tone is energetic, accountable, transparent, and effortlessly modern—distancing itself from bureaucratic campus administration portals. The interface feels light, reactive, and crisp, optimizing for immediate physical context (GPS accuracy, camera captures, on-site problem reporting) without cognitive overhead.

The aesthetic blends **Modern Minimalism** with **Selective Glassmorphism** and a **Gen-Z Neo-Utility** feel:
- **Clean Spatial Whitespace**: Ample breathing room prioritizing visual media reports over dense copy.
- **Electric Accents**: Purpose-built high-contrast royal blue driving interactive focal points, statuses, and spatial actions.
- **Physical Clues & Friendly Softness**: Deep pill geometry, pill badges, and soft tinted elevations that make mobile touch targets feel tangible, responsive, and tactile without turning skeuomorphic.

## Colors

The palette revolves around an electric, saturated royal blue (`#1E60FF`), communicating dynamic civic energy and clear navigation. Neutrals rely on an ultra-clean cool slate spectrum (`#F8FAFC` to `#0F172A`) to preserve high visual contrast under direct daylight outdoors across the campus hills.

### Role Assignments
- **Primary (`#1E60FF`)**: Primary action triggers (CTA buttons, FAB submission, active tab indicators, location pins, and upvote states).
- **Secondary (`#0D9488`)**: Environmental and green space metrics, verified campus responses, and administrative clearance confirmations.
- **Tertiary (`#F59E0B`)**: Alert milestones, real-time warnings, pending progress statuses, and hotspot thresholds.
- **Neutral (`#64748B`)**: Structural secondary text, subtle divider lines, map controls, and neutral inactive pill chips.

### Named Color Logic
- `canvas-base` (`#F8FAFC`): Default device background providing high contrast against card containers.
- `surface-subtle` (`#F1F5F9`): Inset containers, search bars, input backgrounds, and media capture slots.
- `surface-pure` (`#FFFFFF`): Elevated report cards, sheets, and interactive overlays.
- Status category colors (`#EF4444`, `#F59E0B`, `#1E60FF`, `#10B981`) categorize incident types (*Fasilitas Rusak*, *Kondisi Kampus*, *Informasi Penting*, and *Selesai*) strictly for instantaneous feed scanning.

## Typography

Typography relies uniformly on **Plus Jakarta Sans** across all levels. Its geometric proportions, wide aperture, and clean modern terminals deliver peak legibility on variable-density mobile displays while projecting a crisp, friendly visual personality suited for university students.

- **Display & Headlines**: Bold, punchy weights (`700` and `800`) with tight letter spacing ensure that incident titles and geo-tags punch through on map views and social card timelines.
- **Body Hierarchy**: Standard body text (`body-md` at 14px/20px) balances content density and readability for incident descriptions and operational timestamps.
- **Labels & Pills**: Upper-level weights (`600` and `700`) paired with subtle positive letter spacing maintain legibility in dense contexts such as status tags, category markers, and upvote counters.

## Layout & Spacing

The layout is architected with a strict **mobile-first** approach, optimizing for one-handed thumb interaction during outdoor campus inspections.

- **Grid Model**: A fluid 4-column system on mobile expanding to 8 columns on tablet viewports.
- **Horizontal Screen Padding**: Defaults to `1rem` (16px) on mobile for edge-to-edge efficiency, opening to `1.5rem` (24px) on wider tablet viewports.
- **Safe Area Insets**: Floating action buttons (FABs), bottom navigation sheets, and quick-shutter controls must observe explicit bottom safe-area insets (`+ 1rem`) to prevent gesture collisions.
- **Component Vertical Rhythm**: A consistent 8pt incremental scale (`0.25rem`, `0.5rem`, `1rem`, `1.5rem`, `2rem`) dictates inner container padding and media-to-text separation.

## Elevation & Depth

Visual hierarchy uses a refined combination of **chromatic ambient shadows** and **frosted glass surfaces**:

- **Layer 0 (Canvas)**: Non-elevated, flat `#F8FAFC` base screen background.
- **Layer 1 (Card Surfaces)**: `#FFFFFF` report cards and feed items utilize a soft, high-diffusion ambient shadow: `0px 4px 20px -2px rgba(15, 23, 42, 0.05)`, combined with a 1px border colored `rgba(226, 232, 240, 0.8)` for sharp structural definition.
- **Layer 2 (Floating Action & Overlays)**: The primary report camera button and interactive map controls feature an energetic tinted blue elevation: `0px 8px 24px -4px rgba(30, 96, 255, 0.35)`.
- **Layer 3 (Glassmorphism & Modals)**: Bottom app bars, floating category filters, and geolocation badges use translucent frosted acrylic: `background: rgba(255, 255, 255, 0.85)`, backed by a `16px` backdrop-filter blur and subtle top highlight line (`1px solid rgba(255, 255, 255, 0.6)`).

## Shapes

The design system implements a soft, modern geometry dominated by pronounced corner curves that echo contemporary mobile UI trends:

- **Standard Cards & Containers**: `1rem` (16px, `rounded-2xl`) radius for standard feed cards, image previews, and modal sheets.
- **Interactive Focal Elements**: `1.5rem` (24px, `rounded-3xl`) for large bottom sheets, multi-step incident forms, and floating photo preview canvases.
- **Tags, Inputs, & Action Pills**: Full-bleed pill radius (`9999px`) for category chips, upvote toggle pills, search inputs, and primary action buttons.

## Components

### Buttons
- **Primary Button**: Solid `#1E60FF` fill, `#FFFFFF` text, `9999px` full pill radius, minimum height of `48px` to facilitate thumb reach. Includes subtle blue drop shadow (`0 4px 14px rgba(30, 96, 255, 0.3)`).
- **Secondary / Ghost Button**: Translucent background (`#F1F5F9` or `rgba(30, 96, 255, 0.08)`), `#1E60FF` text, no heavy borders.
- **Floating Action Button (Report Incident)**: Centered or lower-right circular/pill trigger with high-contrast icon (`+`), utilizing the electric primary elevation shadow.

### Chips & Status Badges
- **Status Pills**: Compact height (`24px` to `28px`), `9999px` pill radius, paired with a saturated status dot (`6px`). 
- **Active Filter Chips**: Solid `#1E60FF` with white text.
- **Inactive Filter Chips**: `#FFFFFF` with `#64748B` label and subtle `1px` border (`#E2E8F0`).

### Incident Cards
- Encased in pure white `#FFFFFF`, `16px` corner radius, `12px` or `16px` internal padding.
- Media elements take top-priority placement with `12px` inner border radius.
- Metadata footer arranges Upvote Count (`pill` with interactive counter), Location Pin (`body-sm` with truncated facility name), and timestamp in a single baseline scan line.

### Input Fields & Media Uploaders
- **Text Inputs**: Inset fill `#F1F5F9`, zero border in default state, transitioning to a crisp `2px solid #1E60FF` border on active focus.
- **Photo Upload Slot**: Dashed border (`1.5px dashed #CBD5E1`), rounded corners (`16px`), centered camera glyph with prompt label in `label-md`.

### Interactive Hotspot Map Elements
- **Location Marker**: Teardrop icon housing dynamic incident glyphs; pulsing radial aura (`rgba(30, 96, 255, 0.2)`) indicating user location accuracy.
- **Attribution & Floating Controls**: Floating rounded pill at the bottom edge accommodating the compulsory `© OpenStreetMap contributors` text with micro-translucent backdrop styling.

code html:
<!DOCTYPE html><html lang="id" style=""><head><meta charset="utf-8"><meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" name="viewport"><meta content="mobile_tab" name="shell-type"><link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&amp;display=swap" rel="stylesheet"><link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"><style>@layer base{html,body{width:100vw;margin:0;padding:0;background-color:#f8f9ff;}body{overscroll-behavior:none;}.pb-safe{padding-bottom:env(safe-area-inset-bottom,0px);}.pt-safe{padding-top:env(safe-area-inset-top,0px);}main>:first-child{margin-top:0!important;}main>:last-child{margin-bottom:0!important;}}::-webkit-scrollbar{display:none;}</style><script src="https://cdn.tailwindcss.com"></script><script id="tailwind-config">tailwind.config = { darkMode: 'class', theme: { extend: { colors: { 'surface-variant': '#d3e4fe', 'surface-container-high': '#dce9ff', 'surface-dim': '#cbdbf5', 'surface-container': '#e5eeff', 'on-surface': '#0b1c30', 'tertiary-fixed': '#ffddb8', 'on-secondary': '#ffffff', 'on-secondary-fixed-variant': '#005049', 'outline-variant': '#c3c5d9', 'status-announcement': '#1E60FF', 'on-tertiary-container': '#fff1e4', 'secondary-fixed-dim': '#6bd8cb', 'canvas-base': '#F8FAFC', 'surface-pure': '#FFFFFF', 'inverse-surface': '#213145', 'on-error-container': '#93000a', 'surface-container-highest': '#d3e4fe', 'surface-subtle': '#F1F5F9', 'on-tertiary-fixed': '#2a1700', 'on-secondary-container': '#006f66', 'on-primary-container': '#f2f2ff', 'on-primary-fixed': '#00164f', 'error': '#ba1a1a', 'inverse-primary': '#b6c4ff', 'surface': '#f8f9ff', 'status-condition': '#F59E0B', 'tertiary-fixed-dim': '#ffb95f', 'on-tertiary-fixed-variant': '#653e00', 'status-facility': '#EF4444', 'outline': '#737687', 'surface-container-low': '#eff4ff', 'on-tertiary': '#ffffff', 'primary-fixed': '#dce1ff', 'secondary': '#006a61', 'surface-container-lowest': '#ffffff', 'tertiary': '#7a4c00', 'surface-bright': '#f8f9ff', 'secondary-fixed': '#89f5e7', 'tertiary-container': '#9c6200', 'on-background': '#0b1c30', 'primary': '#0048d4', 'secondary-container': '#86f2e4', 'on-surface-variant': '#434656', 'primary-fixed-dim': '#b6c4ff', 'status-resolved': '#10B981', 'inverse-on-surface': '#eaf1ff', 'background': '#f8f9ff', 'on-primary': '#ffffff', 'on-primary-fixed-variant': '#003bb0', 'error-container': '#ffdad6', 'on-secondary-fixed': '#00201d', 'surface-tint': '#004fe5', 'on-error': '#ffffff', 'primary-container': '#1e60ff' }, borderRadius: { 'DEFAULT': '0.25rem', 'lg': '0.5rem', 'xl': '0.75rem', 'full': '9999px' }, spacing: { 'margin': '1rem', 'margin-tablet': '1.5rem', 'space-lg': '1.5rem', 'space-xl': '2rem', 'space-sm': '0.5rem', 'space-xs': '0.25rem', 'space-md': '1rem', 'gutter': '1rem' }, fontFamily: { 'headline-lg': ['Plus Jakarta Sans'], 'display-lg': ['Plus Jakarta Sans'], 'body-sm': ['Plus Jakarta Sans'], 'label-lg': ['Plus Jakarta Sans'], 'label-sm': ['Plus Jakarta Sans'], 'body-md': ['Plus Jakarta Sans'], 'headline-md': ['Plus Jakarta Sans'], 'body-lg': ['Plus Jakarta Sans'], 'label-md': ['Plus Jakarta Sans'], 'headline-sm': ['Plus Jakarta Sans'] }, fontSize: { 'headline-lg': ['24px', { lineHeight: '32px', letterSpacing: '-0.02em', fontWeight: '700' }], 'display-lg': ['32px', { lineHeight: '40px', letterSpacing: '-0.03em', fontWeight: '800' }], 'body-sm': ['12px', { lineHeight: '16px', fontWeight: '400' }], 'label-lg': ['14px', { lineHeight: '20px', letterSpacing: '0.01em', fontWeight: '600' }], 'label-sm': ['10px', { lineHeight: '14px', letterSpacing: '0.04em', fontWeight: '700' }], 'body-md': ['14px', { lineHeight: '20px', fontWeight: '400' }], 'headline-md': ['20px', { lineHeight: '28px', letterSpacing: '-0.015em', fontWeight: '700' }], 'body-lg': ['16px', { lineHeight: '24px', fontWeight: '400' }], 'label-md': ['12px', { lineHeight: '16px', letterSpacing: '0.02em', fontWeight: '600' }], 'headline-sm': ['18px', { lineHeight: '24px', fontWeight: '600' }] } } } };</script><style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head><body class="bg-surface font-body-md text-on-surface antialiased flex flex-col min-h-screen"><header class="fixed top-0 w-full z-50 pt-safe bg-surface-pure/85 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)]"><div class="h-16 px-4 flex items-center justify-between gap-2 border-b border-surface-container"><div class="flex items-center gap-2.5 min-w-0"><img alt="KILAS Logo" class="h-8 w-auto object-contain flex-shrink-0" src="https://lh3.googleusercontent.com/aida/AEtjO1V5x6XcYLkVRl7VhJTw6lNACmLYMohVB-_AysCYDqamhrlZr3yOby6xHiE2hETw3sjOJhLod-avEzKVoZyS5vbuopWFLcRfxB5_y-v_HuZPky55aSQfYYodgcjRwdiNbK8w_7MUmfsDfTH9rmxsbLwV_fCSmUjGKWVZKMeN7ggYAFhtRznTa4ZvEqmUMRL0G3evbmUr9jxvSs1UZUF_cr_xduW51yt29OAZJ2pkwQn5sQAxzKY5BxkJOs0"><div class="flex flex-col min-w-0 justify-center"><div class="flex items-center gap-1"><span class="font-headline-sm text-headline-sm text-on-surface tracking-tight leading-none">KILAS</span><span class="font-label-sm text-label-sm px-1.5 py-0.5 rounded-full bg-surface-container-high text-primary font-bold">UNAND</span></div><span class="font-label-sm text-label-sm text-on-surface-variant truncate leading-none mt-0.5">Halo Mahasiswa, Pantau Kampus</span></div></div><div class="flex items-center gap-1 flex-shrink-0"><a aria-label="Cari &amp; Filter Kategori" class="w-10 h-10 flex items-center justify-center rounded-full text-on-surface hover:bg-surface-subtle transition-colors" data-path="cari-laporan" href="#"><span class="material-symbols-outlined text-[24px]">search</span></a></div></div></header><main class="flex-1 w-full bg-surface pt-16 pb-28"><div class="flex flex-col w-full bg-surface-pure"><div class="flex items-center justify-center py-2 gap-1.5 opacity-60 bg-surface border-b border-surface-container"><span class="material-symbols-outlined text-[16px] text-primary animate-bounce">south</span><span class="font-label-sm text-label-sm text-on-surface-variant tracking-wider uppercase">Tarik untuk memuat baru</span></div><div class="flex flex-col w-full divide-y divide-surface-container"><article class="w-full p-4 flex flex-col gap-3 hover:bg-surface-subtle/30 transition-colors active:bg-surface-subtle/50 cursor-pointer" onclick="window.location.hash='#detail-post-1'"><div class="flex items-start justify-between gap-2"><div class="flex items-center gap-2.5 min-w-0"><div class="w-10 h-10 rounded-full bg-surface-variant flex items-center justify-center text-primary font-bold text-label-md flex-shrink-0">ZA</div><div class="flex flex-col min-w-0"><div class="flex items-center gap-1.5"><span class="font-headline-sm text-headline-sm text-on-surface text-[15px] truncate font-bold">Zakky Aldrin</span><span class="font-label-sm text-label-sm text-on-surface-variant truncate">@zakkyaldrin</span></div><div class="flex items-center gap-1 text-on-surface-variant"><span class="material-symbols-outlined text-[13px] text-primary">location_on</span><span class="font-body-sm text-body-sm truncate">Gedung GKB C, Lantai 2 • 15m lalu</span></div></div></div><div class="flex-shrink-0 px-2.5 py-1 rounded-full bg-tertiary-fixed text-on-tertiary-fixed-variant flex items-center gap-1"><span class="w-1.5 h-1.5 rounded-full bg-status-condition"></span><span class="font-label-sm text-label-sm font-bold">Kondisi Kampus</span></div></div><div class="flex flex-col gap-1"><h2 class="font-headline-sm text-headline-sm text-on-surface leading-snug font-bold">AC Ruang Kuliah GKB C 204 bocor &amp; tidak dingin</h2><p class="font-body-md text-body-md text-on-surface-variant leading-relaxed line-clamp-2 overflow-hidden text-ellipsis">Air menetes deras tepat di deretan bangku tengah. Suasana kelas sangat gerah saat kuliah statistika berlangsung, sehingga beberapa baris kursi tidak dapat ditempati mahasiswa...</p></div><div class="relative w-full h-56 rounded-xl overflow-hidden bg-surface-subtle shadow-inner"><img alt="AC Rusak GKB C" class="w-full h-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCQjRXiN2w4dCPIVQhWlufSduDBSOqq2UCDygQfUyfqSojlTedSVb-jV0eQv01FkURvr7Qgez_9haHqOHRzyrTMm3-zTxvYqLoT_9pOnwvzbpXntLaJrl15dn9w9LqHV6h_Q-VTAArbnGCIPrkLxKjPYJlR_v1VSLY4KUOIjrOZXQlOZdLstSB2MYxJK3RiWV-7pjLLrSMmfoav9T6019ykOx4WMX3P7hAfHAQKUCS_DHnrVSu8_buT"></div><div class="flex items-center justify-between pt-1" onclick="event.stopPropagation()"><div class="flex items-center gap-3"><button class="group flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-primary-container text-on-primary font-label-md text-label-md shadow-sm transition-all active:scale-95" data-count="42" onclick="toggleUpvote(this)" type="button"><span class="material-symbols-outlined text-[16px] font-bold">arrow_upward</span><span class="count-display font-bold">▲ 42</span></button></div><div class="flex items-center gap-1"><button aria-label="Simpan Laporan" class="w-9 h-9 flex items-center justify-center rounded-full text-on-surface-variant hover:bg-surface-subtle active:scale-90 transition-all" onclick="toggleBookmark(this)" type="button"><span class="material-symbols-outlined text-[20px]">bookmark</span></button><button aria-label="Bagikan Laporan" class="w-9 h-9 flex items-center justify-center rounded-full text-on-surface-variant hover:bg-surface-subtle active:scale-90 transition-all" onclick="shareHumas('GKB C 204')" type="button"><span class="material-symbols-outlined text-[20px]">send</span></button></div></div></article><article class="w-full p-4 flex flex-col gap-3 hover:bg-surface-subtle/30 transition-colors active:bg-surface-subtle/50 cursor-pointer" onclick="window.location.hash='#detail-post-2'"><div class="flex items-start justify-between gap-2"><div class="flex items-center gap-2.5 min-w-0"><div class="w-10 h-10 rounded-full bg-secondary-container flex items-center justify-center text-on-secondary-container font-bold text-label-md flex-shrink-0">AH</div><div class="flex flex-col min-w-0"><div class="flex items-center gap-1.5"><span class="font-headline-sm text-headline-sm text-on-surface text-[15px] truncate font-bold">Aziz Hakim</span><span class="font-label-sm text-label-sm text-on-surface-variant truncate">@aziz_hakim</span></div><div class="flex items-center gap-1 text-on-surface-variant"><span class="material-symbols-outlined text-[13px] text-status-condition">location_on</span><span class="font-body-sm text-body-sm truncate">Bundaran PKM UNAND • 1 jam lalu</span></div></div></div><div class="flex-shrink-0 px-2.5 py-1 rounded-full bg-tertiary-fixed text-on-tertiary-fixed-variant flex items-center gap-1"><span class="w-1.5 h-1.5 rounded-full bg-status-condition"></span><span class="font-label-sm text-label-sm font-bold">Kondisi Kampus</span></div></div><div class="flex flex-col gap-1"><h2 class="font-headline-sm text-headline-sm text-on-surface leading-snug font-bold">Genangan air hujan &amp; dahan patah menutup bahu jalan PKM</h2><p class="font-body-md text-body-md text-on-surface-variant leading-relaxed line-clamp-2 overflow-hidden text-ellipsis">Pengendara motor harap pelan-pelan saat melintas dari arah gerbang utama menuju gedung kegiatan mahasiswa karena jalan licin dan ranting pohon berhamburan...</p></div><div class="relative w-full h-52 rounded-xl overflow-hidden bg-surface-subtle shadow-inner"><img alt="Jalan PKM UNAND" class="w-full h-full object-cover" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCh051Xy-xSPGUBXughAzyxvFCY8F_VsQmhDKBKpmVdKsTq5YdmlMKYGzGxc3cwpg2fC4gu5aHhImH4s6--pDRRzEdF6TuTNm89AinPn6UwPbeZkOobIT8DlUgAvdtKpsBo1yWT9c5OfNWMbQufHfEWLFkcK5FoVJpYapGXFC9YSEx0H06v1c8ayEl60Ip2kEne1PDSjakNj0oLwzr7n8KBFOtC_GIPiLzftS2S72nkUya3Nk08RIfh"></div><div class="flex items-center justify-between pt-1" onclick="event.stopPropagation()"><div class="flex items-center gap-3"><button class="group flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-surface-subtle text-on-surface-variant hover:text-primary font-label-md text-label-md transition-all active:scale-95" data-count="28" onclick="toggleUpvote(this)" type="button"><span class="material-symbols-outlined text-[16px]">arrow_upward</span><span class="count-display font-semibold">▲ 28</span></button></div><div class="flex items-center gap-1"><button aria-label="Simpan Laporan" class="w-9 h-9 flex items-center justify-center rounded-full text-on-surface-variant hover:bg-surface-subtle active:scale-90 transition-all" onclick="toggleBookmark(this)" type="button"><span class="material-symbols-outlined text-[20px]">bookmark</span></button><button aria-label="Bagikan Laporan" class="w-9 h-9 flex items-center justify-center rounded-full text-on-surface-variant hover:bg-surface-subtle active:scale-90 transition-all" onclick="shareHumas('Bundaran PKM')" type="button"><span class="material-symbols-outlined text-[20px]">send</span></button></div></div></article><article class="w-full p-4 flex flex-col gap-3 hover:bg-surface-subtle/30 transition-colors active:bg-surface-subtle/50 cursor-pointer" onclick="window.location.hash='#detail-post-3'"><div class="flex items-start justify-between gap-2"><div class="flex items-center gap-2.5 min-w-0"><div class="w-10 h-10 rounded-full bg-surface-container-high flex items-center justify-center text-primary font-bold text-label-md flex-shrink-0"><span class="material-symbols-outlined text-[20px]">verified</span></div><div class="flex flex-col min-w-0"><div class="flex items-center gap-1"><span class="font-headline-sm text-headline-sm text-on-surface text-[15px] truncate font-bold">Biro Umum UNAND</span><span class="material-symbols-outlined text-[15px] text-primary" style="font-variation-settings: 'FILL' 1;">check_circle</span></div><div class="flex items-center gap-1 text-on-surface-variant"><span class="material-symbols-outlined text-[13px] text-primary">schedule</span><span class="font-body-sm text-body-sm truncate">Gedung Rektorat • 2 jam lalu</span></div></div></div><div class="flex-shrink-0 px-2.5 py-1 rounded-full bg-surface-container-high text-primary flex items-center gap-1"><span class="material-symbols-outlined text-[14px]">campaign</span><span class="font-label-sm text-label-sm font-bold">Info Penting</span></div></div><div class="bg-surface-container-low p-3.5 rounded-xl flex items-start gap-3 border border-surface-container"><div class="w-10 h-10 rounded-full bg-surface-pure flex items-center justify-center text-primary flex-shrink-0 shadow-sm"><span class="material-symbols-outlined text-[22px]">elevator</span></div><div class="flex flex-col min-w-0"><h3 class="font-headline-sm text-headline-sm text-on-surface text-[15px] font-bold">Maintenance Lift Gedung Rektorat Sayap Kanan</h3><p class="font-body-md text-body-md text-on-surface-variant mt-0.5 leading-relaxed line-clamp-2 overflow-hidden text-ellipsis">Pemeriksaan berkala kabel suspensi hingga pukul 16:00 WIB. Akses dialihkan ke tangga darurat dan lift sayap kiri untuk keselamatan operasional...</p></div></div><div class="flex items-center justify-between pt-1" onclick="event.stopPropagation()"><div class="flex items-center gap-3"><button class="group flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-surface-subtle text-on-surface-variant hover:text-primary font-label-md text-label-md transition-all active:scale-95" data-count="15" onclick="toggleUpvote(this)" type="button"><span class="material-symbols-outlined text-[16px]">arrow_upward</span><span class="count-display font-semibold">▲ 15</span></button></div><div class="flex items-center gap-1"><button aria-label="Simpan Laporan" class="w-9 h-9 flex items-center justify-center rounded-full text-on-surface-variant hover:bg-surface-subtle active:scale-90 transition-all" onclick="toggleBookmark(this)" type="button"><span class="material-symbols-outlined text-[20px]">bookmark</span></button><button aria-label="Bagikan Laporan" class="w-9 h-9 flex items-center justify-center rounded-full text-on-surface-variant hover:bg-surface-subtle active:scale-90 transition-all" onclick="shareHumas('Rektorat')" type="button"><span class="material-symbols-outlined text-[20px]">send</span></button></div></div></article></div><div class="fixed bottom-20 left-1/2 -translate-x-1/2 z-50 bg-inverse-surface text-inverse-on-surface px-4 py-2.5 rounded-full font-label-md text-label-md shadow-xl flex items-center gap-2 opacity-0 pointer-events-none transition-all duration-200" id="toast"><span class="material-symbols-outlined text-[18px] text-status-resolved">check_circle</span><span id="toast-message" class="">Tautan disalin ke clipboard</span></div></div></main><nav class="fixed bottom-0 w-full z-50 pb-safe bg-surface-pure/90 backdrop-blur-xl shadow-[0_-4px_20px_rgba(15,23,42,0.06)]" data-active-classes="text-primary-container font-bold"><div class="relative flex justify-around items-center h-16 px-space-xs"><a aria-current="page" class="flex flex-col items-center justify-center flex-1 h-full py-1 transition-all select-none text-primary-container font-bold" data-path="beranda" href="#"><span class="material-symbols-outlined text-[24px]">home</span><span class="font-label-sm text-label-sm mt-0.5 text-primary font-bold">Beranda</span></a><a class="flex flex-col items-center justify-center flex-1 h-full py-1 text-on-surface-variant transition-all select-none" data-path="peta-hotspot" href="#"><span class="material-symbols-outlined text-[24px]">map</span><span class="font-label-sm text-label-sm mt-0.5">Peta</span></a><div class="flex flex-col items-center justify-center flex-1"><a aria-label="Buat Laporan Baru" class="-top-5 relative w-14 h-14 rounded-full bg-primary-container text-on-primary flex items-center justify-center shadow-[0_8px_24px_-4px_rgba(30,96,255,0.45)] active:scale-95 transition-all" data-path="buat-laporan" href="#"><span class="material-symbols-outlined text-[28px] font-bold">add</span></a></div><a class="flex flex-col items-center justify-center flex-1 h-full py-1 text-on-surface-variant transition-all select-none relative" data-path="notifikasi" href="#"><div class="relative"><span class="material-symbols-outlined text-[24px]">notifications</span><span class="absolute top-0 right-0 w-2 h-2 rounded-full bg-status-facility ring-1 ring-surface-pure"></span></div><span class="font-label-sm text-label-sm mt-0.5">Notif</span></a><a class="flex flex-col items-center justify-center flex-1 h-full py-1 text-on-surface-variant transition-all select-none" data-path="profil" href="#"><img src="https://lh3.googleusercontent.com/aida/AEtjO1V92EVQ4KN0Kz3oky3ZOjOFB36uMErkEeLAHNV9VFiNR4xHvqrU9y0IB6mb3iqoNJ7swFKmS8DJgKYBhUgFghvxzqoDcWA-tD8zi4vI_JKMI7HK8V7NKtPZM80iTjo6MyY1UFw6KP_73ds3DU6H-yxPWgQ4EA9QnC5J6vKVOODwssgoJO6s-U4JOiunlGU-RGUKB_8Mh_9roo5zd4SLPhhNl7Ky0TQaHz58_z9QyCB75uw1XHJR0hI7plY" alt="Foto Profil Akun" class="w-6 h-6 rounded-full object-cover"><span class="font-label-sm text-label-sm mt-0.5">Akun</span></a></div></nav>







</body></html>