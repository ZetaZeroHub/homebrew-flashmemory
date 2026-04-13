# FlashMemory Homebrew Formula
#
# 使用方法:
#   1. 在 GitHub 上创建仓库: ZetaZeroHub/homebrew-flashmemory
#   2. 将此文件放入该仓库根目录，命名为 Formula/flashmemory.rb
#   3. 用户安装: brew tap ZetaZeroHub/flashmemory && brew install flashmemory
#
# 每次发布新版本后，需要更新 version、url 和 sha256
# 可使用 scripts/update-homebrew.sh 自动更新

class Flashmemory < Formula
  desc "Cross-language code analysis and semantic search system"
  homepage "https://github.com/ZetaZeroHub/FlashMemory"
  version "0.4.5"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/ZetaZeroHub/FlashMemory/releases/download/v#{version}/flashmemory_#{version}_darwin_amd64.tar.gz"
      sha256 "67d6caac8cb66f8dba7eeed1dc0e65663782aac9c602a4bb86b07f6e77b3994d"
    end
    on_arm do
      url "https://github.com/ZetaZeroHub/FlashMemory/releases/download/v#{version}/flashmemory_#{version}_darwin_arm64.tar.gz"
      sha256 "e05d8e39e9547ef772f1213e80863a6e8c75c389e9a39c8e84f3ece6178c0468"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/ZetaZeroHub/FlashMemory/releases/download/v#{version}/flashmemory_#{version}_linux_amd64.tar.gz"
      sha256 "f91166c84e193693920b8604fd10b4e730685b43a7abce973aa8f6c86afe2fc1"
    end
    on_arm do
      url "https://github.com/ZetaZeroHub/FlashMemory/releases/download/v#{version}/flashmemory_#{version}_linux_arm64.tar.gz"
      sha256 "0ef0e2bc33ee07a1bc27579ea57c8ffaf3e4e7b20822709ac1316429ed298503"
    end
  end

  def install
    # Place actual binaries in libexec to avoid PATH conflicts
    libexec.install "fm"
    libexec.install "fm_core"
    libexec.install "fm_http"

    # Install FAISSService to libexec
    if File.directory?("FAISSService")
      (libexec/"FAISSService").install Dir["FAISSService/*"]
    end

    # Install example config
    if File.exist?("fm.yaml.example")
      (etc/"flashmemory").install "fm.yaml.example" => "fm.yaml"
    end

    # Create wrapper scripts in `bin` that set FAISS_SERVICE_PATH
    (bin/"fm").write <<~EOS
      #!/bin/bash
      export FAISS_SERVICE_PATH="#{libexec}/FAISSService"
      exec "#{libexec}/fm" "$@"
    EOS
    (bin/"fm").chmod 0755

    (bin/"fm_core").write <<~EOS
      #!/bin/bash
      export FAISS_SERVICE_PATH="#{libexec}/FAISSService"
      exec "#{libexec}/fm_core" "$@"
    EOS
    (bin/"fm_core").chmod 0755

    (bin/"fm_http").write <<~EOS
      #!/bin/bash
      export FAISS_SERVICE_PATH="#{libexec}/FAISSService"
      exec "#{libexec}/fm_http" "$@"
    EOS
    (bin/"fm_http").chmod 0755
  end

  test do
    assert_match "FlashMemory", shell_output("#{bin}/fm version 2>&1", 0)
  end
end
