{ lib, linkFarm, writeShellScriptBin, nixops
, stateFilePath  # Path to a .nixops file that contains nix state
}:

let
  networkScripts = lib.fix (self:
    lib.mapAttrs writeShellScriptBin {
      notebook-help = ''
        echo "USAGE:"
        echo
        echo "notebook-help"
        echo "notebook-ops"
        echo "notebook-ip"
        echo "notebook-up"
        echo "notebook-down"
        echo "notebook-ssh"
        '';
      notebook-ops = ''
        if [[ -f ${secretsEnvPath} ]]; then
          echo "using secrets in ${secretsEnvPath}"
          source ${secretsEnvPath}
        else
          echo "secrets path ${secretsEnvPath} does not exist"
        fi
        echo "${nixops}/bin/nixops $1 -s ${stateFilePath} -d notebook ''${@:2}"
        ${nixops}/bin/nixops $1 -s ${stateFilePath} -d notebook ''${@:2}
        '';
      notebook-ip = ''
        ${self.notebook-ops}/bin/notebook-ops info --plain 2>/dev/null \
          | grep notebook \
          | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' \
          | head -1 \
          | tr -d '\n'
        '';
      notebook-up = ''
        ${self.notebook-ops}/bin/notebook-ops deploy --include notebook
        # pull down host key ..
        '';
      notebook-down = ''
        ${self.notebook-ops}/bin/notebook-ops destroy --include notebook
        '';
      notebook-ssh = ''
        ${self.notebook-ops}/bin/notebook-ops ssh notebook
        '';
    });
in
  linkFarm "notebook-network"
    (lib.attrValues
      (lib.mapAttrs (name: path: { name = "bin/${name}"; path = "${path}/bin/${name}"; }) networkScripts))
