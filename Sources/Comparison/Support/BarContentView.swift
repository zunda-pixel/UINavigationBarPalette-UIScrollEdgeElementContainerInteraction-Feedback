import UIKit

/// ピッカーに左右マージンを与えるコンテナ。
///
/// palette は `contentView` を横いっぱいに広げるため、マージンはこちら側で与える必要があります。
/// palette 版と公開 API 版で余白を完全に揃えるため、両者ともこのビューを経由します。
/// Level 2 の「見た目は一致する」という主張は、この共通化によって担保されています。
@available(iOS 13.0, *)
final class BarContentView: UIView {
  /// ピッカーの左右マージン。`insetGrouped` リストのカードと揃えています。
  static let horizontalMargin: CGFloat = 20

  let segmentedControl = FilterSegmentedControl()

  init() {
    super.init(frame: .zero)

    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    addSubview(segmentedControl)

    NSLayoutConstraint.activate([
      segmentedControl.leadingAnchor.constraint(
        equalTo: leadingAnchor,
        constant: Self.horizontalMargin
      ),
      segmentedControl.trailingAnchor.constraint(
        equalTo: trailingAnchor,
        constant: -Self.horizontalMargin
      ),
      segmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
