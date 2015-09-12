# Goals

Premise: a mobile-first web UI toolkit for material design UIs.

- Features:
  * HTML-ish templates - Angular, React/JSX
    * readability > conciseness
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
  - templates
  - fragment controllers (a.k.a. ng-if, ng-for; nestable; scoped)
  - decorators
  - text interpolation
  - property binding
  - events
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

# Sound bites

- Zero-cost abstraction: minimal runtime; framework-in-compiler
- Hackable: extend or bring your own compiler
- Skin deep: easy to get access to raw browser API
- Apps, not sites: one fewer thing to care about

# Mobile vs Desktop

|   | Desktop | Mobile |
| - | ------- | ------ |
| % of time spent on features  | 70%  | 30% |
| % of time spent on performance  | 30%  | 70% |
| users care about | capability | responsiveness |
| users interact using | KVM | touch, speech |
| applications | few apps with lots of features | lots of apps with few features |
