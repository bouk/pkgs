{ substitute
, runtimeShell
, coreutils
, gnused
, gnugrep
, lib
, installShellFiles
}:
substitute {
  name = "nix-remote-shell";
  src = ./nix-remote-shell.sh;
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
    description = "Send a nix package to a remote machine";
    license = lib.licenses.mit;
    mainProgram = "nix-remote-shell";
  };
}
