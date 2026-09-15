import SwiftUI
import UIKit

// MARK: - Level 2 — カスタムバーがレイアウト領域を占有する　△ 手作業で実現できる
//
// やりたいこと:
//   コンテンツがカスタムバーの下に潜り込まず、その下から始まってほしい。
//
// 結果:
//   実現できる。ただし 2 つの代償がある。
//
//   1. `UICollectionViewController` が使えない。`view` がコレクションビュー自体なので、
//      カスタムバーを置く兄弟ビューを追加できず、リストを子ビューコントローラとして
//      作り直す必要がある（`PublicAPIViewController` のコメント 1）。
//   2. `additionalSafeAreaInsets.top` に定数を設定して自分で維持する必要がある
//      （同コメント 4）。ナビゲーションバーの高さが固定されている限りは正しく動く。
//
// 判定: **部分的に可能。** バーの高さが変化しない画面であれば、公開 API で実用に耐える。
//   Level 3 以降は、この「バーの高さが変化しない」という前提が崩れたときの話である。

/// Level 2 公開 API 版: インセットは手動。バー高さが固定なので、この Level では正しく動く。
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
