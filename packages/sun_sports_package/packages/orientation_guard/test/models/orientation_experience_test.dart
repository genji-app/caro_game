import 'package:flutter_test/flutter_test.dart';
import 'package:orientation_guard/src/models/orientation_experience.dart';

void main() {
  group('OrientationExperienceClassifier', () {
    const classifier = OrientationExperienceClassifier.standard;

    test('classifies mobile experience', () {
      expect(classifier.classifyFromSize(320), OrientationExperience.mobile);
      expect(classifier.classifyFromSize(599), OrientationExperience.mobile);
    });

    test('classifies tablet experience', () {
      expect(classifier.classifyFromSize(600), OrientationExperience.tablet);
      expect(classifier.classifyFromSize(999), OrientationExperience.tablet);
    });

    test('classifies large tablet experience', () {
      expect(classifier.classifyFromSize(1000), OrientationExperience.largeTablet);
      expect(classifier.classifyFromSize(1299), OrientationExperience.largeTablet);
    });

    test('classifies desktop experience', () {
      expect(classifier.classifyFromSize(1300), OrientationExperience.desktop);
      expect(classifier.classifyFromSize(2560), OrientationExperience.desktop);
    });
  });

  group('OrientationExperience properties', () {
    test('canRotate is true for mobile, tablet and largeTablet', () {
      expect(OrientationExperience.mobile.canRotate, isTrue);
      expect(OrientationExperience.tablet.canRotate, isTrue);
      expect(OrientationExperience.largeTablet.canRotate, isTrue);
      expect(OrientationExperience.desktop.canRotate, isFalse);
    });

    test('usesResize is true only for desktop', () {
      expect(OrientationExperience.mobile.usesResize, isFalse);
      expect(OrientationExperience.tablet.usesResize, isFalse);
      expect(OrientationExperience.largeTablet.usesResize, isFalse);
      expect(OrientationExperience.desktop.usesResize, isTrue);
    });
  });
}
