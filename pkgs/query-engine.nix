{ stdenv
, pkgs
, deps
, contrailVersion
, contrailWorkspace
}:

stdenv.mkDerivation rec {
  name = "contrail-query-engine-${version}";
  version = contrailVersion;
  src = contrailWorkspace;
  buildInputs = with pkgs; [
    scons libxml2 libtool flex_2_5_35 bison curl
    vim # to get xxd binary required by sandesh
    deps.boost deps.thrift deps.log4cplus deps.tbb
    deps.cassandraCppDriver
  ];
  USER = "contrail";
  NIX_CFLAGS_COMPILE = [
    "-Wno-unused-but-set-variable"
    "-isystem ${deps.thrift}/include/thrift"
  ];
  separateDebugInfo = true;
  buildPhase = ''
    scons -j2 --optimization=production contrail-query-engine
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc/contrail}
    cp build/production/query_engine/qed $out/bin/contrail-query-engine
    cp -r build/lib $out/
  '';
}
