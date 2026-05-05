#!/bin/sh
set -eu

# Xcode Cloud post-clone hook
# Tuist 프로젝트라 xcodebuild 호출 전에 xcodeproj/xcworkspace 생성이 필요.
# - GoogleService-Info.plist 복원 (Environment Variable에서)
# - Tuist 설치
# - SPM 의존성 fetch
# - xcodeproj/xcworkspace 생성

# Repo root로 이동 (ci_scripts/에서 한 단계 위)
cd "$(dirname "$0")/.."

# GoogleService-Info.plist 복원 (.gitignore라 repo에 없음)
# Xcode Cloud Environment Variable `GOOGLE_SERVICE_INFO_PLIST_BASE64`에서 디코딩.
# 로컬 빌드는 이미 plist 있으니 변수 없으면 skip.
if [ -n "${GOOGLE_SERVICE_INFO_PLIST_BASE64:-}" ]; then
  echo "$GOOGLE_SERVICE_INFO_PLIST_BASE64" | base64 --decode > MyI/Resources/GoogleService-Info.plist
fi

brew install tuist
tuist install
tuist generate --no-open
