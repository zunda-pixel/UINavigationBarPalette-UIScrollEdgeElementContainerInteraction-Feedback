import CoreGraphics

/// カスタムバーの寸法。palette 版と公開 API 版がここだけを参照します。
///
/// 両者の余白が構造的に一致することを、この 1 箇所で担保しています。
enum BarMetrics {
  /// ピッカーの左右マージン。`insetGrouped` リストのカードと揃えています。
  static let horizontalMargin: CGFloat = 20

  /// ピッカーの上マージン。
  static let topMargin: CGFloat = 8

  /// ピッカーの下マージン。そのままピッカーとコンテンツの間の隙間になります。
  static let bottomMargin: CGFloat = 12

  /// `UISegmentedControl` の標準高さ。
  ///
  /// これを与えずにコンテナの高さいっぱいまで引き伸ばすと、
  /// カプセルの角が崩れて描画されます。
  static let controlHeight: CGFloat = 32

  /// カスタムバー全体の高さ。
  static let barHeight: CGFloat = controlHeight + topMargin + bottomMargin
}
