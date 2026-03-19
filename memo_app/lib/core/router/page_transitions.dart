import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for the app
abstract class PageTransitions {
  /// Slide from right transition (default for push navigation)
  static CustomTransitionPage<T> slideFromRight<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        );
      },
    );
  }

  /// Slide from bottom transition (for modal-style pages)
  static CustomTransitionPage<T> slideFromBottom<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        );
      },
    );
  }

  /// Fade transition
  static CustomTransitionPage<T> fade<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            Tween<double>(begin: 0, end: 1).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Fade and scale transition (for detail pages)
  static CustomTransitionPage<T> fadeScale<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            Tween<double>(begin: 0, end: 1).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          ),
          child: ScaleTransition(
            scale: animation.drive(
              Tween<double>(begin: 0.95, end: 1).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// No transition (instant)
  static CustomTransitionPage<T> none<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
