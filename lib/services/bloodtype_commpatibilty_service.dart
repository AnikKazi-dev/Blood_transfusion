import 'package:secureblood/utils/blood_product_enum.dart';

bool checkIfBloodTypesAreCompatible(BloodProductTypes productType,
    String bloodpackBloodType, String patientBloodType) {
  patientBloodType = patientBloodType.toLowerCase();
  bloodpackBloodType = bloodpackBloodType.toLowerCase();

  if (productType == BloodProductTypes.erythrozyt ||
      productType == BloodProductTypes.thrombozyt) {
    switch (bloodpackBloodType) {
      case "0":
        return patientBloodType == "0" ||
            patientBloodType == "a" ||
            patientBloodType == "b" ||
            patientBloodType == "ab";
      case "a":
        return patientBloodType == "a" || patientBloodType == "ab";
      case "b":
        return patientBloodType == "b" || patientBloodType == "ab";
      case "ab":
        return patientBloodType == "ab";
      default:
        return false;
    }
  } else if (productType == BloodProductTypes.plasma) {
    switch (bloodpackBloodType) {
      case "0":
        return patientBloodType == "0";
      case "a":
        return patientBloodType == "0" || patientBloodType == "a";
      case "b":
        return patientBloodType == "0" || patientBloodType == "b";
      case "ab":
        return patientBloodType == "0" ||
            patientBloodType == "a" ||
            patientBloodType == "b" ||
            patientBloodType == "ab";
      default:
        return false;
    }
  }
  return false;
}
