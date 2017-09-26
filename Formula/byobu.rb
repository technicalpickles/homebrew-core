class Byobu < Formula
  desc "Text-based window manager and terminal multiplexer"
  homepage "http://byobu.co/"
  url "https://launchpad.net/byobu/trunk/5.123/+download/byobu_5.123.orig.tar.gz"
  sha256 "2e5a5425368d2f74c0b8649ce88fc653420c248f6c7945b4b718f382adc5a67d"

  bottle do
    cellar :any_skip_relocation
    sha256 "a7ae1b513159bec1b2994f573552520a5e52652eb860bd4745a830e35809e8a0" => :high_sierra
    sha256 "2a557d087004fad0d9aece2161f7c3137e0e21e4ac8f2791efd1b644e66dd008" => :sierra
    sha256 "2a557d087004fad0d9aece2161f7c3137e0e21e4ac8f2791efd1b644e66dd008" => :el_capitan
    sha256 "2a557d087004fad0d9aece2161f7c3137e0e21e4ac8f2791efd1b644e66dd008" => :yosemite
  end

  head do
    url "https://github.com/dustinkirkland/byobu.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  depends_on "coreutils"
  depends_on "gnu-sed" # fails with BSD sed
  depends_on "tmux"
  depends_on "newt"

  conflicts_with "ctail", :because => "both install `ctail` binaries"

  def install
    if build.head?
      cp "./debian/changelog", "./ChangeLog"
      system "autoreconf", "-fvi"
    end
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    Add the following to your shell configuration file:
      export BYOBU_PREFIX=#{HOMEBREW_PREFIX}
    EOS
  end

  test do
    system bin/"byobu-status"
  end
end
