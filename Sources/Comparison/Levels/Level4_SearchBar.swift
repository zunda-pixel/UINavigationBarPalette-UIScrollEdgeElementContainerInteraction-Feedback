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
//   palette はナビゲーションバーの中に 2 つのスロットを持つ。iOS 27.0 シミュレータで
//   両方を設定して確認したところ、上から次の順で並ぶ。
//
//       _topPalette      ← タイトルより上
//       タイトル
//       検索バー（stacked）
//       _bottomPalette   ← 検索バーより下
//
//   公開 API にはこのどちらの相当物もない。コンテナビューは safeArea の下端、つまり
//   ナビゲーションバー全体の外側にしか置けないため、タイトルの上にも、
//   タイトルと検索バーの間にも入れられない。選べる配置がそもそも 1 つしかない。
//
//   さらに検索アクティブ時の表示制御（palette の `_displaysWhenSearchActive`）に
//   相当するものがなく、検索の起動・解除でバーの高さが変わると手動インセットが破綻する。
//
// 判定: **ギャップ。**
//
// 確認手順:
//   1. 2 つのプレビューを並べ、ピッカーを置けている位置の数を比べる。
//   2. 検索フィールドをタップして起動する。
//   3. キャンセルして解除する。
//   4. 解除後のコンテンツ先頭位置を両者で比較する。

/// Level 4 公開 API 版: 置けるのは safeArea 下端の 1 箇所だけ。
/// 検索の起動・解除でインセットが合わなくなる。
@available(iOS 26.0, *)
#Preview("Lv4 Public ✗") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "Level 4", usesSearchController: true)
    )
  )
}

/// Level 4 palette 版: タイトルの上（`_topPalette`）と検索バーの下（`_bottomPalette`）の
/// 両方に置ける。インセットもバーが維持する。
@available(iOS 18.0, *)
#Preview("Lv4 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "Level 4", usesSearchController: true, usesTopPalette: true)
    )
  )
}
