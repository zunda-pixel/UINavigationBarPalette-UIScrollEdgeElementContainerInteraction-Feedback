import SwiftUI
import UIKit

// MARK: - Level 4 — 検索バーとの合成　✗ 実現できない
//
// やりたいこと:
//   `preferredSearchBarPlacement = .stacked` の検索バーの直下にピッカーを置き、
//   検索がアクティブになったらシステムのアニメーションに乗せて出し入れしたい。
//   Music / Photos / Mail / Fitness の「検索フィールド直下のフィルタ」がこの挙動。
//
// 結果:
//   公開 API では、そもそもタイトル領域と stacked 検索バーの「間」にビューを置く手段がない。
//   safeArea の下端に置くことしかできないため、配置の自由度がない。
//   また検索アクティブ時の表示制御（palette の `_displaysWhenSearchActive`）に
//   相当するものがなく、検索の起動・解除でバーの高さが変わると手動インセットが破綻する。
//
//   palette 側は `_topPalette` / `_bottomPalette` という明確なスロットを持ち、
//   検索バーの上下どちらに置くかを選べる。
//
// 判定: **ギャップ。**
//
// 確認手順:
//   1. 検索フィールドをタップして起動する。
//   2. キャンセルして解除する。
//   3. 解除後のコンテンツ先頭位置を両者で比較する。

/// Level 4 公開 API 版: 検索の起動・解除でインセットが合わなくなる。
@available(iOS 26.0, *)
#Preview("Lv4 Public ✗") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "Level 4", usesSearchController: true)
    )
  )
}

/// Level 4 palette 版: `_bottomPalette` が検索バーの下に入り、インセットもバーが維持する。
@available(iOS 18.0, *)
#Preview("Lv4 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "Level 4", usesSearchController: true)
    )
  )
}
