#!/bin/sh
set -eu

# Xcode Cloud post-clone hook
# Tuist 프로젝트라 xcodebuild 호출 전에 xcodeproj/xcworkspace 생성이 필요.
# - GoogleService-Info.plist 복원 (Environment Variable에서)
# - Tuist 설치 (sudo 없이 user dir에)
# - SPM 의존성 fetch
# - xcodeproj/xcworkspace 생성

# Repo root로 이동 (ci_scripts/에서 한 단계 위)
cd "$(dirname "$0")/.."

# GoogleService-Info.plist 복원 (.gitignore라 repo에 없음)
# Xcode Cloud Environment Variable `GOOGLE_SERVICE_INFO_PLIST_BASE64`에서 디코딩.
# 로컬 빌드는 이미 plist 있으니 변수 없으면 skip.
if [ -n "${GOOGLE_SERVICE_INFO_PLIST_BASE64:-}" ]; then
  echo "[diag] env var length: ${#GOOGLE_SERVICE_INFO_PLIST_BASE64}"
  echo "$GOOGLE_SERVICE_INFO_PLIST_BASE64" | base64 --decode > MyI/Resources/GoogleService-Info.plist
  PLIST_SIZE=$(wc -c < MyI/Resources/GoogleService-Info.plist | tr -d ' ')
  echo "[diag] decoded plist size: ${PLIST_SIZE} bytes"
  if plutil -lint MyI/Resources/GoogleService-Info.plist >/dev/null 2>&1; then
    echo "[diag] plutil -lint: OK"
    BUNDLE_ID_IN_PLIST=$(plutil -extract BUNDLE_ID raw -o - MyI/Resources/GoogleService-Info.plist 2>/dev/null || echo "<not found>")
    echo "[diag] plist BUNDLE_ID: ${BUNDLE_ID_IN_PLIST}"
  else
    echo "[diag] plutil -lint: FAILED"
    plutil -lint MyI/Resources/GoogleService-Info.plist || true
  fi
else
  echo "[diag] WARNING: GOOGLE_SERVICE_INFO_PLIST_BASE64 env var is empty or unset"
fi

# Tuist 설치
# Xcode Cloud는 sudo 막혀서 `brew install tuist`(cask)도 `mise` 기반 install script도
# 안 됨. GitHub release binary 직접 다운로드.
TUIST_VERSION="4.191.6"
TUIST_INSTALL_DIR="$HOME/.tuist-bin"
mkdir -p "$TUIST_INSTALL_DIR"
curl -fL "https://github.com/tuist/tuist/releases/download/${TUIST_VERSION}/tuist.zip" \
  -o /tmp/tuist.zip
unzip -q -o /tmp/tuist.zip -d "$TUIST_INSTALL_DIR"

# binary 위치 자동 탐색 (zip 구조 보장 X)
TUIST_BIN=$(find "$TUIST_INSTALL_DIR" -name 'tuist' -type f | head -1)
if [ -z "$TUIST_BIN" ]; then
  echo "::error::tuist binary not found in extracted archive" >&2
  ls -la "$TUIST_INSTALL_DIR"
  exit 1
fi
chmod +x "$TUIST_BIN"
export PATH="$(dirname "$TUIST_BIN"):$PATH"

tuist install
tuist generate --no-open
