{ lib, stdenv, fetchFromGitHub
, drat-trim, p7zip
}:

stdenv.mkDerivation rec {
  pname = "kissat";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "arminbiere";
    repo = "kissat";
    rev = "rel-${version}";
    sha256 = "sha256-C1lvkyYgFNhV7jGVLlrpJ5zZ8SFHg8g+iW1lDczhpBM=";
  };

  outputs = [ "out" "dev" "lib" ];

  nativeCheckInputs = [ drat-trim p7zip ];
  doCheck = true;

  # 'make test' assumes that /etc/passwd is not writable.
  patches = [ ./writable-passwd-is-ok.patch ];

  # the configure script is not generated by autotools and does not accept the
  # arguments that the default configurePhase passes like --prefix and --libdir
  dontAddPrefix = true;
  setOutputFlags = false;

  installPhase = ''
    runHook preInstall

    install -Dm0755 build/kissat "$out/bin/kissat"
    install -Dm0644 src/kissat.h "$dev/include/kissat.h"
    install -Dm0644 build/libkissat.a "$lib/lib/libkissat.a"
    mkdir -p "$out/share/doc/kissat/"
    install -Dm0644 {LICEN?E,README*,VERSION} "$out/share/doc/kissat/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A 'keep it simple and clean bare metal SAT solver' written in C";
    longDescription = ''
      Kissat is a "keep it simple and clean bare metal SAT solver" written in C.
      It is a port of CaDiCaL back to C with improved data structures,
      better scheduling of inprocessing and optimized algorithms and implementation.
    '';
    maintainers = with maintainers; [ shnarazk ];
    platforms = platforms.unix;
    license = licenses.mit;
    homepage = "http://fmv.jku.at/kissat";
  };
}
