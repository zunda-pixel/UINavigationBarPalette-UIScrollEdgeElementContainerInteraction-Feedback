import UIKit

/// ナビゲーションバー直下に置きたいピッカー。
///
/// Music / Photos / Mail / Fitness が検索フィールドの直下に出すフィルタと同じ役割のコントロールです。
@available(iOS 13.0, *)
final class FilterSegmentedControl: UISegmentedControl {
  init() {
    super.init(items: ["All", "Favorites", "Recent"])
    selectedSegmentIndex = 0
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
