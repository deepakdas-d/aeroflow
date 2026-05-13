import 'package:aeroflow/ui/interaction_lock.dart';
import 'package:flutter/material.dart';

import 'widgets/top_bar.dart';
import 'widgets/turbine_card.dart';
import 'widgets/stability_gauge.dart';
import 'widgets/event_log.dart';
import 'widgets/power_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;

                if (w >= 900) return const _WideLayout();
                if (w >= 600) return const _MediumLayout();

                return const _NarrowLayout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WIDE LAYOUT
// ─────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ValueListenableBuilder<bool>(
              valueListenable: isInteractingNotifier,
              builder: (_, interacting, _) {
                return ListView.separated(
                  physics: interacting
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),

                  itemCount: 6,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => TurbineCard(index: i),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 260,
            child: Column(
              children: const [
                SizedBox(height: 200, child: StabilityGauge()),
                SizedBox(height: 10),
                Expanded(flex: 2, child: PowerChart()),
                SizedBox(height: 10),
                Expanded(flex: 3, child: EventLog()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MEDIUM LAYOUT
// ─────────────────────────────────────────────────────────────

class _MediumLayout extends StatelessWidget {
  const _MediumLayout();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isInteractingNotifier,
      builder: (_, interacting, _) {
        return SingleChildScrollView(
          physics: interacting
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),

          padding: const EdgeInsets.all(12),

          child: Column(
            children: [
              for (int row = 0; row < 3; row++) ...[
                if (row > 0) const SizedBox(height: 10),

                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: TurbineCard(index: row * 2)),

                      const SizedBox(width: 10),

                      Expanded(child: TurbineCard(index: row * 2 + 1)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              SizedBox(
                height: 220,
                child: Row(
                  children: const [
                    Expanded(child: StabilityGauge()),
                    SizedBox(width: 10),
                    Expanded(child: PowerChart()),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 280, child: EventLog()),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NARROW LAYOUT
// ─────────────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isInteractingNotifier,
      builder: (_, interacting, _) {
        return ListView(
          physics: interacting
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),

          padding: const EdgeInsets.all(12),

          children: [
            for (int i = 0; i < 6; i++) ...[
              if (i > 0) const SizedBox(height: 10),

              TurbineCard(index: i),
            ],

            const SizedBox(height: 12),

            const SizedBox(height: 200, child: StabilityGauge()),

            const SizedBox(height: 10),

            const SizedBox(height: 220, child: PowerChart()),

            const SizedBox(height: 10),

            const SizedBox(height: 260, child: EventLog()),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
