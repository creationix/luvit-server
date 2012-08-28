
define.modules = {};
define.defines = {};

function define(name, deps, fn) {
  module.deps = deps;
  function module() {
  }
  define.defines[name] = module;
}

