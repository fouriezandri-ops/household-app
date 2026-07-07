import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/admin_todo/presentation/screens/admin_item_detail_screen.dart';
import '../../features/admin_todo/presentation/screens/admin_todo_screen.dart';
import '../../features/grocery_list/presentation/screens/grocery_list_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/household/presentation/providers/current_member_provider.dart';
import '../../features/household/presentation/screens/pick_member_screen.dart';
import '../../features/packing_list/presentation/screens/packing_trip_detail_screen.dart';
import '../../features/packing_list/presentation/screens/packing_trips_screen.dart';
import '../../features/products_to_buy/presentation/screens/products_to_buy_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

/// Bridges Riverpod state changes into a [Listenable] go_router can use as
/// its `refreshListenable`, so picking a household member re-runs
/// `redirect` without needing a manual `context.go` call from that screen.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

/// Kept alive for the app's lifetime — recreating the router on every
/// provider rebuild would drop the current navigation stack.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final refreshNotifier = _GoRouterRefreshNotifier();
  ref.listen(currentMemberControllerProvider, (_, _) => refreshNotifier.refresh());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/pick-member',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final memberAsync = ref.read(currentMemberControllerProvider);
      if (!memberAsync.hasValue) return null; // still loading from secure storage
      final selectedMemberUid = memberAsync.value;
      final isGoingToPickMember = state.matchedLocation == '/pick-member';

      if (selectedMemberUid == null) {
        return isGoingToPickMember ? null : '/pick-member';
      }
      if (isGoingToPickMember) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/pick-member', builder: (context, state) => const PickMemberScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'grocery',
                    builder: (context, state) => const GroceryListScreen(),
                  ),
                  GoRoute(
                    path: 'packing',
                    builder: (context, state) => const PackingTripsScreen(),
                    routes: [
                      GoRoute(
                        path: ':tripId',
                        builder: (context, state) => PackingTripDetailScreen(
                          tripId: state.pathParameters['tripId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'admin',
                    builder: (context, state) => const AdminTodoScreen(),
                    routes: [
                      GoRoute(
                        path: ':itemId',
                        builder: (context, state) => AdminItemDetailScreen(
                          itemId: state.pathParameters['itemId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'products',
                    builder: (context, state) => const ProductsToBuyScreen(),
                  ),
                  GoRoute(
                    path: 'wishlist',
                    builder: (context, state) => const WishlistScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
            ],
          ),
        ],
      ),
    ],
  );
}
