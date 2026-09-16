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

問題は Level 3・4・5 です。

| Level | やりたいこと | `UIScrollEdgeElementContainerInteraction` | `_UINavigationBarPalette` |
|---|---|---|---|
| 1 | スクロールエッジエフェクトをカスタムバーの背後にかける | ✅ **実現できる**（この用途のための API） | — |
| 2 | カスタムバーがレイアウト領域を占有する | △ 位置とサイズは手作業で揃う（画面構造の変更が必要）。ただしマテリアルは揃わない | ✅ 自動 |
| 3 | ラージタイトル折りたたみ中にバー下端へ追従する | ✗ ラグ・ジッターが発生 | ✅ |
| 4 | stacked 検索バーと合成する | ✗ 置ける位置が 1 箇所だけで、表示制御もない | ✅ タイトルの上と検索バーの下の 2 スロット |
| 5 | iOS 27 のバー最小化に追従する | ✗ 参加できない | ✅ |
| 6 | **実際のユースケース**（Level 3 + 4） | ✗ | ✅ |

### 境界線は「ナビゲーションバー自身の高さが変化するか」

ギャップのある Level とない Level を分けているのは、この一点です。

バーの高さが固定されている限り、カスタムバーを safeArea の上端に固定し、インセットを定数で
押し下げれば成立します。しかしバーの高さが動き出した瞬間、**バー外のビューがそれに追従する
公開手段がない**ため破綻します。ギャップのある Level 3（ラージタイトルの折りたたみ）、
Level 4（検索バーの起動・解除）、Level 5（iOS 27 のバー最小化）は、いずれもバーの高さが
変化するケースです。

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

iOS 27.0 SDK のヘッダにおける公開 API の全体:

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
| `Lv4 Public ✗` / `Lv4 Palette` | 検索バー |
| `Lv5 Public ✗` / `Lv5 Palette` | iOS 27 バー最小化 |
| `Lv6 Public ✗` / `Lv6 Palette` | **実際のユースケース。ここだけ見れば全体が分かる** |

各レベルの「やりたいこと・結果・判定・確認手順」は、対応するソースファイルの先頭コメントに
記載しています。

### まず見るべきもの

**`Lv6 Public ✗` と `Lv6 Palette`** を並べて、この順に操作してください。

1. 静止状態で、ピッカーが検索フィールドに対してどこに座っているかを比較する
2. ゆっくりスクロールしてラージタイトルを折りたたむ（Level 3 のラグ）
3. 上端までフリックしてバウンスさせる（ラグが最大になる）
4. 検索フィールドを起動し、解除する（Level 4 のインセット破綻）

ラージタイトル ＋ stacked 検索バー ＋ その直下のピッカーという、Music / Photos / Mail /
Fitness が採用しているパターンです。

## 構成

```
Sources/
  UIKitCorePrivate/            # 非公開ヘッダ（ipsw で iOS 26.5 から生成）
  Comparison/
    PaletteViewController.swift      # palette 版（参照実装）
    PublicAPIViewController.swift    # 公開 API 版（最善の再現）
    Support/
      ListViewController.swift       # 両者が共有するリスト画面
      FilterSegmentedControl.swift   # 両者が共有するピッカー
      BarContentView.swift           # 両者で余白を揃えるためのコンテナ
      Scenario.swift                 # 両者に同じ条件を与える設定
    Levels/
      Level1_ScrollEdgeEffect.swift … Level6_RealWorldUseCase.swift
```

両実装は同一の `Scenario` を受け取ります。各 Level のプレビューは、どの項目を有効にしたかだけが
違います。

実装量の差もそのまま資料になります。palette 版は 3 行です。

```swift
let palette = _UINavigationBarPalette(contentView: BarContentView())!
palette.preferredHeight = scenario.barHeight
navigationItem._bottomPalette = palette
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

## 調査メモ

サンプルを組む過程で分かった、`_UINavigationBarPalette` を実際に使う際の落とし穴です。

### ipsw が生成したプロパティ宣言はそのままでは実行時に落ちる

`_UINavigationBarPalette.h` のプロパティ宣言には `setter=` が付いていません。

```objc
@property (nonatomic) unsigned long long _contentViewMarginType;
```

この宣言のまま Swift から代入すると `set_contentViewMarginType:` を呼びますが、
実際のセレクタは同ヘッダの instance methods にある `_setContentViewMarginType:` です。

```
-[_UINavigationBarPalette set_contentViewMarginType:]: unrecognized selector sent to instance
```

`_displaysWhenSearchActive` と `_layoutPriority` も同じ形です。このリポジトリでは
3 つとも `setter=` を補ってあります。`_displaysWhenSearchActive` は FB22730304 で公開を
求めている項目でもあるため、この修正なしでは検証そのものができません。

### `_topPalette` はタイトルより上のスロット

名前から検索バーの上を想像しますが、実際はナビゲーションバーの最上部です。
`_topPalette` と `_bottomPalette` の両方に stacked 検索バーを組み合わせると、
上から次の順に並びます（iOS 27.0 シミュレータで確認）。

```
_topPalette      ← タイトルより上
タイトル
検索バー（stacked）
_bottomPalette   ← 検索バーより下
```

公開 API 側のコンテナビューは safeArea の下端、つまりナビゲーションバー全体の外側にしか
置けないため、このどちらの位置も取れません。

### `_contentViewMarginType` には観測可能な効果がなかった

値 0〜5 を実機（iOS 27.0 シミュレータ）で試し、ピッカーの帯をピクセル単位で比較しましたが、
すべて一致しました。名前に反して、これで左右の余白は付きません。

### 余白は contentView 側で与える。ただし縦の内容サイズを確定させること

palette は `contentView` を横いっぱいに広げるため、余白はコンテナビューで与えます
（`BarContentView`）。このとき、コンテナ内でピッカーを centerY だけで留めると、
ピッカーが palette の高さ（44pt）いっぱいに引き伸ばされ、カプセルの角が崩れて描画されます。
上下も制約で留めて、コンテナ自身の縦の内容サイズを確定させる必要があります。

## 正確性に関する注記

- `_UINavigationBarPalette.pinned` は、設定しても観測可能な変化がありませんでした。
  FB22730304 で求めている範囲には含めていません。
- `UINavigationController.attachPalette(_:isPinned:)` は、`navigationItem._bottomPalette` への
  代入と同じ挙動でした。
- Level 3・5・6 の差分は挙動であり、画面収録で確認するものです。それ以外の差分は
  SDK のヘッダだけから確認できます。
- `Sources/UIKitCorePrivate/include/` のヘッダは [ipsw](https://github.com/blacktop/ipsw) で
  iOS 26.5 から生成したものです。比較をビルド可能にするためだけに同梱しています。

## 確認環境

- Xcode 27.0 (27A266a) / iOS 27.0 SDK
- `xcodebuild -scheme Comparison -destination 'generic/platform=iOS Simulator'` でビルド成功
