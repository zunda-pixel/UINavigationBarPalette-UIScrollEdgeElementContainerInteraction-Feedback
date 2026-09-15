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
//   ここでは palette を使う理由がないため、palette 側のプレビューは用意していない。

/// Level 1: コンテンツはカスタムバーの下を流れる（オーバーレイバー）。
/// エッジエフェクトがバーの背後に正しくかかっていることを確認する。
@available(iOS 26.0, *)
#Preview("Lv1 Public ✅") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "Level 1", occupiesLayoutSpace: false)
    )
  )
}
