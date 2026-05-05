#!/bin/sh
set -eu

# Xcode Cloud post-clone hook
# Tuist 프로젝트라 xcodebuild 호출 전에 xcodeproj/xcworkspace 생성이 필요.
# - Tuist 설치
# - SPM 의존성 fetch
# - xcodeproj/xcworkspace 생성

# Repo root로 이동 (ci_scripts/에서 한 단계 위)
cd "$(dirname "$0")/.."

brew install tuist
tuist install
tuist generate --no-open
