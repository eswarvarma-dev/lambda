part of lambda.browser.node_type;

final PROJECTION_TYPE = new ProjectionNodeType();

class ProjectionNodeType extends NodeType<Projection> {
  // TODO: implement
  @override
  String toXml(Projection p) => '[projection:${p.templateId}]';
}
