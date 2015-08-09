# Goals

A mobile-first web UI toolkit for material design UIs.

- Combine the best of Angular with the best of React (remove everything else):
  * HTML-ish templates - Angular, React/JSX
  * directives (decorators, fragment controllers) - Angular
  * dependency injection - Angular
  * create, do not mutate - React
  * be fast:
    - to download (tree-shake, no mirrors)
    - to bootstrap (pre-compile everything) - React
    - to run (monomorphic change detection, template cloning, view reuse) - Angular
- Best possible dev experience:
  * be Darty
  * DDC-ready
  * instant transformation
  * no mirrors
  * lexical scope everywhere
  * direct access to DOM, domain-specific nodes
- Laser-focus:
  * One complete solution >> many incomplete solutions
  * Web-only
  * Dart-only
  * Mobile-first
  * Material design-first
  * DDC-first

# Plan

1. MVP:
  - compile to UIX
  - 'hello world' <200kb minified, <80kb gzipped, <2s load (~Moto G 2015)
  - match UIX/React on load time
1. MVP+1:
  - One of:
    1. UIX is both DDC-compliant && supports fat-node implementation
    1. Move off UIX in favor of a custom-built DDC-compliant VDOM that implements
      fat node
  - implement "fat node" that speeds up view instantiation via:
    1. DOM cloning
    1. DOM reuse (a la ng2 view reuse)
  - dependency injection
  - CSS encapsulation & tree-shaking
  - match ng2 on post-load performance
