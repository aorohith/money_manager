double getDropDownHeight(List<String> list, [double defaultHeight = 250]) {
  var yearListLength = list.length;
  return yearListLength > 5 ? defaultHeight : yearListLength * 41;
}
