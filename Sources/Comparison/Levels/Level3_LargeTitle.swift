import SwiftUI
import UIKit

// MARK: - Level 3 — ラージタイトルとの前後関係　✗ 実現できない
//
// やりたいこと:
//   `prefersLargeTitles` が有効な画面で、カスタムバーがラージタイトルの下に位置し続けてほしい。
//
// 結果:
//   下へ引き伸ばすと前後関係が入れ替わる。上から順に、公開 API 版は
//   **ピッカー → タイトル**、palette 版は **タイトル → ピッカー** になる。
//
//   バーが伸びるとき、バーの中身であるタイトルは一緒に下へ移動するが、
//   バーの外にあるカスタムバーは safeArea が決めた位置に留まるため、
//   ピッカーだけが上に取り残される。
//
//   引き伸ばしている間、バーは伸びるが safeArea は変わらない。iOS 27.3 シミュレータで
//   102pt 引き伸ばしたとき、バーの下端は 168 → 270 に動き、safeArea の上端は 168 のままだった。
//
//   逆に、上へ送ってラージタイトルを折りたたむ間は safeArea が毎フレーム追従するので、
//   ピッカーはバーの下端から離れない。Level 2 の手動インセットもカスタムバー自身の高さなので、
//   バーの高さが変わっても古くならない。
//
// 判定: **ギャップ。**
//
// 確認手順:
//   下へスクロールして引き伸ばし、ピッカーとタイトルの上下がどうなるかを両者で比べる。
//
// 備考:
//   録画は実際に指で操作して撮っている。`contentOffset` をプログラムから書き換えると
//   `UIScrollView` 本来の処理を経由せず、この挙動が再現されない。

/// Level 3 公開 API 版: 引き伸ばすとピッカーがタイトルより上に取り残される。
@available(iOS 26.0, *)
#Preview("Lv3 Public ✗") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "Level 3", prefersLargeTitle: true)
    ),
    prefersLargeTitles: true
  )
}

/// Level 3 palette 版: バーが自身の一部としてレイアウトするため、引き伸ばしても一体で動く。
@available(iOS 18.0, *)
#Preview("Lv3 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "Level 3", prefersLargeTitle: true)
    ),
    prefersLargeTitles: true
  )
}
