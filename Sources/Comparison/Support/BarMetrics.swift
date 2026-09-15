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

  /// ピッカーの高さ。
  ///
  /// `UISegmentedControl` の標準高さは 32pt ですが、ここでは意図的に 44pt にしています。
  /// この高さでは palette 版と公開 API 版で選択中セグメントの形が変わり、
  /// contentView が palette 側のスタイルで描画されていることが目に見える形になります
  /// （Level 2 を参照）。
  ///
  /// 高さを与えずにコンテナいっぱいまで引き伸ばすと、高さが安定せず描画も崩れます。
  static let controlHeight: CGFloat = 44

  /// カスタムバー全体の高さ。
  static let barHeight: CGFloat = controlHeight + topMargin + bottomMargin
}
