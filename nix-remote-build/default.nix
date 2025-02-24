{ substitute
, runtimeShell
, coreutils
, gnused
, gnugrep
, lib
, installShellFiles
}:
substitute {
  name = "nix-remote-build";
  src = ./nix-remote-build.sh;
  dir = "bin";
  isExecutable = true;

  substitutions = [
    "--subst-var-by"
    "runtimeShell"
    runtimeShell
    "--subst-var-by"
    "path"
    (lib.makeBinPath [ coreutils gnused gnugrep ])
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  meta = {
    description = "Send a nix build to a remote machine";
    license = lib.licenses.mit;
    mainProgram = "nix-remote-build";
  };
}
