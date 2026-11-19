import UIKit

/// `UIScrollEdgeElementContainerInteraction` による実装（公開 API のみでの最善の再現）。
///
/// iOS 27.1 SDK における公開 API の全体は次の 2 プロパティです。
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
    //
    //    ナビゲーションバーが追跡するスクロールビューは `setContentScrollView(_:for:)` で明示する
    //    （DTS が提案した構成どおり）。UIKit は子のコレクションビューを自動で見つけるので、
    //    呼ばなくてもラージタイトルは折りたたまれ、座標も変わらない（iOS 27.3 シミュレータで実測）。
    addChild(listViewController)
    listViewController.view.frame = view.bounds
    listViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(listViewController.view)
    listViewController.didMove(toParent: self)
    setContentScrollView(listViewController.collectionView, for: .top)

    // 2. カスタムバーを safeArea 上端に固定する。
    //    `safeAreaLayoutGuide.topAnchor` はナビゲーションバーの下端を追う。ラージタイトルの折りたたみ、
    //    検索の起動・解除、バーの表示・非表示のいずれも、静止した状態ではバーの下端に一致する。
    //    ただし下へ引き伸ばしている間はバーだけが伸びて safeArea は変わらないため、このビューは
    //    元の位置に留まり、Level 3 や Level 5 でタイトルより上に取り残される。
    //    検索の解除やバーの表示・非表示のアニメーション中も、バーと一緒には動かない。
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
    //    設定するのはカスタムバー自身の高さだけで、ナビゲーションバーの高さは親の safeArea を
    //    通じて子に伝わる。そのためバーの高さが変わってもこの値は古くならない。
    //    手で直す必要があるのは、カスタムバー自身の高さを変えるときだけ。
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
