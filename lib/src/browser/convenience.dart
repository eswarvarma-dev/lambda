library lambda.browser.convenience;

import 'package:lambda/lambda.dart';
import 'node_type.dart';

Text text(String value) => new Text(TEXT_TYPE.typeIndex, value);
Text comment(String value) => new Text(COMMENT_TYPE.typeIndex, value);

Element div(Map attributes, [
  Node child1,
  Node child2,
  Node child3,
  Node child4,
  Node child5,
  Node child6,
  Node child7,
  Node child8,
  Node child9,
  Node child10]) {
  // TODO: can be made faster without takeWhile and toList
  return _el(
      DIV_TYPE,
      attributes: attributes,
      children: [
        child1,
        child2,
        child3,
        child4,
        child5,
        child6,
        child7,
        child8,
        child9,
        child10
      ].takeWhile((c) => c != null).toList());
}

Element ldiv(Iterable<Node> children) => _el(DIV_TYPE, children: children);

Element tdiv(String txt, [Map<String, String> attributes]) {
  return _el(DIV_TYPE, attributes: attributes, children: [text(txt)]);
}

Element table(Iterable<Node> children) => _el(TABLE_TYPE, children: children);
Element a(String txt, {String href}) =>
  new Element(A_TYPE, children: [text(txt)], attributes: {href: href});

ElementNodeType _type(String tag) => new ElementNodeType(tag);

Element _el(ElementNodeType type, {Iterable<Node> children,
    Map<String, String> attributes}) {
  return new Element(type.typeIndex, children: children, attributes: attributes);
}


// TODO: get the full list from somewhere
final A_TYPE = _type('a');
final B_TYPE = _type('b');
final BR_TYPE = _type('br');
final BODY_TYPE = _type('body');
final BUTTON_TYPE = _type('button');
final CANVAS_TYPE = _type('canvas');
final DIV_TYPE = _type('div');
final FORM_TYPE = _type('form');
final H1_TYPE = _type('h1');
final H2_TYPE = _type('h2');
final H3_TYPE = _type('h3');
final H4_TYPE = _type('h4');
final H5_TYPE = _type('h5');
final H6_TYPE = _type('h6');
final HEAD_TYPE = _type('head');
final HTML_TYPE = _type('html');
final I_TYPE = _type('i');
final IFRAME_TYPE = _type('iframe');
final IMG_TYPE = _type('img');
final INPUT_TYPE = _type('input');
final LABEL_TYPE = _type('label');
final LI_TYPE = _type('li');
final LINK_TYPE = _type('link');
final META_TYPE = _type('meta');
final OBJECT_TYPE = _type('object');
final OL_TYPE = _type('ol');
final OPTGROUP_TYPE = _type('optgroup');
final OPTION_TYPE = _type('option');
final P_TYPE = _type('p');
final PRE_TYPE = _type('pre');
final SCRIPT_TYPE = _type('script');
final S_TYPE = _type('s');
final SELECT_TYPE = _type('select');
final SMALL_TYPE = _type('small');
final SPAN_TYPE = _type('span');
final STRONG_TYPE = _type('strong');
final STYLE_TYPE = _type('style');
final SUB_TYPE = _type('sub');
final SUP_TYPE = _type('sup');
final TABLE_TYPE = _type('table');
final TBODY_TYPE = _type('tbody');
final TD_TYPE = _type('td');
final TEXTAREA_TYPE = _type('textarea');
final TFOOT_TYPE = _type('tfoot');
final TH_TYPE = _type('th');
final THEAD_TYPE = _type('thead');
final TITLE_TYPE = _type('title');
final TR_TYPE = _type('tr');
final U_TYPE = _type('u');
final UL_TYPE = _type('ul');
final VIDEO_TYPE = _type('video');
