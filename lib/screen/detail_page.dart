import 'package:flutter/material.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/utils/format_date.dart';

class DetailPage extends StatelessWidget{
  final SingleAmiibo amiibo;
  final AmiiboProvider amiiboProvider;

  DetailPage({Key key,
    @required this.amiibo,
    @required this.amiiboProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SingleAmiibo>.value(value: amiibo),
        Provider<AmiiboProvider>.value(value: amiiboProvider)
      ],
      child: SafeArea(
        child: _BottomSheetDetail()
      ),
    );
  }
}

class _BottomSheetDetail extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final AmiiboProvider amiiboProvider = Provider.of<AmiiboProvider>(context, listen: false);
    final AmiiboDB amiibo = Provider.of<SingleAmiibo>(context, listen: false).amiibo;
    final Size size = MediaQuery.of(context).size;
    final S translate = S.of(context);
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    int flex = 4;
    if(size.longestSide >= 800)
      padding = EdgeInsets.symmetric(
          horizontal: (size.width/2 - 250).clamp(0.0, double.infinity)
      );
    if(size.width >= 400) flex = 6;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: padding,
        child: Material(
          type: MaterialType.card,
          shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8))
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: LimitedBox(
              maxHeight: 250,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                            child: Hero(
                              transitionOnUserGestures: true,
                              tag: amiibo.key,
                              child: Image.asset(
                                'assets/collection/icon_${amiibo.key}.png',
                                fit: BoxFit.scaleDown,
                              )
                            ),
                          ),
                          flex: 7,
                        ),
                        Expanded(
                          child: Consumer<SingleAmiibo>(
                            builder: (ctx, amiiboDB, child){
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    child: FittedBox(
                                      child: IconButton(
                                        icon: (amiibo.owned?.isEven ?? true) ?
                                        const Icon(Icons.radio_button_unchecked) : const Icon(iconOwned),
                                        color: colorOwned,
                                        iconSize: 30.0,
                                        tooltip: translate.ownTooltip,
                                        splashColor: colorOwned[100],
                                        onPressed: () {
                                          final int newValue = (amiibo?.owned ?? 0) ^ 1;
                                          amiiboDB.owned = newValue;
                                          amiiboProvider.updateAmiiboDB(amiibo: amiibo);
                                        }
                                    ),
                                    )
                                  ),
                                  Expanded(
                                    child: FittedBox(
                                      child: IconButton(
                                        icon: (amiibo.wishlist?.isEven ?? true) ?
                                        const Icon(Icons.check_box_outline_blank) : const Icon(iconWished),
                                        color: colorWished,
                                        iconSize: 30.0,
                                        tooltip: translate.wishTooltip,
                                        splashColor: Colors.amberAccent[100],
                                        onPressed: () {
                                          final int newValue = (amiibo?.wishlist ?? 0) ^ 1;
                                          amiiboDB.wishlist = newValue;
                                          amiiboProvider.updateAmiiboDB(amiibo: amiibo);
                                        }
                                      )
                                    )
                                  ),
                                ],
                              );
                            }
                          ),
                          flex: 2,
                        ),
                      ],
                    ),
                    flex: flex,
                  ),
                  const VerticalDivider(indent: 10, endIndent: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextCardDetail(text: translate.character(amiibo.character)),
                        if(amiibo.character != amiibo.name) TextCardDetail(text: translate.name(amiibo.name)),
                        TextCardDetail(text: translate.serie(amiibo.amiiboSeries)),
                        if(amiibo.amiiboSeries != amiibo.gameSeries) TextCardDetail(text: translate.game(amiibo.gameSeries)),
                        TextCardDetail(text: translate.types(amiibo.type),),
                        if(amiibo.au != null) RegionDetail(amiibo.au, 'au', translate.au),
                        if(amiibo.eu != null) RegionDetail(amiibo.eu, 'eu', translate.eu),
                        if(amiibo.na != null) RegionDetail(amiibo.na, 'na', translate.na),
                        if(amiibo.jp != null) RegionDetail(amiibo.jp, 'jp', translate.jp),
                      ],
                    ),
                    flex: 7,
                  )
                ],
              ),
            )
          )
        ),
      )
    );
  }
}

class RegionDetail extends StatelessWidget{
  final String asset;
  final String description;
  final FormatDate formatDate;

  RegionDetail(dateString, this.asset, this.description)
    : formatDate = FormatDate(dateString);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/images/$asset.png',
          height: 16, width: 25,
          fit: BoxFit.fill,
          semanticLabel: description,
         ),
        Flexible(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(formatDate.localizedDate(context),
                overflow: TextOverflow.fade,
                softWrap: false,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontWeight: FontWeight.bold
                ),
              )
            ),
          ),
        )
      ],
    );
  }
}

class TextCardDetail extends StatelessWidget{
  final String text;

  TextCardDetail({
    Key key,
    this.text,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      child: Text(text,
        textAlign: TextAlign.start,
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
          fontWeight: FontWeight.bold
        ),
      )
    );
  }
}