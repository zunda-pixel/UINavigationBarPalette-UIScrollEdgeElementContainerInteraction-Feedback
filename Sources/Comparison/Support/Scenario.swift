import UIKit

/// 両実装に同じ条件を与えるための設定。
///
/// palette 版 (`PaletteViewController`) と公開 API 版 (`PublicAPIViewController`) は
/// この同一の `Scenario` を受け取ります。各 Level のプレビューは、どの項目を有効にしたかだけが違います。
@available(iOS 18.0, *)
struct Scenario: Sendable {
  /// ナビゲーションバーのタイトル。
  var title: String = "Title"

  /// カスタムバー（ピッカーを載せる領域）の高さ。
  var barHeight: CGFloat = 44

  /// カスタムバーの分だけコンテンツを押し下げるか。
  ///
  /// `false` のとき、コンテンツはカスタムバーの下を流れます（Level 1 のオーバーレイバー）。
  /// `true` のとき、カスタムバーはレイアウト上の領域を占有します。palette は常に占有するため
  /// この項目は公開 API 版にのみ影響します。
  var occupiesLayoutSpace: Bool = true

  /// `prefersLargeTitles` を有効にするか。バーの高さがスクロールに応じて連続的に変化します。
  var prefersLargeTitle: Bool = false

  /// `preferredSearchBarPlacement = .stacked` の検索バーを追加するか。
  var usesSearchController: Bool = false

  /// iOS 27 の `UINavigationItem.navigationBarMinimization` を有効にするか。
  var minimizesBarOnScrollDown: Bool = false

  /// 遷移を試すための Push ボタンを出すか。
  var showsPushButton: Bool = false
}

@available(iOS 18.0, *)
@MainActor
func makeNavigationController(
  rootViewController: UIViewController,
  prefersLargeTitles: Bool = false
) -> UINavigationController {
  let navigationController = UINavigationController(rootViewController: rootViewController)
  navigationController.navigationBar.prefersLargeTitles = prefersLargeTitles
  return navigationController
}
