import UIKit

/// `UIScrollEdgeElementContainerInteraction` による実装（公開 API のみでの最善の再現）。
///
/// iOS 27.0 SDK における公開 API の全体は次の 2 プロパティです。
///
/// ```objc
/// @interface UIScrollEdgeElementContainerInteraction : NSObject <UIInteraction>
/// @property (nonatomic, nullable, weak) UIScrollView *scrollView;
/// @property (nonatomic) UIRectEdge edge;
/// @end
/// ```
///
/// ヘッダ自身が用途を "Any descendants of this view that should affect the shape of the edge
/// effect ... will automatically do so." と説明している通り、これはスクロールエッジエフェクトの
/// 形状にビューを参加させるための仕組みです。その役割については完全に機能します（Level 1）。
///
/// 一方 palette がバー内部にいることで得ていたものは、すべてこのクラス側の手作業になります。
/// 以下の `viewDidLoad` のコメント 1〜4 が、その手作業の内訳です。
final class PublicAPIViewController: UIViewController {
  private let scenario: Scenario
  private let listViewController: ListViewController
  private let barContainerView = UIView()
  private let barContentView = BarContentView()

  init(_ scenario: Scenario) {
    self.scenario = scenario
    self.listViewController = ListViewController(title: scenario.title)
    super.init(nibName: nil, bundle: nil)
    title = scenario.title
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground

    // 1. リストを子ビューコントローラとして作り直す。
    //    `UICollectionViewController` は `view` がコレクションビュー自体なので、
    //    カスタムバーを置く兄弟ビューを追加できない。palette ではこの変更は不要。
    addChild(listViewController)
    listViewController.view.frame = view.bounds
    listViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(listViewController.view)
    listViewController.didMove(toParent: self)

    // 2. カスタムバーを safeArea 上端に固定する。
    //    `safeAreaLayoutGuide.topAnchor` はナビゲーションバーの下端を追うが、これを解決するのは
    //    このビューコントローラのレイアウトパスであり、バー自身のレイアウトではない。
    //    バーの高さが動くケース（Level 3 のラージタイトル）でラグが出るのはこのため。
    barContainerView.translatesAutoresizingMaskIntoConstraints = false
    barContentView.translatesAutoresizingMaskIntoConstraints = false
    barContainerView.addSubview(barContentView)
    view.addSubview(barContainerView)

    NSLayoutConstraint.activate([
      barContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      barContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      barContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      barContainerView.heightAnchor.constraint(equalToConstant: scenario.barHeight),

      // 余白を palette 版と揃えるため、ピッカーは共通の BarContentView に入れる。
      barContentView.topAnchor.constraint(equalTo: barContainerView.topAnchor),
      barContentView.leadingAnchor.constraint(equalTo: barContainerView.leadingAnchor),
      barContentView.trailingAnchor.constraint(equalTo: barContainerView.trailingAnchor),
      barContentView.bottomAnchor.constraint(equalTo: barContainerView.bottomAnchor),
    ])

    // 3. 公開 API が提供するのはここだけ。そしてこの役割については正しく機能する。
    let interaction = UIScrollEdgeElementContainerInteraction()
    interaction.scrollView = listViewController.collectionView
    interaction.edge = .top
    barContainerView.addInteraction(interaction)

    // 4. カスタムバーの高さはナビゲーションバーからは見えないので、インセットを手で押し下げる。
    //    この定数は、バー自身の高さが変わるたびに黙って陳腐化する。
    //    そして「バーの高さが変わった」ことを知る公開 API はない。
    listViewController.additionalSafeAreaInsets.top = scenario.barHeight

    if scenario.usesSearchController {
      navigationItem.searchController = UISearchController(searchResultsController: nil)
      navigationItem.preferredSearchBarPlacement = .stacked
    }

    if scenario.prefersLargeTitle {
      navigationItem.largeTitleDisplayMode = .always
    }
  }
}
