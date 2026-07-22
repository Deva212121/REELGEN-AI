import 'package:flutter/material.dart';

class MarketingLandingScreen extends StatelessWidget {
  const MarketingLandingScreen({super.key});

  static const _background = Color(0xFF0B0718);
  static const _surface = Color(0xFF181329);
  static const _primary = Color(0xFFC4FF62);
  static const _purple = Color(0xFFD0BCFF);

  void _openLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: _background.withValues(alpha: 0.96),
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 72,
              title: const _Brand(),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton(
                    onPressed: () => _openLogin(context),
                    child: const Text('Sign in'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: FilledButton(
                    onPressed: () => _openLogin(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Get early access'),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _Hero(onStart: () => _openLogin(context)),
                  const _TrustStrip(),
                  const _FeatureSection(),
                  const _RoleSection(),
                  const _HowItWorks(),
                  _CtaSection(onStart: () => _openLogin(context)),
                  const _Footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: const LinearGradient(
              colors: [Color(0xFFD0BCFF), Color(0xFFFF4B8A)],
            ),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 10),
        const Text(
          'SelloreAI',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .2),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 82, 24, 76),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(.72, -.3),
          radius: 1.15,
          colors: [Color(0x55381E72), Color(0x000B0718)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final copy = Column(
                crossAxisAlignment: compact
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  const _Pill(label: 'EARLY ACCESS Ã¢â‚¬Â¢ BUILT FOR INDIA'),
                  const SizedBox(height: 24),
                  Text(
                    'Create. Promote.\nTrack. Grow.',
                    textAlign: compact ? TextAlign.center : TextAlign.left,
                    style: TextStyle(
                      fontSize: compact ? 50 : 72,
                      height: .98,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'One AI-powered business workspace for creators, influencers, vendors and growing commerce teams.',
                    textAlign: compact ? TextAlign.center : TextAlign.left,
                    style: const TextStyle(
                      color: Color(0xFFC9C3D6),
                      fontSize: 19,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    alignment:
                        compact ? WrapAlignment.center : WrapAlignment.start,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: onStart,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Start with SelloreAI'),
                        style: FilledButton.styleFrom(
                          backgroundColor: MarketingLandingScreen._primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 18),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: onStart,
                        icon: const Icon(Icons.login),
                        label: const Text('Open dashboard'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No public payment required during early access.',
                    style: TextStyle(color: Color(0xFF938F99), fontSize: 13),
                  ),
                ],
              );
              final visual = const _HeroVisual();
              if (compact) {
                return Column(
                    children: [copy, const SizedBox(height: 48), visual]);
              }
              return Row(
                children: [
                  Expanded(flex: 6, child: copy),
                  const SizedBox(width: 54),
                  Expanded(flex: 4, child: visual),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MarketingLandingScreen._surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF3E3652)),
        boxShadow: const [BoxShadow(color: Color(0x44FF4B8A), blurRadius: 60)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Business command center',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              _Pill(label: 'LIVE'),
            ],
          ),
          const SizedBox(height: 28),
          const _Metric(
              label: 'Products ready',
              value: '128',
              icon: Icons.inventory_2_outlined),
          const SizedBox(height: 12),
          const _Metric(
              label: 'Creator reach', value: '42.8K', icon: Icons.trending_up),
          const SizedBox(height: 12),
          const _Metric(
              label: 'Orders tracked',
              value: '1,240',
              icon: Icons.local_shipping_outlined),
          const SizedBox(height: 22),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFC4FF62),
                  Color(0xFFFF4B8A),
                  Color(0xFFD0BCFF)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252033),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: MarketingLandingScreen._primary),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: Color(0xFFB9B2C6)))),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();
  @override
  Widget build(BuildContext context) {
    return const _Section(
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 30,
        runSpacing: 20,
        children: [
          _Trust(icon: Icons.auto_awesome, text: 'AI content workflows'),
          _Trust(icon: Icons.storefront_outlined, text: 'Product catalog'),
          _Trust(icon: Icons.groups_outlined, text: 'Influencer selling'),
          _Trust(icon: Icons.analytics_outlined, text: 'Business tracking'),
        ],
      ),
    );
  }
}

class _Trust extends StatelessWidget {
  const _Trust({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: MarketingLandingScreen._purple),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      );
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection();
  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Everything your business needs to move faster',
      subtitle: 'Replace scattered tools with one connected operating system.',
      child: _CardGrid(
        cards: [
          _InfoCard(
              icon: Icons.movie_filter_outlined,
              title: 'Create with AI',
              body:
                  'Plan reels, scripts and promotion content from one focused workspace.'),
          _InfoCard(
              icon: Icons.inventory_2_outlined,
              title: 'Manage catalog',
              body:
                  'Organize products, prices, stock, commission and delivery details.'),
          _InfoCard(
              icon: Icons.campaign_outlined,
              title: 'Activate creators',
              body:
                  'Help influencers discover products and build trackable promotions.'),
          _InfoCard(
              icon: Icons.monitor_heart_outlined,
              title: 'Track growth',
              body:
                  'Follow reach, orders, inventory and performance across your business.'),
        ],
      ),
    );
  }
}

class _RoleSection extends StatelessWidget {
  const _RoleSection();
  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'One platform. Multiple growth roles.',
      child: _CardGrid(
        cards: [
          _InfoCard(
              icon: Icons.movie_creation_outlined,
              title: 'For influencers',
              body:
                  'Find products, activate promotions and manage your selling pipeline.'),
          _InfoCard(
              icon: Icons.factory_outlined,
              title: 'For vendors',
              body:
                  'List products, manage inventory and collaborate with a creator network.'),
          _InfoCard(
              icon: Icons.admin_panel_settings_outlined,
              title: 'For business teams',
              body:
                  'Control operations, reports, settings and partner performance.'),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();
  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Start growing in three steps',
      child: _CardGrid(
        cards: [
          _InfoCard(
              icon: Icons.person_add_alt_1,
              title: '1. Choose your role',
              body: 'Enter the workspace built for how you sell and operate.'),
          _InfoCard(
              icon: Icons.add_business,
              title: '2. Build your catalog',
              body: 'Add products and prepare them for creator-led promotion.'),
          _InfoCard(
              icon: Icons.rocket_launch_outlined,
              title: '3. Launch and learn',
              body: 'Promote, track results and improve what works.'),
        ],
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection({required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    return _Section(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 54),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
              colors: [Color(0xFF381E72), Color(0xFF6D2148)]),
        ),
        child: Column(
          children: [
            const Text('Ready to build your growth engine?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const Text('Join SelloreAI early access today.',
                style: TextStyle(color: Color(0xFFE4DDED), fontSize: 17)),
            const SizedBox(height: 26),
            FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                  backgroundColor: MarketingLandingScreen._primary,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 18)),
              child: const Text('Open SelloreAI'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({this.title, this.subtitle, required this.child});
  final String? title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 58),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            children: [
              if (title != null)
                Text(title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 34, fontWeight: FontWeight.w900)),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(subtitle!,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Color(0xFFAAA3B5), fontSize: 17))
              ],
              if (title != null) const SizedBox(height: 36),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.cards});
  final List<Widget> cards;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth >= 900
          ? (constraints.maxWidth - 36) / 3
          : constraints.maxWidth >= 600
              ? (constraints.maxWidth - 18) / 2
              : constraints.maxWidth;
      return Wrap(
          spacing: 18,
          runSpacing: 18,
          children: cards
              .map((card) => SizedBox(width: width, child: card))
              .toList());
    });
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: MarketingLandingScreen._surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF352E45))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFF2A2042),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: MarketingLandingScreen._primary)),
        const SizedBox(height: 22),
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text(body,
            style: const TextStyle(color: Color(0xFFB9B2C6), height: 1.5)),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
            color: const Color(0x3320D96B),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF4ED67A))),
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFFC4FF62),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
      );
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      color: const Color(0xFF07040B),
      child: const Center(
        child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 26,
            runSpacing: 12,
            children: [
              _Brand(),
              Text('Early Access', style: TextStyle(color: Color(0xFFAAA3B5))),
              Text('Privacy & Terms coming before public release',
                  style: TextStyle(color: Color(0xFFAAA3B5))),
            ]),
      ),
    );
  }
}
