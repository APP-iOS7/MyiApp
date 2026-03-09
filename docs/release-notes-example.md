# 릴리즈 노트 예시

**메이저·마이너 릴리스만** (`v*.*.0`) 태그 푸시 시 `.github/workflows/release.yml`이 GitHub Release를 생성하고,
`.github/release.yml` 설정에 따라 PR 기반 릴리즈 노트가 자동 생성됩니다.

- **트리거**: `v1.0.0`, `v1.1.0`, `v2.0.0` 등 (패치 `v1.2.1` 제외)

## 생성 결과 예시

```markdown
## What's Changed

### 🚀 새 기능

* AuthClient 프로토콜 추가 by @username in #194
* Tuist 버전 고정 및 릴리즈 워크플로우 추가 by @username in #199

### 🐛 버그 수정

* 타임라인 날짜 정렬 오류 수정 by @username in #150

### ♻️ 개선

* 성능 최적화 by @username in #145

### 📝 문서·테스트

* 테스트 코드 추가 by @username in #140

### 🔧 인프라

* CI 워크플로우 추가 by @username in #196

### 🛠 기타

* 의존성 업데이트 by @dependabot in #148

**Full Changelog**: https://github.com/APP-iOS7/MyiApp/compare/v1.2.0...v1.3.0
```

## 카테고리 매핑 (.github/release.yml)

| 카테고리 | PR 라벨 |
|----------|---------|
| 🚀 새 기능 | `✨ feature`, `📈 improvement`, `🎨 ui/ux` |
| 🐛 버그 수정 | `🐛 bug` |
| ♻️ 개선 | `♻️ refactor`, `⚡ performance` |
| 📝 문서·테스트 | `📝 documentation`, `🧪 test` |
| 🔧 인프라 | `🔧 chore`, `🔄 ci/cd`, `🏗️ build`, `🚀 deploy` |
| 🛠 기타 | 그 외 (`*`) |

## 사용 방법

1. `release/1.3.0` 브랜치를 `main`에 머지
2. `git tag v1.3.0 && git push origin v1.3.0` 실행 (패치 `v1.2.1`은 릴리즈 노트 미생성)
3. GitHub Actions가 Release 생성 및 릴리즈 노트 자동 작성
