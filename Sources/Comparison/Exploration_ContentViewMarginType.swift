import SwiftUI
import UIKit
import UIKitCorePrivate

// MARK: - 調査用: `_UINavigationBarPalette._contentViewMarginType`
//
// palette は `contentView` を横いっぱいに広げるため、ピッカーに左右の余白を付けるには
// この非公開プロパティを使う必要があります。
//
// ```objc
// @property (nonatomic) unsigned long long _contentViewMarginType;
// - (void)_setContentViewMarginType:(unsigned long long)type;
// ```
//
// 取りうる値はヘッダからは分からないため、以下のプレビューで実際に確認します。
// 妥当な値が判明したら `Scenario.contentViewMarginType` の既定値に反映し、
// 公開 API 版の `BarContentView.horizontalMargin` をその余白に合わせたうえで、
// このファイルは削除します。
//
// なお `_contentViewMarginType` の存在自体が、palette が余白の概念を内蔵していることの
// 裏付けであり、FB22730304 で公開を求める範囲の材料にもなります。

@available(iOS 18.0, *)
@MainActor
private func makeMarginTypeProbe(_ type: UInt64) -> UINavigationController {
  var scenario = Scenario(title: "marginType \(type)")
  scenario.contentViewMarginType = type
  return makeNavigationController(rootViewController: PaletteViewController(scenario))
}

@available(iOS 18.0, *)
#Preview("Explore: marginType 0") { makeMarginTypeProbe(0) }

@available(iOS 18.0, *)
#Preview("Explore: marginType 1") { makeMarginTypeProbe(1) }

@available(iOS 18.0, *)
#Preview("Explore: marginType 2") { makeMarginTypeProbe(2) }

@available(iOS 18.0, *)
#Preview("Explore: marginType 3") { makeMarginTypeProbe(3) }
