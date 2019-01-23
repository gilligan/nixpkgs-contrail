{ stdenv
, pkgs
, contrailVersion
, contrailWorkspace
, boost
, thrift
, log4cplus
, tbb
, cassandraCppDriver
}:

stdenv.mkDerivation rec {
  name = "contrail-query-engine-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  buildInputs = with pkgs; [
    scons libxml2 libtool flex_2_5_35 bison curl
    vim # to get xxd binary required by sandesh
    boost thrift log4cplus tbb cassandraCppDriver
  ];
  USER = "contrail";
  NIX_CFLAGS_COMPILE = "-isystem ${thrift}/include/thrift";
  buildPhase = ''
    scons -j2 --optimization=production contrail-query-engine
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/query_engine/qed $out/bin/
    cp ${contrailWorkspace}/controller/src/query_engine/contrail-query-engine.conf $out/etc/contrail/
  '';
}
