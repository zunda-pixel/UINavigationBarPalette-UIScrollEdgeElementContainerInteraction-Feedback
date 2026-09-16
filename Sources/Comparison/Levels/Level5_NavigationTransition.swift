import SwiftUI
import UIKit

// MARK: - Level 5 — ナビゲーション遷移（push / pop）　✅ 差は確認できなかった
//
// やりたいこと:
//   画面ごとに異なるカスタムバーを持ち、push / pop や対話的な戻るジェスチャの最中も
//   破綻せずに遷移してほしい。
//
// 結果:
//   **両者に見た目の差は確認できなかった。** iOS 26 以降の push はカード型の遷移で、
//   新しい画面がバーごと滑り込んでくる。palette 側もカスタムバー側も同じように
//   カードの一部として移動するため、結果が一致する。
//
//   API 上の所有関係は違う（palette は `UINavigationItem` が所有し、公開 API 版の
//   カスタムバーはビューコントローラの view のサブビューである）が、
//   この Level ではその違いが画面に出てこない。
//
// 判定: **ギャップなし。** この Level は公開 API で問題ない。
//
//   当初この Level は「遷移中に 2 つのピッカーが並んで見える」というギャップとして
//   書いていたが、公開 API 版の 1 フレームだけを見た誤った判断だった。
//   対になる palette 版のフレームを同じ進行度で撮れておらず、比較が成立していなかった。
//   その後プレビューで手動確認したところ、両者は同じ挙動だった。
//
//   FB22730304 はこの Level を根拠にしない。
//
// 確認手順:
//   1. Push をタップする。
//   2. 画面端から戻るジェスチャを**ゆっくり**ドラッグし、画面の半分あたりで止める。
//   3. 両者の見え方を比べる。
//
// 備考:
//   画面ごとにピッカーの中身を変えてある（"All / Favorites / Recent" と
//   "Nearby / Worldwide"）。同じ中身だと差の有無を判断できないため。

/// Level 5 公開 API 版。
@available(iOS 26.0, *)
#Preview("Lv5 Public ✅") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "First", showsPushButton: true)
    )
  )
}

/// Level 5 palette 版。
@available(iOS 18.0, *)
#Preview("Lv5 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "First", showsPushButton: true)
    )
  )
}
