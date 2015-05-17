part of lambda.tree;

/// A type of [Node] that builds its structure from a template. Projections
/// are useful when the ratio of dynamic content to static content of your
/// component is low. Projection on carries dynamic information, and therefore
/// has less data than required to build the complete structure of the
/// component.
class Projection extends Node {
  final int templateId;
  final List<ProjectionChild> content;

  Projection(this.templateId, this.content)
      : super(PROJECTION_TYPE);
}

abstract class ProjectionChild {
  /// Index to the bound element in projection template
  final int index;

  ProjectionChild(this.index);
}

class Insertion extends ProjectionChild {
  final Node node;

  Insertion(int index, this.node) : super(index);
}

class Property extends ProjectionChild {
  /// Property ID in the property registry.
  final int propertyId;
  final dynamic propertyValue;

  Property(int index, this.propertyId, this.propertyValue) : super(index);
}
