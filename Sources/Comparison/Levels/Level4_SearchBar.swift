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
//   相当するものがない。palette は検索中に隠れるが、カスタムバーは検索バーの下に残り続ける。
//   また検索を解除するアニメーションでは、カスタムバーがナビゲーションバーと一緒に動かず、
//   iOS 27.3 シミュレータで下端から最大 54pt 離れた。解除し終えた後の位置は palette 版と
//   一致するので、手動インセットが古くなるわけではない。
//
// 判定: **ギャップ。**
//
// 確認手順:
//   1. 3 つのプレビューを見比べ、ピッカーが座れる位置の数を比べる。
//   2. 検索フィールドをタップして起動する。
//   3. キャンセルして解除する。
//   4. 検索中にピッカーが残るか、解除のアニメーション中にピッカーがバーと一緒に動くかを比較する。

/// Level 4 公開 API 版: 置けるのはナビゲーションバーの外側、safeArea 下端の 1 箇所だけ。
/// 検索中もピッカーが残り、解除のアニメーションではバーと一緒に動かない。
@available(iOS 26.0, *)
#Preview("Lv4 Public ✗") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "Level 4", usesSearchController: true)
    )
  )
}

/// Level 4 palette 版・下スロット: `_bottomPalette` は検索バーの直下に入る。
/// これが Music / Photos / Mail / Fitness のフィルタと同じ位置。
@available(iOS 18.0, *)
#Preview("Lv4 Palette (bottom)") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "Level 4", usesSearchController: true)
    )
  )
}

/// Level 4 palette 版・上スロット: `_topPalette` はタイトルより上に入る。
/// 公開 API ではこの位置にビューを置く手段がない。
@available(iOS 18.0, *)
#Preview("Lv4 Palette (top)") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(
        title: "Level 4",
        usesSearchController: true,
        usesBottomPalette: false,
        usesTopPalette: true
      )
    )
  )
}
