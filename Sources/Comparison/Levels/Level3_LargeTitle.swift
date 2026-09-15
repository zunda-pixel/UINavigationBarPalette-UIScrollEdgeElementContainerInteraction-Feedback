import SwiftUI
import UIKit

// MARK: - Level 3 — ラージタイトル（バーの高さが連続的に変化する）　✗ 実現できない
//
// やりたいこと:
//   `prefersLargeTitles` が有効な画面で、カスタムバーがナビゲーションバーの下端に
//   貼り付いたまま一体で動いてほしい。
//
// 結果:
//   公開 API 版では、折りたたみの最中にカスタムバーがラグ・ジッターを起こし、
//   バーの下端に追従しきれない。ナビゲーションバーは自身の高さをアニメーションする一方、
//   カスタムバーはビューコントローラ側のレイアウトパスで `safeAreaLayoutGuide` を
//   解決して再配置されるため、両者を同一フレームで同期させる公開手段がない。
//
//   あわせて Level 2 の手動インセットも問題になる。折りたたみでバーの高さが変わっても
//   「高さが変わった」ことを知る公開 API がないため、定数のまま取り残される。
//
// 判定: **ギャップ。**
//
// 確認手順:
//   1. ゆっくりスクロールしてラージタイトルを折りたたむ。
//   2. 上端までフリックしてバウンスさせる（ラージタイトルが伸び、ずれが最大になる）。

/// Level 3 公開 API 版: 折りたたみ中にピッカーがバー下端から遅れる。
@available(iOS 26.0, *)
#Preview("Lv3 Public ✗") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "Level 3", prefersLargeTitle: true)
    ),
    prefersLargeTitles: true
  )
}

/// Level 3 palette 版: バーが自身の一部としてレイアウトするため、折りたたみ中も一体で動く。
@available(iOS 18.0, *)
#Preview("Lv3 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "Level 3", prefersLargeTitle: true)
    ),
    prefersLargeTitles: true
  )
}
