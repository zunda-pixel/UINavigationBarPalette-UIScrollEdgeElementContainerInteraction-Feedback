import SwiftUI
import UIKit

// MARK: - Level 5 — iOS 27 のバー最小化　✗ 実現できない
//
// やりたいこと:
//   iOS 27 で追加された `UINavigationItem.navigationBarMinimization` を有効にしたとき、
//   カスタムバーもバーと一緒に最小化してほしい。
//
//   ```swift
//   navigationItem.navigationBarMinimization.minimizationBehavior = .onScrollDown
//   navigationItem.navigationBarMinimization.safeAreaAdjustment = .enabled
//   ```
//
// 結果:
//   バー内部にいる palette は自動的に追従する。バーの外にある独立したコンテナビューは
//   この挙動に参加する手段がなく、バーだけが縮んでピッカーが取り残される。
//
//   iOS 27 でこの API が追加されたことで、両者の差はむしろ広がっている。
//
// 判定: **ギャップ。**
//
// 確認手順: バーが最小化されるまでスクロールダウンする。

/// Level 5 公開 API 版: バーだけが最小化し、ピッカーは取り残される。
@available(iOS 27.0, *)
#Preview("Lv5 Public ✗") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "Level 6", minimizesBarOnScrollDown: true)
    )
  )
}

/// Level 5 palette 版: バーと一緒に最小化する。
@available(iOS 27.0, *)
#Preview("Lv5 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "Level 6", minimizesBarOnScrollDown: true)
    )
  )
}
