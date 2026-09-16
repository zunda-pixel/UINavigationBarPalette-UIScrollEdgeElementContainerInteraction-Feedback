import SwiftUI
import UIKit

// MARK: - Level 5 — ナビゲーション遷移（push / pop）　△ 要手動確認
//
// やりたいこと:
//   画面ごとに異なるカスタムバーを持ち、push / pop や対話的な戻るジェスチャの最中も
//   バーの内容として扱われてほしい。
//
// API から言えること（確認済み）:
//   palette は `UINavigationItem` が所有する。つまりバーの内容として画面ごとに保持され、
//   バーのトランジションの対象になる。公開 API 版のカスタムバーは特定のビューコントローラの
//   view のサブビューでしかないため、view と一緒に移動する以外の選択肢がない。
//   この所有関係の違いはヘッダから確認できる。
//
// 実機で確認できたこと:
//   公開 API 版で push の最中を撮影したところ、**2 つのピッカーが画面上に並んだ**。
//   前の画面の "All / Favorites" が左へ抜けていき、次の画面の "Nearby" が右から入ってくる
//   （`scratchpad/marginprobe/shots/lv5/slow-public-2-band.png`）。
//
// まだ確認できていないこと:
//   同じ進行度での palette 版のフレームを撮れていない。simctl では遷移中の任意の時点を
//   狙って撮るのが難しく、`layer.speed` によるスローダウンも遷移には効かなかった。
//
//   また iOS 26 以降の push はカード型の遷移で、新しい画面がバーごと滑り込んでくる。
//   そのため push については、両者の見た目の差は小さい可能性がある。
//   差が明確に出るのは対話的な戻るジェスチャを途中で止めたときだと考えられるが、
//   これは手で操作して確認する必要がある。
//
// 判定: **構造上の違いは確実。見た目の差は手動確認が必要。**
//   この Level を FB / CLS の証拠として使う場合は、先に画面収録を取ること。
//
// 確認手順:
//   1. Push をタップする。
//   2. 画面端から戻るジェスチャを**ゆっくり**ドラッグし、画面の半分あたりで止める。
//   3. ピッカーが 1 つに見えるか、2 つ並んで見えるかを両者で比べる。
//
// 備考:
//   画面ごとにピッカーの中身を変えてある（"All / Favorites / Recent" と
//   "Nearby / Worldwide"）。両画面で同じ中身だと、バーと一緒に扱われたのか
//   view と一緒に滑ったのかを見分けられないため。

/// Level 5 公開 API 版: カスタムバーは view のサブビュー。
@available(iOS 26.0, *)
#Preview("Lv5 Public △") {
  makeNavigationController(
    rootViewController: PublicAPIViewController(
      Scenario(title: "First", showsPushButton: true)
    )
  )
}

/// Level 5 palette 版: カスタムバーは `UINavigationItem` が所有する。
@available(iOS 18.0, *)
#Preview("Lv5 Palette") {
  makeNavigationController(
    rootViewController: PaletteViewController(
      Scenario(title: "First", showsPushButton: true)
    )
  )
}
