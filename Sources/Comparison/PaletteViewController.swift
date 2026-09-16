import UIKit
import UIKitCorePrivate

/// `_UINavigationBarPalette` による実装（参照実装）。
///
/// palette は `UINavigationItem` が所有し、`_UINavigationBarLayoutParticipating`
/// （`-updateLayoutData:layoutWidth:`）として `UINavigationBar` が自身の一部としてレイアウトします。
/// そのため以下はすべてバー側が面倒を見ており、このクラスには一切の帳尻合わせがありません。
///
/// - セーフエリアへの算入（バーの高さに含まれる、Level 2）
/// - ラージタイトル折りたたみ中の追従（Level 3）
/// - stacked 検索バーとの上下関係（Level 4）
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

    // 実装はこれだけ。画面構造の変更も、インセットの手計算も不要。
    //
    // palette は contentView を横いっぱいに広げるため、左右の余白は contentView 側で与える。
    // `_contentViewMarginType` という非公開プロパティがあるが、値 0〜5 を試しても
    // 観測可能な変化はなかった（詳細は README の「調査メモ」を参照）。
    if scenario.usesBottomPalette {
      let bottomPalette = _UINavigationBarPalette(contentView: BarContentView())!
      bottomPalette.preferredHeight = scenario.barHeight
      navigationItem._bottomPalette = bottomPalette
    }

    if scenario.usesSearchController {
      navigationItem.searchController = UISearchController(searchResultsController: nil)
      navigationItem.preferredSearchBarPlacement = .stacked
    }

    // palette はナビゲーションバーの中に上下 2 つのスロットを持つ。
    // 公開 API 側にはどちらの相当物もない。
    if scenario.usesTopPalette {
      let topPalette = _UINavigationBarPalette(
        contentView: BarContentView(items: ["Newest", "Oldest"])
      )!
      topPalette.preferredHeight = scenario.barHeight
      navigationItem._topPalette = topPalette
    }

    if scenario.prefersLargeTitle {
      navigationItem.largeTitleDisplayMode = .always
    }
  }
}
