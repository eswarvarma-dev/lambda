# Goals

Premise: a mobile-first web UI toolkit for material design UIs.

- Features:
  * HTML-ish templates - Angular, React/JSX
  * directives (decorators, fragment controllers) - Angular
  * dependency injection - Angular
  * change detection - Angular
  * zones - Angular
  * be fast:
    - to download (tree-shake, no mirrors)
    - to bootstrap (pre-compile everything) - React
    - to run (monomorphic change detection, template cloning, view reuse) - Angular
- Excellent dev experience:
  * be Darty
  * DDC-ready
  * instant transformation
  * no mirrors
  * lexical scope everywhere
  * direct access to DOM, domain-specific nodes
- Laser-focus:
  * Web-only
  * Dart-only
  * Mobile-first
  * Material design-first
  * DDC-first

# Plan

1. MVP:
  - file-by-file transformer
  - 'hello world' <150kb minified, <60kb gzipped, <2s load (~Moto X 2014)
  - match UIX/React on load time
1. MVP+1:
  - dependency injection
  - view instantiation optimization:
    1. DOM reuse (a la ng2 view reuse)
    1. DOM cloning?
  - CSS encapsulation
  - CSS tree-shaking
  - match ng2 on post-load performance
