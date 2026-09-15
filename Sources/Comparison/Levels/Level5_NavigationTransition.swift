import SwiftUI
import UIKit

// MARK: - Level 5 — ナビゲーション遷移（push / pop）　✗ 実現できない
//
// やりたいこと:
//   画面ごとに異なるカスタムバーを持ち、push / pop でタイトルやバーボタンと一緒に
//   クロスフェードしてほしい。対話的な戻るジェスチャの途中でも追従してほしい。
//
// 結果:
//   iOS 27.0 シミュレータでアニメーションを遅くして遷移の途中を撮影したところ、
//   両者は決定的に違った。
//
//   palette 版は、バーが 1 枚のまま中身だけ新しい画面のものに入れ替わっている。
//   タイトルが "Second" に変わるのと同時にピッカーも "Nearby / Worldwide" になり、
//   その下でビューコントローラの view が滑り込んでくる。
//
//   公開 API 版は、**2 つのピッカーが画面上に並んで見える**。
//   前の画面の "All / Favorites" が左へ抜けていき、次の画面の "Nearby" が右から入ってくる。
//   view の境界でバーが左右に裂けた状態になる。
//
//   palette は `UINavigationItem` が所有するためバーのトランジションの一部として扱われるのに対し、
//   公開 API 版のカスタムバーは特定のビューコントローラの view のサブビューなので、
//   view と一緒に移動するしかない。
//
// 判定: **ギャップ。**
//
// 確認手順:
//   1. Push をタップする。遷移の最中を見る。
//   2. 画面端から戻るジェスチャを**ゆっくり**ドラッグし、画面の半分あたりで止める。
//   3. ピッカーが 1 つに見えるか、2 つ並んで見えるかを比べる。
//
// 備考:
//   画面ごとにピッカーの中身を変えてある（"All / Favorites / Recent" と
//   "Nearby / Worldwide"）。両画面で同じ中身だと、バーと一緒にクロスフェードしたのか
//   view と一緒に滑ったのかを見分けられないため。

/// Level 5 公開 API 版: 遷移中、2 つのピッカーが並んで見える。
@available(iOS 26.0, *)
#Preview("Lv5 Public ✗") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "First", showsPushButton: true)
    )
  )
}

/// Level 5 palette 版: バーは 1 枚のまま、中身がタイトルと一緒に入れ替わる。
@available(iOS 18.0, *)
#Preview("Lv5 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "First", showsPushButton: true)
    )
  )
}
