require 'formula'

# for UTF-8-MAC filename problem
def with_unicode_path?; build.include? 'unicode-path'; end

class Zsh < Formula
  homepage 'http://www.zsh.org/'
  url 'http://downloads.sourceforge.net/project/zsh/zsh/zsh-5.0.5.tar.bz2'
  mirror 'http://www.zsh.org/pub/zsh-5.0.5.tar.bz2'
  sha1 '75426146bce45ee176d9d50b32f1ced78418ae16'

  depends_on 'gdbm'
  depends_on 'pcre'

  skip_clean :all

  def options
    [
      ['--disable-etcdir', 'Disable the reading of Zsh rc files in /etc'],
      ['--unicode-path', 'Include support for OS X UTF-8-MAC filename'],
    ]
  end

  def patches
    # Patch for Zsh handling of OS X UTF-8-MAC filename.
    if with_unicode_path?
      return { :p1 =>
        'https://gist.github.com/waltarix/1403346/raw/ba177e4e0044d16dca4f7b7f0d3888249ebe5951/zsh-utf8mac-completion.patch'
      }
    end
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{share}/zsh/functions
      --enable-scriptdir=#{share}/zsh/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-pcre
      --enable-zsh-secure-free
      --with-tcsetpgrp
    ]

    if build.include? 'disable-etcdir'
      args << '--disable-etcdir'
    else
      args << '--enable-etcdir=/etc'
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    system "make install"
  end

  def test
    system "#{bin}/zsh", "--version"
  end

  def caveats; <<-EOS.undent
    Add the following to your zshrc to access the online help:
      unalias run-help
      autoload run-help
      HELPDIR=#{HOMEBREW_PREFIX}/share/zsh/helpfiles
    EOS
  end
end
