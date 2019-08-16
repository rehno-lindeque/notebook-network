# Deployment instructions

# $ nixops create deploy.nix
#

let
  networkName = "notebook";
  region = "us-east-1";
  zone = "us-east-1b";

  resources =
    import ./ec2-resources.nix { inherit networkName region zone; };

  ec2BuildSlave = instanceType: systemImport: name: { resources, lib, ... }: {
    imports =
      [ systemImport
      ];

    deployment = {
      targetEnv = "ec2";
      ec2 = {
        inherit region instanceType;
        associatePublicIpAddress = true;
        subnetId = resources.vpcSubnets."${networkName}-subnet";
        keyPair = resources.ec2KeyPairs.keypair.name;
        securityGroupIds = [ resources.ec2SecurityGroups."${networkName}-sg".name ];
        spotInstancePrice = 2; # TODO
        ebsInitialRootDiskSize = 30; # TODO
      };
    };
  };
in
{
  inherit resources;

  network = {
    description = "${networkName}";
  };

  # defaults = {
  #   imports = [
  #     ./common.nix
  #   ];
  # };
  "notebook" = ec2BuildSlave "m1.small" ./notebook-configuration.nix "notebook";
}
