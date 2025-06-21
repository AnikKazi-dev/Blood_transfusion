import 'package:flutter/material.dart';

import '../services/bloodtype_commpatibilty_service.dart';
import '../utils/blood_product_enum.dart';

class BloodTypeCompatibilityWidget extends StatelessWidget {
  final String recieverBloodType;
  final String bloodPackBloodType;
  final String productType;
  const BloodTypeCompatibilityWidget({
    required this.recieverBloodType,
    required this.bloodPackBloodType,
    required this.productType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isCompatible = checkIfBloodTypesAreCompatible(
        BloodProductTypes.fromValue(int.parse(productType))!,
        bloodPackBloodType,
        recieverBloodType);

    return !isCompatible
        ? SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.red.shade50,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.error_outline,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                        "Achtung! Unabhängig vom Datenvergleich wurde eine Blutgruppenunverträglichkeit zwischen Blutkonserve und Patient festgestellt. Bitte überprüfen Sie das vor Transfusion!"),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
