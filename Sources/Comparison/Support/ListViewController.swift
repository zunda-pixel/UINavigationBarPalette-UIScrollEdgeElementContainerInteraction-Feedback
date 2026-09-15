import UIKit

/// 比較用のリスト画面。
///
/// `UICollectionViewController` のままにしてあるのは意図的です。Level 2 で示す通り、
/// `UIScrollEdgeElementContainerInteraction` 方式では `view` がコレクションビュー自体であるため、
/// カスタムバーを置くための兄弟ビューを追加できず、この画面を子ビューコントローラとして
/// 作り直す必要が生じます。palette 方式ではこの作り直しは不要です。
@available(iOS 18.0, *)
class ListViewController: UICollectionViewController {
  private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item.ID>
  private typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item>

  @ViewLoading private var repository: Repository
  @ViewLoading private var dataSource: DataSource

  private let titleText: String

  init(title: String = "Title") {
    self.titleText = title
    super.init(collectionViewLayout: UICollectionViewLayout())
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.collectionViewLayout = Self.makeLayout()
    title = titleText

    repository = Repository()
    dataSource = makeDataSource(for: collectionView)

    Task {
      await applyInitialSnapshot()
    }
  }

  private static func makeLayout() -> UICollectionViewLayout {
    let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    return UICollectionViewCompositionalLayout.list(using: configuration)
  }

  private func makeDataSource(for collectionView: UICollectionView) -> DataSource {
    let cellRegistration = CellRegistration { cell, _, item in
      var contentConfiguration = cell.defaultContentConfiguration()
      contentConfiguration.text = item.title
      cell.contentConfiguration = contentConfiguration
    }

    return DataSource(collectionView: collectionView) { [weak repository] collectionView, indexPath, id in
      guard let item = repository?.items.first(where: { $0.id == id }) else { return nil }
      return collectionView.dequeueConfiguredReusableCell(
        using: cellRegistration,
        for: indexPath,
        item: item
      )
    }
  }

  private func applyInitialSnapshot() async {
    var snapshot = dataSource.snapshot()
    snapshot.appendSections(Section.allCases)
    snapshot.appendItems(repository.items.map(\.id), toSection: .default)
    await dataSource.apply(snapshot, animatingDifferences: false)
  }
}

@available(iOS 18.0, *)
extension ListViewController {
  final class Repository {
    var items: [Item] = (1...100).map { Item(title: "Item \($0)") }
  }

  enum Section: Sendable, Hashable, CaseIterable {
    case `default`
  }

  struct Item: Hashable, Identifiable, Sendable {
    var id = UUID()
    var title: String
  }
}
