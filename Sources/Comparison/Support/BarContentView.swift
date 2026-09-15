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

  /// ピッカーの上下マージン。
  ///
  /// 上下を制約で留めることで、このビュー自身の縦の内容サイズが確定します。
  /// centerY だけで留めると内容サイズが 0 になり、palette がこのビューを
  /// `systemLayoutSizeFitting` で測ったときに高さが定まらず、
  /// ピッカーのガラス形状の角が崩れて描画されます。
  static let verticalMargin: CGFloat = 6

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
      segmentedControl.topAnchor.constraint(
        equalTo: topAnchor,
        constant: Self.verticalMargin
      ),
      segmentedControl.bottomAnchor.constraint(
        equalTo: bottomAnchor,
        constant: -Self.verticalMargin
      ),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
