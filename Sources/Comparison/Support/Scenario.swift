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
  ///
  /// 内訳は `BarMetrics` を参照。
  var barHeight: CGFloat = BarMetrics.barHeight

  /// `prefersLargeTitles` を有効にするか。バーの高さがスクロールに応じて連続的に変化します。
  var prefersLargeTitle: Bool = false

  /// `preferredSearchBarPlacement = .stacked` の検索バーを追加するか。
  var usesSearchController: Bool = false

  /// 検索バーの上側のスロット（`_topPalette`）にもピッカーを置くか。
  ///
  /// この項目は palette 版にしか効きません。公開 API にはタイトル領域と stacked 検索バーの
  /// 「間」にビューを置く手段がないためです。効かないこと自体が Level 4 の論点です。
  var usesTopPalette: Bool = false

  /// iOS 27 の `UINavigationItem.navigationBarMinimization` を有効にするか。
  var minimizesBarOnScrollDown: Bool = false

  /// 遷移を試すための Push ボタンを出すか。
  var showsPushButton: Bool = false

  /// ピッカーに並べる項目。
  ///
  /// push した先では別の項目に切り替わります。両画面で中身が同じだと、
  /// ピッカーがバーと一緒にクロスフェードしたのか、ビューコントローラの view と一緒に
  /// 横に滑ったのかを見分けられないためです（Level 5）。
  var pickerItems: [String] = Scenario.firstScreenItems

  static let firstScreenItems = ["All", "Favorites", "Recent"]
  static let secondScreenItems = ["Nearby", "Worldwide"]

  /// push した先に渡す設定。タイトルとピッカーの中身が入れ替わります。
  func pushed() -> Scenario {
    var next = self
    let isFirst = pickerItems == Scenario.firstScreenItems
    next.title = isFirst ? "Second" : "Third"
    next.pickerItems = isFirst ? Scenario.secondScreenItems : Scenario.firstScreenItems
    return next
  }
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
