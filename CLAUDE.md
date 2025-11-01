# DailyRecord - 다온일기

## 프로젝트 개요

### 프로젝트 목표
다온일기는 사용자의 일상을 감정과 함께 기록하고 회고할 수 있는 iOS 일기 애플리케이션입니다.

### 주요 기능
- **일기 작성**: 텍스트, 감정, 이미지를 포함한 일기 작성 및 수정
- **캘린더 뷰**: 월별/일별 일기 조회 및 감정 상태 시각화
- **차트**: 감정 통계 및 분석
- **검색**: 일기 내용 검색
- **드로어**: 일기 목록 보기
- **프로필/설정**:
  - iCloud 동기화
  - 화면 잠금 (비밀번호 보호)
  - 다크 모드 설정
  - 다국어 지원 (한국어, 영어)
  - 앱 평가하기
  - 문의하기
- **위젯**: 홈 화면 위젯 지원

---

## 기술 스택

### 언어 & 플랫폼
- **Swift** (iOS)
- **UIKit** (UI 프레임워크)
- **Xcode** (개발 환경)

### 아키텍처 & 디자인 패턴
- **Clean Architecture** (Data, Domain, Presentation 계층 분리)
- **MVVM** (Model-View-ViewModel)
- **Coordinator Pattern** (화면 전환 관리)
- **Dependency Injection** (DIContainer)

### 핵심 라이브러리
- **SnapKit**: Auto Layout DSL
- **FSCalendar**: 캘린더 UI
- **Combine**: 리액티브 프로그래밍

### 데이터 & 저장소
- **CoreData**: 로컬 데이터베이스 (일기 저장)
- **iCloud**: 백업 및 동기화
- **KeyChain**: 비밀번호 보안 저장
- **UserDefaults**: 앱 설정 저장

### 분석 & 모니터링
- **Firebase Analytics**: 사용자 분석
- **Firebase Crashlytics**: 크래시 리포팅
- **Amplitude**: 사용자 행동 분석

### 기타
- **WidgetKit**: 홈 화면 위젯
- **PhotosUI**: 사진 라이브러리 접근
- **LocalAuthentication**: 생체 인증 (Face ID, Touch ID)
- **StoreKit**: 앱 평가
- **Fastlane**: 배포 자동화

---

## 프로젝트 구조

```
DailyRecord/
├── Application/           # 앱 진입점 및 기본 설정
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Coordinator/       # 화면 전환 관리
│   └── DIContainer/       # 의존성 주입 컨테이너
│
├── Domain/                # 비즈니스 로직 계층
│   ├── Entity/            # 도메인 모델
│   ├── Interface/         # Repository 프로토콜
│   └── UseCase/           # 비즈니스 로직
│
├── Data/                  # 데이터 계층
│   ├── Repository/        # Repository 구현체
│   ├── Manager/           # CoreData, Shortcut 등 매니저
│   └── Storage/           # 데이터 저장소
│       ├── CoreData.xcdatamodeld
│       ├── KeyChain/
│       └── UserDefaults/
│
├── Presentation/          # UI 계층
│   ├── CalendarScene/     # 캘린더 화면
│   ├── ChartScene/        # 차트 화면
│   ├── DrawerScene/       # 드로어(목록) 화면
│   ├── RecordScene/       # 일기 작성/조회 화면
│   ├── SearchScene/       # 검색 화면
│   └── ProfileScene/      # 프로필/설정 화면
│
│   (각 Scene은 아래 구조를 따름)
│   ├── ViewController/    # 화면 컨트롤러
│   ├── ViewModel/         # 뷰 모델
│   └── View/              # 커스텀 뷰 컴포넌트
│
├── Util/                  # 유틸리티
│   ├── Base/              # Base 클래스들
│   ├── Common/            # 공통 타입 및 상수
│   ├── Extension/         # Swift Extension
│   └── Logger/            # 로깅 및 분석
│
└── Resource/              # 리소스
    ├── Assets.xcassets    # 이미지, 색상 등
    ├── Font/              # 폰트 파일
    ├── ko.lproj/          # 한국어 리소스
    ├── en.lproj/          # 영어 리소스
    └── Info.plist

Widget/                    # 위젯 Extension
fastlane/                  # 배포 자동화
```

---

## 코딩 컨벤션

### 네이밍 규칙

#### 1. Swift 기본 네이밍
- **클래스/구조체/프로토콜**: PascalCase (예: `RecordViewModel`, `DefaultRecordRepository`)
- **변수/함수/프로퍼티**: camelCase (예: `createRecord`, `emotionType`)
- **상수**: camelCase (예: `coreDataManager`)

#### 2. Enum Case
- **Enum Case**: snake_case 사용 (예: `very_happy`, `very_sad`)
- **CoreData 속성**: snake_case 사용 (예: `calendar_date`, `create_time`, `emotion_type`)

#### 3. 파일 네이밍
- **ViewController**: `{기능}ViewController.swift` (예: `CalendarViewController.swift`)
- **ViewModel**: `{기능}ViewModel.swift` (예: `RecordViewModel.swift`)
- **View**: `{기능}View.swift` (예: `RecordFooterView.swift`)
- **Extension**: `{타입}+.swift` (예: `Date+.swift`, `UIImage+.swift`)
- **UseCase**: `{도메인}UseCase.swift` (예: `RecordUseCase.swift`)
- **Repository**: `{도메인}Repository.swift` (예: `RecordRepository.swift`)
- **Coordinator**: `{화면}Coordinator.swift` (예: `RecordCoordinator.swift`)
- **DIContainer**: `{화면}DIContainer.swift` (예: `RecordDIContainer.swift`)

### 코드 스타일

#### 1. 파일 헤더 주석
모든 Swift 파일은 다음 형식의 헤더 주석을 포함합니다:
```swift
//
//  FileName.swift
//  DailyRecord
//
//  Created by Kim SungHun on MM/DD/YY.
//
```

#### 2. MARK 주석 활용
코드 섹션을 명확히 구분하기 위해 `MARK` 주석을 적극 활용합니다:
```swift
// MARK: - Properties
// MARK: - Init
// MARK: - Functions
// MARK: - Views
```

#### 3. 클래스 및 구조체
- `final class` 키워드를 사용하여 상속을 명시적으로 제한합니다
- Protocol을 통한 추상화를 선호합니다

```swift
final class RecordViewModel: BaseViewModel {
  // ...
}
```

#### 4. Extension 활용
- 기능별로 Extension을 나누어 코드를 구조화합니다
- Protocol 채택은 별도 Extension에서 수행합니다

```swift
extension RecordViewModel {
  func updateContent(_ content: String) {
    self.content = content
  }
}
```

#### 5. 뷰 초기화
- 클로저를 사용한 뷰 초기화 패턴을 사용합니다:

```swift
private let divider: UIView = {
  let view = UIView()
  view.backgroundColor = .azLightGray.withAlphaComponent(0.05)
  return view
}()
```

#### 6. BaseViewController 패턴
모든 ViewController는 `BaseViewController`를 상속하며, 다음 메서드를 오버라이드합니다:
- `addView()`: 서브뷰 추가
- `setLayout()`: 레이아웃 설정 (SnapKit)
- `setupView()`: 초기 설정

```swift
final class RecordFooterView: BaseView {
  override func addView() {
    [divider, galleryIcon, saveIcon].forEach {
      addSubview($0)
    }
  }

  override func setLayout() {
    divider.snp.makeConstraints { make in
      make.top.equalToSuperview()
    }
  }

  override func setupView() {
    // 초기 설정
  }
}
```

#### 7. 접근 제어
- 외부에서 접근할 필요가 없는 프로퍼티/메서드는 `private` 사용
- 읽기만 가능한 프로퍼티는 `private(set)` 사용

```swift
private let coreDataManager: CoreDataManager = CoreDataManager.shared
private(set) var content: String = ""
```

#### 8. 비동기 처리
- `async/await` 패턴 사용
- UseCase 메서드는 `async throws`로 정의

```swift
func createRecord(data: RecordEntity) async throws {
  try await recordRepository.createRecord(data: data)
}
```

---

## 아키텍처 패턴

### Clean Architecture 계층 구조

```
Presentation Layer (ViewController, ViewModel)
        ↓
Domain Layer (UseCase, Entity, Repository Protocol)
        ↓
Data Layer (Repository Implementation, CoreData, KeyChain)
```

### 의존성 방향
- **Presentation → Domain → Data**
- Domain 계층은 Data 계층을 직접 알지 못하며 Interface(Protocol)를 통해 통신
- DIContainer를 통해 의존성 주입

### MVVM 패턴
```
View (ViewController) ← Binding → ViewModel → UseCase → Repository
```

### Coordinator 패턴
- 화면 전환 로직을 ViewController에서 분리
- 각 Scene마다 별도의 Coordinator 존재
- DIContainer와 함께 사용되어 의존성 주입 수행

---

## 개발 환경 및 도구

### Xcode 설정
- **Minimum Deployment Target**: iOS 15.0 이상 (확인 필요)
- **Build System**: Xcode Build System

### Localization
- **지원 언어**: 한국어 (ko), 영어 (en)
- **리소스**: `ko.lproj/Localizable.strings`, `en.lproj/Localizable.strings`
- **자동 생성**: `Strings+Generated.swift` (SwiftGen 또는 수동 관리)

### 배포
- **Fastlane**: 배포 자동화
- **CI/CD**: GitHub Actions (추정)
- **Provisioning**: Match를 통한 인증서 관리

---

## 중요 규칙 및 제약사항

### ⚠️ 빌드 및 실행
**코드 수정 후 빌드는 하지 마세요. 빌드는 개발자가 직접 수행합니다.**

### 응답 언어
⚠️ **중요**: 모든 응답은 한글로 작성해야 합니다.
- 사용자와의 모든 커뮤니케이션은 한글로 진행합니다
- 코드 설명, 변경사항 요약, 질문 등 모든 텍스트 응답은 한글로 작성합니다
- 코드 내 주석도 한글로 작성합니다
- 단, 코드 자체(변수명, 함수명 등)는 영어를 사용합니다

### 보안
- API Key 및 민감 정보는 코드에 하드코딩하지 않습니다
- `GoogleService-Info.plist`는 `.gitignore`에 포함되어 있습니다
- KeyChain을 사용하여 비밀번호를 안전하게 저장합니다

### CoreData
- `Record` 엔티티가 주요 데이터 모델
- 속성명은 snake_case 사용: `calendar_date`, `create_time`, `emotion_type`, `image_list`, `image_identifier`
- CoreDataManager는 Singleton 패턴으로 구현

### 이미지 처리
- 이미지는 JPEG로 압축하여 저장 (compression quality: 0.1)
- 이미지 식별자(identifier)와 Data를 함께 저장

### 날짜/시간
- 타임스탬프는 밀리초 단위 Int64로 저장
- `Date+.swift`에 milliseconds 변환 Extension 존재

---

## 주요 타입 및 모델

### EmotionType
감정을 나타내는 Enum (Type.swift)
- **기분**: `very_happy`, `happy`, `neutral`, `sad`, `very_sad`, `angry`, `embarrassed`, `hurt`, `lovely`, `sleepy`, `surprised`, `tired`
- **일상**: `shopping`, `coffee`, `food`, `culture`, `sleep`, `alcohol`, `hospital`, `music`, `love`, `studying`, `cleaning`, `money`, `shower`, `book`, `bomb`

### RecordEntity
일기 데이터를 나타내는 구조체
```swift
struct RecordEntity {
  let content: String              // 일기 내용
  let emotionType: String          // 감정 타입
  let imageList: [Data]            // 첨부 이미지 데이터
  let imageIdentifier: [String]    // 이미지 식별자
  let createTime: Int              // 생성/수정 시간 (밀리초)
  let calendarDate: Int            // 캘린더 날짜
}
```

### DisplayMode
화면 모드를 나타내는 Enum
- `system`: 시스템 설정 따름
- `light`: 라이트 모드
- `dark`: 다크 모드

---

## 자주 사용하는 패턴

### 1. Repository 패턴
```swift
// Protocol 정의 (Domain/Interface)
protocol DefaultRecordRepository {
  func createRecord(data: RecordEntity) async throws
}

// 구현체 (Data/Repository)
final class RecordRepository: DefaultRecordRepository {
  func createRecord(data: RecordEntity) async throws {
    // CoreData 저장 로직
  }
}
```

### 2. UseCase 패턴
```swift
protocol DefaultRecordUseCase {
  func createRecord(data: RecordEntity) async throws
}

final class RecordUseCase: DefaultRecordUseCase {
  let recordRepository: DefaultRecordRepository

  init(recordRepository: DefaultRecordRepository) {
    self.recordRepository = recordRepository
  }

  func createRecord(data: RecordEntity) async throws {
    try await recordRepository.createRecord(data: data)
  }
}
```

### 3. Coordinator 패턴
```swift
protocol Coordinator: AnyObject {
  associatedtype DIContainerProtocol: DIContainer
  var DIContainer: DIContainerProtocol { get }

  func start()
  func popToRoot()
}
```

### 4. ViewModel 업데이트 패턴
```swift
func updateContent(_ content: String) {
  self.content = content
}
```

---

## 로깅 및 분석

### Amplitude
- 사용자 행동 분석
- `AmplitudeManager.swift`에서 관리
- API Key: 코드에 하드코딩되어 있음 (보안 고려 필요)

### Firebase
- **Analytics**: 사용자 분석
- **Crashlytics**: 크래시 리포팅
- `AppDelegate`에서 초기화

---

## Git Commit 메시지 규칙

최근 커밋 히스토리를 보면 다음과 같은 형식을 사용합니다:
- `:rocket: [deploy]`: 배포
- `:sparkles: [feat]`: 새 기능
- `:hammer: [chore]`: 기타 작업

---

## 참고 사항

### Widget
- `Widget/` 디렉터리에 위젯 Extension 코드 존재
- WidgetKit을 사용하여 구현
- 일기 작성/수정 후 `WidgetCenter.shared.reloadAllTimelines()` 호출

### iCloud 동기화
- CoreData의 NSPersistentCloudKitContainer 사용
- 사용자가 설정에서 토글로 활성화/비활성화 가능

### 화면 잠금
- LocalAuthentication (Face ID, Touch ID) 지원
- 비밀번호는 KeyChain에 안전하게 저장
- 비밀번호 분실 시 복구 불가 (사용자에게 경고 필요)

### Localization
- `Localizable.strings` 파일 관리
- `Strings+Generated.swift`를 통해 타입 안전한 문자열 접근

---

## 요약

DailyRecord는 **Clean Architecture**와 **MVVM 패턴**을 기반으로 한 iOS 일기 애플리케이션입니다.
**UIKit + SnapKit**으로 UI를 구성하고, **CoreData**로 로컬 저장, **iCloud**로 동기화하며,
**Coordinator 패턴**으로 화면 전환을 관리합니다.

코드 수정 시에는 **Clean Architecture 계층 구조**를 유지하고, **Protocol 기반 추상화**를 활용하며,
**MARK 주석**과 **Extension**을 통해 코드를 구조화해야 합니다.

**중요: 코드 수정 후 빌드는 하지 마세요. 빌드는 개발자가 직접 수행합니다.**
