import SwiftUI
import UIKit

// MARK: - Level 6 — 実際のユースケース（FB22730304）　✗ 実現できない
//
// やりたいこと:
//   ラージタイトル ＋ stacked 検索バー ＋ その直下のピッカー。
//   Music / Photos / Mail / Fitness が採用しているパターンであり、
//   FB22730304 のアプリが必要としているものそのもの。
//
//   これは Level 3・4 が同時に起きる構成であり、この 1 組だけで
//   ギャップのほとんどを確認できる。
//
// 判定: **ギャップ。**
//
// 確認手順（両プレビューを並べて、この順に操作する）:
//   1. 静止状態で、ピッカーが検索フィールドに対してどこに座っているかを比較する。
//   2. ゆっくりスクロールしてラージタイトルを折りたたむ（Level 3 のラグ）。
//   3. 上端までフリックしてバウンスさせる（ラグが最大になる）。
//   4. 検索フィールドを起動し、解除する（Level 4 のインセット破綻）。

/// Level 6 公開 API 版。
@available(iOS 26.0, *)
#Preview("Lv6 Public ✗") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(
        title: "Level 7",
        prefersLargeTitle: true,
        usesSearchController: true
      )
    ),
    prefersLargeTitles: true
  )
}

/// Level 6 palette 版。
@available(iOS 18.0, *)
#Preview("Lv6 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(
        title: "Level 7",
        prefersLargeTitle: true,
        usesSearchController: true
      )
    ),
    prefersLargeTitles: true
  )
}
