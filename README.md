# P2J Mobile

P들을 위한 TODO 공유 앱 P2J의 Flutter 클라이언트.

로컬 DB를 쓰지 않는다. 모든 데이터는 서버 REST API로 오간다.
기기에 남는 것은 `flutter_secure_storage`에 저장하는 액세스/리프레시 토큰뿐이다.

---

## 개발 환경 세팅

윈도우 기준이다. 처음부터 끝까지 따라 하면 앱이 뜬다.
맥이나 리눅스는 경로만 다르고 나머지는 같다.

검증 환경: Windows 11, Flutter 3.47.2, Dart 3.13.2, Android SDK 36.

### 1. Flutter SDK

[docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)에서 받거나
git 이 있으면 아래로 받는다.

```
git clone https://github.com/flutter/flutter.git -b stable C:\flutter
```

**경로에 공백이 없어야 하고 `C:\Program Files` 아래는 피한다.** 권한 문제로 Flutter 가 경고한다.

받은 뒤 `C:\flutter\bin` 을 PATH 에 등록한다. 관리자 권한 없이 되는 방법:

```
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";C:\flutter\bin", "User")
```

터미널을 새로 열고 확인한다.

```
flutter --version
```

PATH 등록을 건너뛰려면 아래 문서의 모든 `flutter` 를 `C:\flutter\bin\flutter.bat` 으로 바꿔 읽으면 된다.

### 2. Android Studio

[developer.android.com/studio](https://developer.android.com/studio) 에서 받는다. winget 으로도 된다.

```
winget install --id Google.AndroidStudio -e
```

설치 후 실행해서 초기 마법사를 끝낸다. SDK 와 JDK 가 함께 깔린다.
**JDK 를 따로 설치할 필요는 없다.** Android Studio 가 번들로 가지고 있다.

이어서 **SDK Manager** (톱니바퀴 → SDK Manager)에서 두 가지를 추가한다.

- **SDK Tools** 탭 → `Android SDK Command-line Tools (latest)` 체크
- **SDK Platforms** 탭 → `Android 16.0 (API 36)` 체크

### 3. 에뮬레이터

Android Studio → **Device Manager** → **+ Create Virtual Device**

- 기기: Pixel 7
- 시스템 이미지: **API 36, Google APIs, x86_64** (약 1.8GB 다운로드)
- Google Play 이미지는 root adb 가 막혀 있으니 Google APIs 를 고른다

만든 뒤 상단에 `Windows Hypervisor Platform is not enabled` 배너가 뜨면 **Enable** 을 누르고 재부팅한다.
직접 켜려면 `optionalfeatures.exe` 에서 **Windows 하이퍼바이저 플랫폼**을 체크한다.
"Hyper-V" 전체는 체크하지 않는다. 다른 가상화 도구와 충돌한다.

안드로이드 폰이 있으면 에뮬레이터 대신 써도 된다. 이 앱은 로컬 DB 없이 전부 네트워크로 돌아서 실기기가 더 빠르다.
설정 → 휴대전화 정보 → 빌드번호 7번 탭 → 개발자 옵션 → USB 디버깅 켜기.

### 4. 확인

```
flutter doctor
```

`Android toolchain` 과 `Chrome` 에 체크가 있으면 된다.
`Visual Studio not installed` 는 윈도우 데스크톱 앱용이라 무시해도 된다.
`Android license status unknown` 도 무시해도 된다 — 아래 "자주 막히는 곳" 참고.

---

## 프로젝트 실행

### 1. 플랫폼 폴더 생성

이 저장소에는 `lib/` 와 설정 파일만 들어 있다. `android/` 와 `web/` 은 아래 명령으로 만든다.
기존 파일은 덮어쓰지 않는다.

```
flutter create --org dev.p2j --project-name p2j_mobile --platforms android,web .
```

`minSdk` 는 손댈 필요 없다. Flutter 3.47 기본값이 24라
`flutter_secure_storage` 의 API 23+ 요구를 이미 넘는다.

`web` 을 함께 만드는 이유는 Android SDK 없이도 화면을 확인할 수 있어서다.

### 2. 의존성 설치와 코드 생성

```
flutter pub get
```

```
dart run build_runner build
```

freezed 모델과 riverpod 프로바이더가 생성된다. **`.g.dart` / `.freezed.dart` 는 저장소에 없으므로 이 단계를 건너뛰면 빌드가 깨진다.**

build_runner 2.15부터 `--delete-conflicting-outputs` 는 제거됐다. 붙여도 무시된다.

`pub get` 이 버전 충돌로 실패하면 아래로 최신 호환 버전을 다시 잡는다.

```
flutter pub upgrade --major-versions
```

### 3. 실행

에뮬레이터를 켜거나 폰을 연결한 뒤 기기 목록을 확인한다.

```
flutter devices
```

```
flutter run --dart-define=USE_MOCK=true
```

기기가 여러 대면 `-d` 로 고른다.

```
flutter run -d emulator-5554 --dart-define=USE_MOCK=true
```

Android SDK 없이 브라우저로 먼저 볼 수도 있다.

```
flutter run -d chrome --dart-define=USE_MOCK=true
```

앱이 뜨면 인트로가 나온다. 이름을 넣고 아무 이메일과 8자 이상 비밀번호로 가입하면 홈으로 들어간다.
백엔드는 아직 없고 전부 Mock 응답이다.

### 4. 코드 수정 중

모델(`*_models.dart`)이나 프로바이더(`@riverpod`)를 고치면 코드 생성을 다시 돌려야 한다.
파일을 감시하며 자동으로 다시 만들려면 아래를 켜 둔다.

```
dart run build_runner watch
```

정적 분석은 커밋 전에 돌린다. 경고 0개를 유지한다.

```
flutter analyze
```

### 검증 상태

Flutter 3.47.2 / Dart 3.13.2 기준으로 확인했다.

| 명령 | 결과 |
| --- | --- |
| `flutter pub get` | 131개 의존성 해석 |
| `dart run build_runner build` | 27개 파일 생성, 에러 없음 |
| `flutter analyze` | `No issues found` |
| `flutter build apk --debug` | 성공 |
| 에뮬레이터 실행 | Pixel 7 / Android 16 (API 36) 확인 |

### 자주 막히는 곳

**Gradle 빌드가 `Package ndk not found` 로 죽는다면.**
`path_provider_android` 가 끌어오는 `jni` 플러그인이 NDK 를 요구한다. 토큰 저장에 쓰는
`flutter_secure_storage` 의 전이 의존이라 뺄 수 없다. Gradle 이 자동 설치를 시도하지만,
새 Android SDK 에서 `sdkmanager` 가 deprecated 되면서 그 경로가 프로세스 크래시
(`NTSTATUS 0xC0000409`) 로 죽는다. 새 CLI 로 직접 받으면 넘어간다.

```
%LOCALAPPDATA%/Android/Sdk/cmdline-tools/latest/bin/android.exe sdk install "platforms/android-36" "ndk/28.2.13676358"
```

NDK 는 다운로드 713MB, 압축 해제 2.1GB 다. `platforms/android-36` 을 같이 받는 이유는
Flutter 3.47 의 `compileSdk` 가 36 인데 Android Studio 가 기본으로 다른 버전을 깔아두기
때문이다. 이 둘만 넣으면 나머지(platform 35, CMake 등)는 Gradle 이 알아서 설치한다.

**`flutter doctor` 가 `Android license status unknown` 이라고 한다면.**
무시해도 된다. Android SDK 툴링이 `sdkmanager` 에서 `android` CLI 로 넘어가면서
`flutter doctor --android-licenses` 옵션 자체가 없어졌고, Flutter 가 옛 방식으로
상태를 조회하다 실패해서 나오는 표시다. 실제 라이선스는 Gradle 이 빌드 중에
필요할 때 수락한다.

**에뮬레이터가 `Windows Hypervisor Platform is not enabled` 라고 한다면.**
Windows 기능 켜기/끄기(`optionalfeatures.exe`)에서 **Windows 하이퍼바이저 플랫폼**을
체크하고 재부팅한다. Android Studio 의 Device Manager 상단 배너에서 바로 켤 수도 있다.
"Hyper-V" 전체를 켜면 다른 가상화 도구와 충돌할 수 있으니 체크하지 않는다.

---

## Mock ↔ 실서버 전환

백엔드가 붙기 전까지 모든 화면은 Mock 응답으로 돈다.
전환은 빌드 플래그 하나로 하고, **화면 코드와 Repository는 한 줄도 바뀌지 않는다.**
`MockInterceptor`가 Dio 체인에 등록되느냐 마느냐만 달라진다.

| 모드 | 명령 |
| --- | --- |
| Mock (기본값) | `flutter run --dart-define=USE_MOCK=true` |
| 실서버 | `flutter run --dart-define=USE_MOCK=false` |
| 주소 지정 | `flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://10.0.2.2:8000/v1` |

`API_BASE_URL` 기본값이 `http://10.0.2.2:8000/v1`이다. 안드로이드 에뮬레이터에서
호스트 PC의 `localhost`가 `10.0.2.2`다. **전환에 소스 수정은 필요 없다.**

실기기로 테스트하려면 PC의 LAN IP를 넣는다. 평문 HTTP는 Android 9부터 막히는데,
`android/app/src/debug/`에만 `network_security_config.xml`을 두어 debug 빌드에서만 열어 뒀다.
메인 매니페스트에 `usesCleartextTraffic="true"`를 넣지 말 것 — 릴리스에 딸려간다.

### Mock 시나리오

에러 화면과 빈 화면을 실제로 눈으로 확인하기 위한 스위치다.

```
flutter run --dart-define=USE_MOCK=true --dart-define=MOCK_SCENARIO=emptyTodos
```

| 값 | 동작 |
| --- | --- |
| `normal` | 기본. 투두 4개, 목표 3개가 들어 있다 |
| `emptyTodos` | 투두·목표가 하나도 없는 신규 사용자. 빈 상태 화면 |
| `networkError` | 모든 요청이 연결 실패. 에러 화면과 재시도 버튼 |
| `serverError` | 인증 외 모든 요청이 500 |
| `tokenExpired` | 로그인 후 첫 요청이 401. 재발급 1회 → 재시도 흐름 확인 |

`WEAK_PASSWORD`는 비밀번호를 8자 미만으로 넣으면, `EMAIL_ALREADY_EXISTS`는
`taken@p2j.dev`로 가입을 시도하면 재현된다.

Mock은 **상태를 메모리에 유지한다.** 투두를 완료 체크하면 다음 조회에도 완료로 남고,
달성률과 목표 진행률이 다시 계산된다. 앱을 재시작하면 fixture 기준으로 초기화된다.

fixture(`lib/mock/fixtures/*.json`)의 날짜는 `{{TODAY}}`, `{{TODAY-3}}`, `{{TODAY+18}}` 같은
플레이스홀더로만 쓴다. 날짜를 하드코딩하면 다음 날 실행할 때 빈 화면이 나온다.

---

## 폴더 구조

feature-first다. 레이어를 domain/data/presentation 3단으로 나누지 않고,
feature 안에서 **data / presentation 2단**으로만 나눈다. 3인 학생팀 규모에서 domain 레이어는 오버헤드다.

```
lib/
├── main.dart                     진입점
├── app.dart                      MaterialApp.router, 앱 복귀 시 today 재확인
├── core/
│   ├── config/                   app_config(실서버 전환 지점), env(--dart-define)
│   ├── network/                  ApiClient + 인터셉터 3종 + 예외/응답 래퍼
│   ├── storage/                  token_storage
│   ├── router/                   app_router(인증 게이트), routes(경로 상수)
│   ├── theme/                    컬러·타이포·스페이싱 토큰, ThemeData
│   └── widgets/                  로딩·에러·빈 상태·입력·진행률 바
├── features/
│   ├── auth/    data(모델·API·Repository) / presentation(화면·프로바이더)
│   ├── todo/    〃
│   ├── goal/    〃
│   └── shell/   바텀 네비게이션 껍데기, 스플래시, 준비 중 화면
└── mock/                         가짜 서버. 실서버 빌드에서는 트리 셰이킹으로 빠진다
```

## 규칙

- 모든 네트워크 호출은 Repository를 거친다. 화면에서 Dio를 직접 부르지 않는다.
- Repository는 인터페이스를 분리해 둔다. 나중에 테스트에서 가짜 구현으로 갈아끼운다.
- Provider는 `@riverpod` 코드 생성 방식으로 통일한다.
- 위젯 파일은 200줄을 넘기지 않는다. 넘으면 쪼갠다.
- 서버가 주는 enum 값은 모르는 값이 와도 앱이 죽지 않게 `unknown` 폴백을 둔다.

## 도메인 규칙

**하루의 경계는 자정이 아니라 04:00 KST다.** 새벽 1시에 앱을 켠 사용자에게 "오늘"은 어제 날짜다.
그래서 **클라이언트는 오늘 날짜를 직접 계산하지 않는다.** `GET /auth/me`의 `today`를 믿고,
`serverTodayProvider`로 전역에서 꺼내 쓴다. 앱이 백그라운드에서 복귀하면 다시 확인한다.

**선언 잠금.** `is_declared: true`인 투두는 제목 수정과 삭제가 막힌다. 완료 체크는 가능하다.
UI에서 잠금 아이콘을 보여주고 스와이프 삭제를 아예 열지 않는다.

**낙관적 업데이트.** 완료 체크는 서버 응답을 기다리지 않고 즉시 UI를 바꾼다.
실패하면 되돌리고 스낵바로 알린다. `uncomplete`는 204라 바디가 없어서
`summary`를 로컬에서 다시 센다(재조회하지 않는다). 서버 조회 결과의 `summary`는
그대로 믿고, 낙관적 변경분만 로컬에서 반영한다.

**토큰 재발급.** 서버가 refresh 토큰 rotation을 쓴다. 동시에 401을 받은 요청들이
각자 재발급을 부르면 두 번째부터 실패해 엉뚱한 로그아웃이 생긴다. 그래서
`AuthInterceptor`가 진행 중인 재발급 Future를 **하나만** 유지하고 나머지는 그것을
기다린다. 재시도는 요청당 1회로 `RequestOptions.extra` 플래그가 강제한다.

**Riverpod 자동 재시도는 꺼져 있다.** Riverpod 3 은 provider 가 실패하면 기본으로
10회까지 지수 백오프(200ms~6.4s)로 재시도한다. 그동안 상태가 계속 `AsyncLoading` 이라,
오프라인으로 앱을 켜면 스플래시에서 50초 가까이 갇힌다. `main.dart` 의 `ProviderScope`
에서 `retry: (retryCount, error) => null` 로 껐다. 재시도는 에러 화면의 '다시 시도'
버튼으로 사용자가 정한다.

**자동 로그인이 실패하면 스플래시가 에러를 보여준다.** 로그인 화면으로 보내면
사용자는 로그아웃된 줄 안다. 실제로는 대개 오프라인일 뿐이고 토큰은 살아 있다.
그래서 라우터는 `auth.hasError` 일 때도 스플래시에 머물고, 스플래시가 재시도 버튼과
'다른 계정으로 로그인' 탈출구를 제공한다.

**enum.** 서버가 값을 추가할 수 있으므로 전부 `unknown` 폴백을 둔다.
`deferred`/`skipped`는 이 UI가 만들지 않지만 회색 처리 + 배지로 렌더링한다.
모르는 값은 pending처럼 동작시키되 **배지에 원문 문자열을 그대로 노출**한다.
조용히 숨기면 서버가 값을 추가했을 때 아무도 눈치채지 못한다.

## 디자인 토큰

토스 계열의 중성 회색 스케일 + 단일 브랜드 블루. `lib/core/theme/app_colors.dart`.

| 이름 | 값 | 용도 |
| --- | --- | --- |
| `ink` | `#191F28` | 본문, 큰 숫자, 제목 |
| `inkSub` | `#4E5968` | 눌러야 하는 본문 |
| `muted` | `#8B95A1` | 보조 텍스트, 라벨 |
| `disabled` | `#B0B8C1` | 비활성, placeholder |
| `background` / `surface` | `#FFFFFF` | 화면과 카드. 둘 다 순백 |
| `fill` | `#F2F4F6` | 옅은 채움. 진행률 트랙, 입력 필드, 목표 카드 |
| `line` | `#E5E8EB` | 구분선 |
| `brand` | `#3182F6` | 주요 버튼, 진행률, 완료 체크 |
| `danger` | `#F04452` | 에러, 스와이프 삭제 |

**성취를 색이 아니라 크기로 강조한다.** 달성률은 52px w700 잉크 숫자로 쓰고, 브랜드
블루는 진행 표시와 주요 액션에만 쓴다. 다 끝낸 날에만 숫자가 브랜드 색으로 바뀐다 —
화면에서 유일한 축하다. 어두운 블록에 형광색을 얹어 소리치는 방식은 폐기했다.

타이포는 7단계(`display / titleXL / titleL / titleM / body / caption / label`),
스페이싱은 4의 배수 8단계(`s4 … s40`), 라운드는 `r8 / r12 / r20`.

폰트는 **Pretendard 가변 폰트**를 번들한다(`assets/fonts/PretendardVariable.ttf`, 6.5MB).
한글 자간과 숫자 균형이 시스템 폰트보다 낫다. SIL Open Font License 라 상업적 사용도
자유롭고, 라이선스 전문을 `assets/fonts/Pretendard-OFL.txt` 에 함께 담았다.

가변 폰트 하나로 모든 굵기를 내는데, **Flutter 는 가변 폰트에서 `fontWeight` 를 wght 축에
자동으로 이어주지 않는다.** 그래서 `app_typography.dart` 의 모든 스타일이 `fontWeight` 와
`fontVariations` 를 함께 지정한다. 새 스타일을 추가하거나 `copyWith(fontWeight:)` 로
굵기를 덮어쓸 때는 축도 같이 바꿔야 한다. 안 그러면 굵기가 무시되거나 가짜 볼드가 나온다.

### 화면이 지켜야 할 것

이 앱의 목적은 **사람이 계획 세우는 일을 최소로 줄이는 것**이다. 자연어나 음성으로
아무렇게나 말하면 서버가 할 일로 쪼개 준다. 그러니 화면도 사용자에게 결정을 적게
요구해야 한다.

- 한 화면에 질문 하나. 제목을 크게 쓰고 나머지는 비운다.
- 입력 단계를 늘리지 않는다. 수동 추가 바텀시트가 제목 하나만 필수인 이유다.
- 주요 액션은 화면 아래에 붙여 엄지가 닿는 곳에 둔다.
- 사용자가 고를 수 있는 값은 서버가 정할 수 있는 값보다 적어야 한다.

8주차에 음성 입력이 들어올 자리는 홈의 플로팅 버튼이다. 지금은 수동 추가가 그 자리를
쓰고 있고, 빈 상태 문구도 이미 그 방향을 가리킨다.

## 만들지 않은 것

음성 입력·STT(8주차), AI 파싱(`/ai/parse`), 계획량 안내(10주차),
그룹·선언·인증샷·랭킹(12~13주차), 통계 화면(11주차), 푸시·딥링크·다국어.

바텀 네비게이션의 그룹·통계 탭은 "준비 중" 플레이스홀더다.
