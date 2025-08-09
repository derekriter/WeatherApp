import 'package:flutter/material.dart';
import 'package:weather_app/widgets/shimmer_loading.dart';

class NullableText extends Text {
  const NullableText(
    this.nullableData, {
    required this.referenceData,
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  }) : super(
         nullableData ?? "null",
       ); //null condition is to make the compiler happy, this "null" text will never be displayed

  final String? nullableData;

  ///Text used to determine the size of the widget when [nullableData] is null
  final String referenceData;

  @override
  Widget build(BuildContext context) {
    if (nullableData != null) {
      return super.build(context);
    }

    TextStyle? normal = super.style;
    //taken from Text.build @ ln687
    if (normal == null || normal.inherit) {
      normal = DefaultTextStyle.of(context).style.merge(normal);
    }
    TextStyle invisible = normal.merge(
      TextStyle(
        inherit: true,
        color: Colors.transparent,
        decorationColor: Colors.transparent,
      ),
    );

    Text copy = Text(
      referenceData,
      key: super.key,
      style: invisible,
      strutStyle: super.strutStyle,
      textAlign: super.textAlign,
      textDirection: super.textDirection,
      locale: super.locale,
      softWrap: super.softWrap,
      overflow: super.overflow,
      textScaler: super.textScaler,
      maxLines: super.maxLines,
      semanticsLabel: super.semanticsLabel,
      textWidthBasis: super.textWidthBasis,
      textHeightBehavior: super.textHeightBehavior,
      selectionColor: Colors.transparent,
    );

    //render an invisible copy of the text to determine the size
    //relies on the fact that a container without layout info will size itself to fit the child
    //https://api.flutter.dev/flutter/widgets/Container-class.html#:~:text=otherwise%2C%20the%20widget%20has%20a%20child%20but%20no%20height%2C%20no%20width%2C%20no%20constraints%2C%20and%20no%20alignment%2C%20and%20the%20container%20passes%20the%20constraints%20from%20the%20parent%20to%20the%20child%20and%20sizes%20itself%20to%20match%20the%20child.
    return ShimmerLoading(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: copy,
      ),
    );
  }
}
