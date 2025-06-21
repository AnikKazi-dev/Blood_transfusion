enum BloodProductTypes {
  erythrozyt("Erythrozytenkonzentrat", 1),
  thrombozyt("Thrombozytenkonzentrat", 2),
  plasma("Plasmakonzentrat", 5);

  final String label;
  final int value;

  const BloodProductTypes(this.label, this.value);

  static BloodProductTypes? fromValue(int value) {
    try {
      return BloodProductTypes.values
          .firstWhere((element) => element.value == value);
    } catch (e) {
      return null;
    }
  }
}
