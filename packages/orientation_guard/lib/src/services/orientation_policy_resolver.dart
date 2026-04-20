import 'package:flutter/widgets.dart';
import 'package:orientation_guard/src/models/orientation_models.dart';

/// Base class for resolving orientation policies based on custom models.
///
/// This allows features to define their own business rules for orientation
/// without making the [OrientationGuard] aware of those models.
abstract class OrientationPolicyResolver<T> {
  /// Creates a new [OrientationPolicyResolver].
  const OrientationPolicyResolver();

  /// Resolves the effective [OrientationPolicy] for the given [model].
  OrientationPolicy resolve(BuildContext context, T model);
}
