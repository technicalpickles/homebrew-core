class Fmt < Formula
  desc "Open-source formatting library for C++"
  homepage "https://fmt.dev/"
  url "https://github.com/fmtlib/fmt/archive/refs/tags/10.2.1.tar.gz"
  sha256 "1250e4cc58bf06ee631567523f48848dc4596133e163f02615c97f78bab6c811"
  license "MIT"
  revision 1
  head "https://github.com/fmtlib/fmt.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "f9dc0c31723eb4f22e1378e8321df1ed4b39911eb5a37a0a76e87e21cc7b89a5"
    sha256 cellar: :any,                 arm64_ventura:  "17fd077bd2b1fa4f79f8282deedd4c3c8f14ac6304682073e4f787f344872783"
    sha256 cellar: :any,                 arm64_monterey: "ef1392d686e361babaaa2df5a812025b85cd2a4f7b4c5229f819adff5abc0ebf"
    sha256 cellar: :any,                 sonoma:         "906df9a1334c0f62d83c0b4ee0ad13296ee6664a01194b58be730707bb7bd260"
    sha256 cellar: :any,                 ventura:        "3def3ba737bc6fc0cbf33c5439af128706e185b51cbd3d8a5699c7bf539210c4"
    sha256 cellar: :any,                 monterey:       "4b890aa33f79f61a0da985049bfae4a776a56c897a07ead872009d8eb96ba96b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "b3cbe457bbcd435144be1769cd638ba03bd776f26d9b3fe4f8d492c9bc5cb6ff"
  end

  depends_on "cmake" => :build

  # Fix handling of static separator; cherry-picked from:
  # https://github.com/fmtlib/fmt/commit/44c3fe1ebb466ab5c296e1a1a6991c7c7b51b72e
  # Remove when included in a release.
  patch :DATA

  def install
    system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=TRUE", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    system "cmake", "-S", ".", "-B", "build-static", "-DBUILD_SHARED_LIBS=FALSE", *std_cmake_args
    system "cmake", "--build", "build-static"
    lib.install "build-static/libfmt.a"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <string>
      #include <fmt/format.h>
      int main()
      {
        std::string str = fmt::format("The answer is {}", 42);
        std::cout << str;
        return 0;
      }
    EOS

    system ENV.cxx, "test.cpp", "-std=c++11", "-o", "test",
                  "-I#{include}",
                  "-L#{lib}",
                  "-lfmt"
    assert_equal "The answer is 42", shell_output("./test")
  end
end

__END__
diff --git a/include/fmt/format-inl.h b/include/fmt/format-inl.h
index 9fc87ecf2027df0346935e7666ea80ec70e65575..872aa9802df1ffa8572a2f0d29f58bdb2b171a1a 100644
--- a/include/fmt/format-inl.h
+++ b/include/fmt/format-inl.h
@@ -110,7 +110,11 @@ template <typename Char> FMT_FUNC Char decimal_point_impl(locale_ref) {
 
 FMT_FUNC auto write_loc(appender out, loc_value value,
                         const format_specs<>& specs, locale_ref loc) -> bool {
-#ifndef FMT_STATIC_THOUSANDS_SEPARATOR
+#ifdef FMT_STATIC_THOUSANDS_SEPARATOR
+  value.visit(loc_writer<>{
+      out, specs, std::string(1, FMT_STATIC_THOUSANDS_SEPARATOR), "\3", "."});
+  return true;
+#else
   auto locale = loc.get<std::locale>();
   // We cannot use the num_put<char> facet because it may produce output in
   // a wrong encoding.
@@ -119,7 +123,6 @@ FMT_FUNC auto write_loc(appender out, loc_value value,
     return std::use_facet<facet>(locale).put(out, value, specs);
   return facet(locale).put(out, value, specs);
 #endif
-  return false;
 }
 }  // namespace detail
 
