{
  ...
}:
{
  flake.templates = {
    elm = {
      path = ./elm;
      description = "Elm dev environment";
    };
    haskell = {
      path = ./haskell;
      description = "Haskell dev environment";
    };
    java = {
      path = ./java;
      description = "Java dev environment";
    };
    python = {
      path = ./python;
      description = "Python dev environment";
    };
    rust = {
      path = ./rust;
      description = "Rust dev environment";
    };
    typescript = {
      path = ./typescript;
      description = "Typescript dev environment";
    };
  };
}
