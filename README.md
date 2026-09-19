# `_UINavigationBarPalette` と `UIScrollEdgeElementContainerInteraction` の比較

*English: [README.en.md](README.en.md)*

相互運用性リクエスト **FB22730304**（`_UINavigationBarPalette` の公開要求）および関連する
Code-Level Support ケースの補足資料です。

FB22730304 に対して「`UIScrollEdgeElementContainerInteraction` で実現できる」とのご案内を
いただきました。これを踏まえ、**同一の UI を 2 つの API で実装し、どこまでが公開 API で
実現でき、どこから実現できなくなるのかをレベル別に切り分けた**のがこのリポジトリです。

## 結論

**Level 1 については、ご案内は正しいです。** `UIScrollEdgeElementContainerInteraction` は
スクロールエッジエフェクトについては完全に機能し、この用途では palette を使う理由がありません。
Level 2 も、代償を払えば公開 API で実用に耐えます。

問題は Level 3・4 です。

| Level | やりたいこと | `UIScrollEdgeElementContainerInteraction` | `_UINavigationBarPalette` |
|---|---|---|---|
| 1 | スクロールエッジエフェクトをカスタムバーの背後にかける | ✅ **実現できる**（この用途のための API） | — |
| 2 | カスタムバーがレイアウト領域を占有する | △ 位置とサイズは手作業で揃う（画面構造の変更が必要）。ただしマテリアルは揃わない | ✅ 自動 |
| 3 | ラージタイトルとの前後関係を保つ | ✗ 引き伸ばすとピッカーがタイトルの上に来る | ✅ 順序が保たれる |
| 4 | stacked 検索バーと合成する | ✗ 置ける位置が 1 箇所だけで、表示制御もない | ✅ タイトルの上と検索バーの下の 2 スロット |
| 5 | **実際のユースケース**（Level 3 + 4） | ✗ | ✅ |

### 境界線は「ナビゲーションバー自身の高さが変化するか」

ギャップのある Level とない Level を分けているのは、この一点です。

バーの高さが固定されている限り、カスタムバーを safeArea の上端に固定し、インセットを定数で
押し下げれば成立します。しかしバーの高さが動き出した瞬間、**バー外のビューがそれに追従する
公開手段がない**ため破綻します。ギャップのある Level 3（ラージタイトルの引き伸ばし）、
Level 4（検索バーの起動・解除）は、いずれもバーの高さが変化するケースです。

破綻の仕方は前後関係の入れ替わりとして現れます。バーが伸びるとき、バーの中身
（タイトル、検索バー）は一緒に下へ移動しますが、バーの外にあるカスタムバーは safeArea が
決めた位置に留まります。その結果、上から **ピッカー → タイトル → 検索バー** の順になり、
本来バーの一部であるはずのものだけが上に残ります。

逆にバーの高さが変わらない操作では差が出ません。push / pop も検証しましたが、所有関係は違う
（palette は `UINavigationItem` が所有し、カスタムバーはビューコントローラの view の
サブビューである）にもかかわらず、実際の見た目に差はありませんでした。
そのためこの項目は Level として扱っていません。

したがって FB22730304 が求めているのは視覚効果ではなく、
**ナビゲーションバー自身がレイアウトするコンポーネントになる手段**です。

なお Level 2 の時点で、レイアウトは揃ってもマテリアルは揃いません。palette 内のピッカーは
ナビゲーションバーのガラスに参加して描画されますが、バー外のコンテナに置いたピッカーは
通常の不透明なコントロールとして描画され、バー下端にエッジエフェクトの境目の線が現れます。

## 2 つの API

### `UIScrollEdgeElementContainerInteraction`（iOS 26.0）

iOS 27.1 SDK のヘッダにおける公開 API の全体:

```objc
UIKIT_FINAL UIKIT_EXTERN NS_SWIFT_UI_ACTOR API_AVAILABLE(ios(26.0), tvos(26.0), visionos(26.0))
@interface UIScrollEdgeElementContainerInteraction : NSObject <UIInteraction>
/// The scroll view to affect
@property (nonatomic, nullable, weak) UIScrollView *scrollView;
/// The edge of the scroll view to affect
@property (nonatomic) UIRectEdge edge;
@end
```

ヘッダ自身が用途をこう説明しています。

> Add this interaction to a container view of views that overlay the edge of a scroll view.
> Any descendants of this view that should **affect the shape of the edge effect**, such as labels,
> images, glass views, and controls, will automatically do so.

スクロールエッジエフェクトの形状にビューを参加させるための仕組みです。

iOS 27.1 SDK でもこの 2 プロパティのままで、`UINavigationItem` に palette 相当の公開 API も
追加されていません。

### `_UINavigationBarPalette`

`_UINavigationBarLayoutParticipating`（`-updateLayoutData:layoutWidth:`）に準拠する `UIView` で、
`UINavigationItem` が `_topPalette` / `_bottomPalette` として所有し、`UINavigationBar` が
自身の一部としてレイアウトします。ナビゲーションバーの構成要素です。

両者はレイヤーが異なります。前者が後者の代わりにならないのはこのためです。

## 動かし方

Xcode 27 以降で `Package.swift` を開き、`Sources/Comparison/Levels/` の各ファイルで
Xcode Previews を実行してください。プレビュー名は判定つきです。

| プレビュー | 内容 |
|---|---|
| `Lv1 Public ✅` | 公開 API で実現できることの確認。スクロールするとエフェクトが見える（palette 版は不要） |
| `Lv2 Public △` / `Lv2 Palette` | 手作業で実現できるが代償がある |
| `Lv3 Public ✗` / `Lv3 Palette` | ラージタイトル |
| `Lv4 Public ✗` / `Lv4 Palette (bottom)` / `Lv4 Palette (top)` | 検索バー。palette 側は 2 つのスロットを別々に示す |
| `Lv5 Public ✗` / `Lv5 Palette` | **実際のユースケース。ここだけ見れば全体が分かる** |

各レベルの「やりたいこと・結果・判定・確認手順」は、対応するソースファイルの先頭コメントに
記載しています。

### まず見るべきもの

**`Lv5 Public ✗` と `Lv5 Palette`** を並べて、この順に操作してください。

1. 静止状態で、ピッカーが検索フィールドに対してどこに座っているかを比較する
2. 下へ引き伸ばして、タイトルと検索バーがピッカーの下に潜り込むかを見る（Level 3 と同じ現象）
3. 上へ送ってラージタイトルが通常タイトルに変わるまでスクロールする
4. 検索フィールドを起動し、解除する（Level 4 のインセット破綻）

ラージタイトル ＋ stacked 検索バー ＋ その直下のピッカーという、Music / Photos / Mail /
Fitness が採用しているパターンです。

### 録画

iOS 27.0 シミュレータ（iPhone 18 Pro）で、このリポジトリのコードをそのまま動かして
撮ったものです。表内は GIF（400px）で、原寸の mp4 は各 Level の下にリンクしてあります。
mp4 は 60fps・実速度です。

GIF はフレーム遅延を 1/100 秒の整数でしか持てないため、出力は 50fps（遅延 2cs）が上限です。
60fps の素材をそのまま 50fps で取ると 1/6 のコマが不規則に落ちてジャダーになるので、
速度を変えていない Level は先に時間を 1.2 倍へ伸ばしてから 50fps で取り出しています。
コマ落ちがない代わりに、再生は実速度の 83% です。
ファイルはすべて `Docs/` にあります。

#### Level 1 — スクロールするとピッカーの背後にエッジエフェクトがかかる

| 公開 API 版 |
|---|
| ![公開 API 版](Docs/lv1-public.gif) |

原寸の動画: [lv1-public.mp4](Docs/lv1-public.mp4)

#### Level 2 — 位置とサイズは同一。ピッカーの質感と、バー下端に境目の線が出るかを比べる

| 公開 API 版 | palette 版 |
|---|---|
| ![公開 API 版](Docs/lv2-public.gif) | ![palette 版](Docs/lv2-palette.gif) |

原寸の動画: [lv2-public.mp4](Docs/lv2-public.mp4) / [lv2-palette.mp4](Docs/lv2-palette.mp4)

#### Level 3 — 下へ引き伸ばして指を離す（手で操作）

| 公開 API 版 | palette 版 |
|---|---|
| ![公開 API 版](Docs/lv3-public.gif) | ![palette 版](Docs/lv3-palette.gif) |

引き伸ばしたところを見てください。上から順に、公開 API 版は **ピッカー → タイトル**、
palette 版は **タイトル → ピッカー** になります。palette はバーの一部なので順序が保たれますが、
公開 API 版はピッカーだけがバーの外に取り残され、タイトルがその下に回ります。

Level 5 と同じ現象で、検索バーがない分こちらのほうが単純です。

原寸の動画: [lv3-public.mp4](Docs/lv3-public.mp4) / [lv3-palette.mp4](Docs/lv3-palette.mp4)

#### Level 4 — 検索の起動と解除。palette は検索バーの下とタイトルの上の 2 箇所に置ける

| 公開 API 版 | palette 版（下スロット） | palette 版（上スロット） |
|---|---|---|
| ![公開 API 版](Docs/lv4-public.gif) | ![palette 版（下スロット）](Docs/lv4-palette.gif) | ![palette 版（上スロット）](Docs/lv4-palette-top.gif) |

Level 4 の GIF は 0.5 倍速です。原寸の mp4 は実速度です。

原寸の動画: [lv4-public.mp4](Docs/lv4-public.mp4) / [lv4-palette.mp4](Docs/lv4-palette.mp4) / [lv4-palette-top.mp4](Docs/lv4-palette-top.mp4)

#### Level 5 — 引き伸ばして指を離す → 通常タイトルまで送って折り返す → 検索の起動と解除（手で操作）

| 公開 API 版 | palette 版 |
|---|---|
| ![公開 API 版](Docs/lv5-public.gif) | ![palette 版](Docs/lv5-palette.gif) |

下へ引き伸ばしたところを見てください。上から順に、公開 API 版は
**ピッカー → タイトル → 検索バー**、palette 版は **タイトル → 検索バー → ピッカー** になります。
palette はバーの一部なので順序が保たれますが、公開 API 版はピッカーだけがバーの外に取り残され、
タイトルと検索バーがその下に潜り込みます。

Level 5 だけは実際に指で操作して録画しています（GIF は 1.67 倍速）。

原寸の動画: [lv5-public.mp4](Docs/lv5-public.mp4) / [lv5-palette.mp4](Docs/lv5-palette.mp4)


## 構成

```
Docs/                          # 各 Level の録画（GIF と mp4）
Sources/
  UIKitCorePrivate/            # 非公開ヘッダ（ipsw で iOS 26.5 から生成）
  Comparison/
    PaletteViewController.swift      # palette 版（参照実装）
    PublicAPIViewController.swift    # 公開 API 版（最善の再現）
    Support/
      ListViewController.swift       # 両者が共有するリスト画面
      FilterSegmentedControl.swift   # 両者が共有するピッカー
      BarContentView.swift           # 両者で余白を揃えるためのコンテナ
      BarMetrics.swift               # 両者が参照する唯一の寸法定義
      Scenario.swift                 # 両者に同じ条件を与える設定
    Levels/
      Level1_ScrollEdgeEffect.swift … Level5_RealWorldUseCase.swift
```

両実装は同一の `Scenario` を受け取ります。各 Level のプレビューは、どの項目を有効にしたかだけが
違います。

実装量の差もそのまま資料になります。palette 版は 3 行です。

```swift
let bottomPalette = _UINavigationBarPalette(contentView: BarContentView())!
bottomPalette.preferredHeight = scenario.barHeight
navigationItem._bottomPalette = bottomPalette
```

公開 API 版は、リストの子ビューコントローラ化・制約・インタラクション・手動インセットの
4 段階が必要で、そのうち公開 API が担うのは 1 段階だけです
（`PublicAPIViewController.swift` のコメント 1〜4）。

## 求めているもの

既存の挙動へのアクセスのみで、新しい挙動は求めていません。最小限の公開範囲は次のとおりです。

```swift
// UINavigationBarPalette
init(contentView: UIView)
var preferredHeight: CGFloat
var minimumHeight: CGFloat
var displaysWhenSearchActive: Bool

// UINavigationItem
var topPalette: UINavigationBarPalette?
var bottomPalette: UINavigationBarPalette?
```

## 参考

- Apple Developer Forums [#808436](https://developer.apple.com/forums/thread/808436) —
  「SwiftUI の `.safeAreaBar(edge: .top)` を UIKit で実現したい」という本件と同一の質問に対し、
  同じく `UIScrollEdgeElementContainerInteraction` が案内されています。同スレッドには
  「ナビゲーションバー表示時はエッジエフェクトが全幅に広がらない」という報告も付いています。
- SwiftUI には `.safeAreaBar(edge:)` という公開 API が存在する一方、UIKit には等価な公開 API が
  ありません。UIKit で構築されたアプリは、非公開 API に依存するか SwiftUI へ移行するかの
  選択を迫られています。

## 確認環境

- Xcode 27.1 (27A9269) / iOS 27.1 SDK
- `xcodebuild -scheme Comparison -destination 'generic/platform=iOS Simulator'` でビルド成功
- 録画は iOS 27.0 シミュレータで撮影
