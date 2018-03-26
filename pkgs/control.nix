{pkgs, stdenv, contrailBuildInputs, workspace, isContrailMaster }:

stdenv.mkDerivation {
  name = "contrail-control";
  version = "3.2";
  src = workspace;
  USER="contrail";
  # Only required on master
  dontUseCmakeConfigure = true;

  buildInputs = contrailBuildInputs ++
   (pkgs.lib.optional isContrailMaster [ pkgs.cmake pkgs."rabbitmq-c" pkgs.gperftools ]);

  buildPhase = ''
    scons -j1 --optimization=production contrail-control
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/control-node/contrail-control $out/bin/
    cp ${workspace}/controller/src/control-node/contrail-control.conf $out/etc/contrail/
  '';
}

