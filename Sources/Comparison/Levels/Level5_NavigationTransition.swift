import SwiftUI
import UIKit

// MARK: - Level 5 — ナビゲーション遷移（push / pop）　✗ 実現できない
//
// やりたいこと:
//   画面ごとに異なるカスタムバーを持ち、push / pop でタイトルやバーボタンと一緒に
//   クロスフェードしてほしい。対話的な戻るジェスチャの途中でも追従してほしい。
//
// 結果:
//   palette は `UINavigationItem` が所有するため画面ごとに保持でき、バーのトランジションの
//   一部として扱われる。公開 API 版のカスタムバーは特定のビューコントローラの view の
//   サブビューなので、バーの遷移とビューコントローラの遷移という無関係な 2 つの
//   アニメーションになり、ピッカーだけが横に滑っていく。
//
// 判定: **ギャップ。**
//
// 確認手順:
//   1. Push をタップする。
//   2. 画面端から戻るジェスチャを**ゆっくり**ドラッグし、途中で止める。
//   3. タイトル・バーボタンとピッカーの動きが揃っているかを見る。

/// Level 5 公開 API 版: ピッカーだけが view と一緒に横に滑る。
@available(iOS 26.0, *)
#Preview("Lv5 Public ✗") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "Level 5", showsPushButton: true)
    )
  )
}

/// Level 5 palette 版: タイトル・バーボタンと一緒にクロスフェードする。
@available(iOS 18.0, *)
#Preview("Lv5 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "Level 5", showsPushButton: true)
    )
  )
}
