import UIKit

/// ピッカーに余白を与えるコンテナ。
///
/// palette は `contentView` をバーの幅いっぱいに広げるため、余白はこちら側で与える必要があります。
/// palette 版と公開 API 版で余白を完全に揃えるため、両者ともこのビューを経由します。
///
/// 上下も制約で留めているのは、このビュー自身の縦の内容サイズを確定させるためです。
/// centerY だけで留めるとピッカーがコンテナの高さいっぱいまで引き伸ばされ、
/// カプセルの角が崩れて描画されます。
@available(iOS 13.0, *)
final class BarContentView: UIView {
  let segmentedControl = FilterSegmentedControl()

  init() {
    super.init(frame: .zero)

    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    addSubview(segmentedControl)

    NSLayoutConstraint.activate([
      segmentedControl.leadingAnchor.constraint(
        equalTo: leadingAnchor,
        constant: BarMetrics.horizontalMargin
      ),
      segmentedControl.trailingAnchor.constraint(
        equalTo: trailingAnchor,
        constant: -BarMetrics.horizontalMargin
      ),
      segmentedControl.topAnchor.constraint(
        equalTo: topAnchor,
        constant: BarMetrics.topMargin
      ),
      segmentedControl.heightAnchor.constraint(
        equalToConstant: BarMetrics.controlHeight
      ),
      segmentedControl.bottomAnchor.constraint(
        equalTo: bottomAnchor,
        constant: -BarMetrics.bottomMargin
      ),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
