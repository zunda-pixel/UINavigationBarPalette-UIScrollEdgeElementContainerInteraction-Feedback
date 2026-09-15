import SwiftUI
import UIKit

// MARK: - Level 2 — カスタムバーがレイアウト領域を占有する　△ 手作業で実現できる
//
// やりたいこと:
//   コンテンツがカスタムバーの下に潜り込んだままにならず、その下から始まってほしい。
//
// 結果:
//   レイアウトとしては実現できる。ただし 2 つの代償があり、さらに描画は一致しない。
//
//   1. `UICollectionViewController` が使えない。`view` がコレクションビュー自体なので、
//      カスタムバーを置く兄弟ビューを追加できず、リストを子ビューコントローラとして
//      作り直す必要がある（`PublicAPIViewController` のコメント 1）。
//   2. `additionalSafeAreaInsets.top` に定数を設定して自分で維持する必要がある
//      （同コメント 4）。ナビゲーションバーの高さが固定されている限りは正しく動く。
//
//   palette 版は以下の 3 行で、画面構造の変更もインセットの指定も不要。
//
//   ```swift
//   let palette = _UINavigationBarPalette(contentView: FilterSegmentedControl())!
//   palette.preferredHeight = scenario.barHeight
//   navigationItem._bottomPalette = palette
//   ```
//
//   そして描画が一致しない。iOS 27.0 シミュレータで両者を並べたところ、
//   ジオメトリは 1pt 単位で一致する（どちらもコントロール 124〜168、コンテンツ開始 180）のに、
//   palette 版ではピッカーがナビゲーションバーのガラスマテリアルに参加して描画される
//   （半透明で、細い縁取りを持つ）のに対し、公開 API 版では通常の不透明なコントロールとして
//   描画され、さらにバー下端にエッジエフェクトの境目の線が現れる。
//   コンテナビューはバーの外にあるため、バーの背景と一枚のクロームにならない。
//
//   同じ差は選択中セグメントの形にも出る。`BarMetrics.controlHeight` は
//   `UISegmentedControl` の標準高さ（32pt）ではなく 44pt にしてあり、この高さでは
//   palette 版の選択中セグメントがスクワークル型、公開 API 版がピル型になる。
//   同一のコントロールを同一のサイズで置いても、描画するのは palette 側である。
//
// 判定: **部分的に可能。** バーの高さが変化しない画面なら、位置とサイズは公開 API で揃う。
//   ただしマテリアルは揃わない。
//   Level 3 以降は、この「バーの高さが変化しない」という前提が崩れたときの話である。
//
// 確認手順:
//   2 つのプレビューを並べ、ピッカーの質感とバー下端の境目を比較する。
//   そのうえで `PublicAPIViewController.swift` と `PaletteViewController.swift` の
//   実装量を比較する。

/// Level 2 公開 API 版: 画面構造の変更と手動インセットが必要。
@available(iOS 26.0, *)
#Preview("Lv2 Public △") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(Scenario(title: "Level 2"))
  )
}

/// Level 2 palette 版: `preferredHeight` がバーの高さに算入されるので、インセットの指定は不要。
@available(iOS 18.0, *)
#Preview("Lv2 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(Scenario(title: "Level 2"))
  )
}
