import 'package:flutter/material.dart';
import 'package:randki/models/place.dart';
import 'package:randki/models/category_tags_enums.dart';
import 'package:provider/provider.dart';
import 'package:randki/view_models/favorite_places_view_model.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Widget to display a place notice card
class PlaceNotice extends StatelessWidget {
  final Place place;
  final double screenWidth;

  const PlaceNotice({
    super.key,
    required this.place,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 400;
    final addressText = place.address.split(',').first;
    final textPainter = TextPainter(
      text: TextSpan(
        text: addressText,
        style: TextStyle(
          fontSize: 10 * textScale,
          fontFamily: 'Mplus1p',
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final addressWidth = textPainter.width; // szerokość w pikselach

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: screenWidth,
        height: 144,
        child: Stack(
          children: [
            place.profilePicture.isNotEmpty
                ? Image.network(
                  place.profilePicture,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Image error: $error');
                    debugPrint('$stackTrace');
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    );
                  },
                )
                : Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80, // wysokość gradientu
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromRGBO(16, 20, 94, 1),
                      // Color.fromRGBO(16, 20, 94, 0),
                      Color.fromRGBO(16, 20, 94, 0.95),
                      Color.fromRGBO(16, 20, 94, 0.8),
                      Color.fromRGBO(16, 20, 94, 0.4),
                      Color.fromRGBO(16, 20, 94, 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Consumer<FavoritePlacesViewModel>(
                builder: (context, favVM, _) {
                  final isFav = favVM.isFavorite(place.id);
                  return SizedBox(
                    height: 25,
                    width: 25,
                    child: FloatingActionButton(
                      heroTag: null, // wyłącz hero animację dla serduszka
                      onPressed: () {
                        favVM.toggleFavorite(place.id, place: place);
                      },
                      shape: const CircleBorder(),
                      mini: true,
                      backgroundColor: isFav ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_outline,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 17,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 11,
              bottom: 10,
              right: 11,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 135 * textScale, //screenWidth < 380 ? 125 : 135,
                        height: 27,
                        child: Text(
                          place.name,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize:
                                18 * textScale, //screenWidth < 300 ? 15 : 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 160 * textScale,
                        height: 16,
                        child: Row(
                          children: [
                            SizedBox(
                              width: place.distance == null ? (addressWidth + 8).clamp(10, 140) : (addressWidth + 8).clamp(10, 90),
                              height: 16,
                              child: Text(
                                place.address.split(',').first,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 10 * textScale,
                                  //fontWeight: FontWeight.w300,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                            //dystans do miejsca
                            if (place.distance != null)
                              Row(
                                children: [
                                  Icon(
                                   Symbols.distance,
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    size: 16 * textScale,
                                  ),
                                  SizedBox(
                                    width: (140 - ((addressWidth + 8).clamp(10, 90))) * textScale,
                                    height: 16,
                                    child: Text(
                                      place.distance! > 1000
                                          ? '${(place.distance! / 1000).toStringAsFixed(1)} km'
                                          : '${place.distance!.toStringAsFixed(0)} m',
                                      style: TextStyle(
                                        fontFamily: 'Mplus1p',
                                        fontSize: 10 * textScale,
                                        //fontWeight: FontWeight.w300,
                                        color: Theme.of(context).colorScheme.onSecondary,
                                      ),
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 0,
                                right: 5,
                                top: 0,
                                bottom: 0,
                              ),
                              child: Icon(
                                Icons.local_cafe_outlined,
                                color: Theme.of(context).colorScheme.onSecondary,
                                size: 16 * textScale,
                              ),
                            ),
                            Text(
                              getCategoryName(context, place.category),
                              style: TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 10 * textScale,
                                //fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 0,
                                right: 5,
                                top: 0,
                                bottom: 0,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Theme.of(context).colorScheme.onSecondary,
                                size: 16 * textScale,
                              ),
                            ),
                            Text(
                              '${place.pricepp?.$1} - ${place.pricepp?.$2} zł',
                              style: TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 10 * textScale,
                                //fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
