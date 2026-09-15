import UIKit
import UIKitCorePrivate

/// `_UINavigationBarPalette` による実装（参照実装）。
///
/// palette は `UINavigationItem` が所有し、`_UINavigationBarLayoutParticipating`
/// （`-updateLayoutData:layoutWidth:`）として `UINavigationBar` が自身の一部としてレイアウトします。
/// そのため以下はすべてバー側が面倒を見ており、このクラスには一切の帳尻合わせがありません。
///
/// - セーフエリアへの算入（バーの高さに含まれる）
/// - ラージタイトル折りたたみ中の追従
/// - stacked 検索バーとの上下関係
/// - push / pop 時のクロスフェード
/// - iOS 27 のバー最小化への追従
@available(iOS 18.0, *)
final class PaletteViewController: ListViewController {
  private let scenario: Scenario

  init(_ scenario: Scenario) {
    self.scenario = scenario
    super.init(title: scenario.title)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // 実装はこの 3 行だけ。画面構造の変更も、インセットの手計算も不要。
    //
    // contentView にはピッカーを直接渡す。間にコンテナビューを挟むと、
    // ピッカーのガラス形状の角が崩れて描画される。
    // 左右の余白は palette 自身が `_contentViewMarginType` として持っている。
    let palette = _UINavigationBarPalette(contentView: FilterSegmentedControl())!
    palette.preferredHeight = scenario.barHeight
    navigationItem._bottomPalette = palette

    if let contentViewMarginType = scenario.contentViewMarginType {
      palette._contentViewMarginType = contentViewMarginType
    }

    if scenario.usesSearchController {
      navigationItem.searchController = UISearchController(searchResultsController: nil)
      navigationItem.preferredSearchBarPlacement = .stacked
    }

    if scenario.prefersLargeTitle {
      navigationItem.largeTitleDisplayMode = .always
    }

    if scenario.minimizesBarOnScrollDown, #available(iOS 27.0, *) {
      navigationItem.navigationBarMinimization.minimizationBehavior = .onScrollDown
      navigationItem.navigationBarMinimization.safeAreaAdjustment = .enabled
    }

    if scenario.showsPushButton {
      navigationItem.rightBarButtonItem = UIBarButtonItem(
        title: "Push",
        primaryAction: UIAction { [weak self] _ in
          guard let self else { return }
          var next = self.scenario
          next.title = "Pushed"
          self.navigationController?.pushViewController(PaletteViewController(next), animated: true)
        }
      )
    }
  }
}
