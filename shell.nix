{ pkgs ? import <nixpkgs> {}
, stateFilePath ? (builtins.getEnv "PWD" + "/secrets/localstate.nixops")
, secretsEnvPath ? (builtins.getEnv "PWD" + "/secrets/.ec2-env")
}:

let
  notebookNetwork = pkgs.callPackage ./. { inherit stateFilePath secretsEnvPath; };
in
pkgs.stdenv.mkDerivation
  {
    name = "notebook-network-provisioning-environment";
    version = "0.0.0";
    buildInputs =
      with pkgs;
      [
        git-crypt
        nixops
        notebookNetwork
      ];
    shellHook =
      let
        nc="\\e[0m"; # No Color
        white="\\e[1;37m";
        black="\\e[0;30m";
        blue="\\e[0;34m";
        light_blue="\\e[1;34m";
        green="\\e[0;32m";
        light_green="\\e[1;32m";
        cyan="\\e[0;36m";
        light_cyan="\\e[1;36m";
        red="\\e[0;31m";
        light_red="\\e[1;31m";
        purple="\\e[0;35m";
        light_purple="\\e[1;35m";
        brown="\\e[0;33m";
        yellow="\\e[1;33m";
        grey="\\e[0;30m";
        light_grey="\\e[0;37m";
      in
        ''
        echo
        printf "${white}"
        echo "------------------------------------------------"
        echo "Notebook network provisioning environment"
        echo "------------------------------------------------"
        printf "${nc}"
        ${notebookNetwork}/bin/notebook-help

        export NIXOPS_STATE=${stateFilePath}
        export NIXOPS_DEPLOYMENT=notebook
        '';
  }


