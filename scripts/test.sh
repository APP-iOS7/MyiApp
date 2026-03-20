#!/bin/bash

# Firebase 에뮬레이터를 사용하여 모든 테스트를 수행하는 스크립트
# 사용법: ./scripts/test.sh

echo "🚀 Firebase 에뮬레이터를 시작하고 테스트를 실행합니다..."

firebase emulators:exec --project demo-myiapp "tuist test"
