import SwiftUI
import UIKit

// MARK: - Level 1 — スクロールエッジエフェクト　✅ 公開 API で実現できる
//
// やりたいこと:
//   スクロールビューの上に重ねたカスタムバーの背後で、システム標準の可変ブラーと
//   グラデーションがかかってほしい。
//
// 結果:
//   `UIScrollEdgeElementContainerInteraction` で完全に実現できる。コンテナの子要素
//   （ラベル・画像・コントロール）がエフェクトの形状に自動で反映されるところまで含めて、
//   これはまさにこの API のための用途である。
//
// 判定: **ギャップなし。** この Level については Apple の案内は正しい。
//
// 確認手順:
//   スクロールして、コンテンツがピッカーの背後を通るときにブラーとグラデーションが
//   かかることを確認する。静止状態ではコンテンツがバーの下から始まるため、
//   エフェクトはスクロールして初めて見える。
//
// 備考:
//   この Level では palette を使う理由がないため、palette 版のプレビューは用意していない。
//   同じ構成の palette 版を見たい場合は `Lv2 Palette` を参照。
//   Level 2 は、この結果を得るために公開 API 側が何を払っているかを見る Level である。

/// Level 1: エッジエフェクトが機能することの確認。
@available(iOS 26.0, *)
#Preview("Lv1 Public ✅") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(Scenario(title: "Level 1"))
  )
}
