{ bootstrap_pkgs ? import <nixpkgs> {}
, pkgs_path ? bootstrap_pkgs.fetchFromGitHub {
    owner = "nlewo";
    repo = "nixpkgs";
    rev = "0c41433868ad61aac43da184c113f305a3784957";
    sha256 = "0jrlk9wwbskzw2bxvncna1fi4qm596r83smcfh1dashb8gm3ddp8";
  }
, pkgs ? import pkgs_path {}
}:

let
  debian = import ./debian.nix {inherit pkgs;};
  controller = import ./controller.nix {inherit pkgs;};
  webui = import ./webui.nix {inherit pkgs;};
  deps = import ./deps.nix {inherit pkgs;};
in
  with controller; with webui; with deps; {
    inherit contrailApi contrailControl contrailVrouterAgent
            # This is not a derivation.
            contrailVrouter
            contrailCollector contrailAnalyticsApi contrailDiscovery
            contrailQueryEngine
            contrailConfigUtils contrailVrouterUtils # contrailApiCli
            contrailVrouterNetns contrailVrouterPortControl
            webCore;
  } //
  { 
    debian = debian;
    test = { contrail = import ./test/test.nix { inherit pkgs pkgs_path; }; };
  }
