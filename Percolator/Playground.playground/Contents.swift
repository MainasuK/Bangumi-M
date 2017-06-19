//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let cellReuseIdentifer = "CMKTableViewCell"

// MARK: - Model
class CMKTableViewModel: DataProvider {
    typealias ItemType = (text: String, detail: String, image: UIImage)
    
    private weak var tableView: UITableView?
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }

    func numberOfSections() -> Int {
        return 5
    }
    
    func numberOfItems(in section: Int) -> Int {
        return 5
    }
    
    func item(at indexPath: IndexPath) -> ItemType {
        return ("Section - \(indexPath.section)", "Row - \(indexPath.row)", #imageLiteral(resourceName: "autolayout.png"))
    }
    
    func identifier(at indexPath: IndexPath) -> String {
        return cellReuseIdentifer
    }
    
}

// MARK: - View
class CMKTableViewCell: UITableViewCell {

    fileprivate var mainStackView: UIStackView!
    fileprivate var descriptionStackView: UIStackView!
    
    fileprivate var itemImageView = UIImageView()
    fileprivate var itemTextLabel = UILabel()
    fileprivate var itemDetailLabel = UILabel()
    
}

extension CMKTableViewCell: ConfigurableCell {
    typealias ItemType = CMKTableViewModel.ItemType

    func configure(with item: ItemType) {
        itemTextLabel.text = item.text
        itemDetailLabel.text = item.detail
        
        itemImageView.image = item.image
        itemImageView.contentMode = .scaleAspectFit
        
        descriptionStackView = UIStackView(arrangedSubviews: [itemTextLabel, itemDetailLabel])
        descriptionStackView.axis = .vertical
        descriptionStackView.distribution = .fill
        descriptionStackView.alignment = .fill
        descriptionStackView.spacing = 8.0
        descriptionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView = UIStackView(arrangedSubviews: [itemImageView, descriptionStackView])
        mainStackView.axis = .horizontal
        mainStackView.distribution = .fill
        mainStackView.alignment = .center
        mainStackView.spacing = 8.0
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStackView)
        setupLayout(with: item)
    }
    
    private func setupLayout(with item: ItemType) {
        itemImageView.widthAnchor.constraint(equalToConstant: item.image.size.width).isActive = true
        itemImageView.heightAnchor.constraint(equalToConstant: item.image.size.height).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
    }

}

// MARK: - Controller
class CMKTableViewController: UITableViewController {
    
    typealias Model = CMKTableViewModel
    typealias Cell = CMKTableViewCell
    
    fileprivate lazy var model: Model = {
        return CMKTableViewModel(tableView: self.tableView)
    }()
    fileprivate var dataSource: TableViewDataSource<Model, Cell>!
    
}

extension CMKTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = UIScreen.main.bounds
        
        title = "Table View"
        setupTableView()
        setupTableViewDataSource()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.frame)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(CMKTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifer)
    }
    
    private func setupTableViewDataSource() {
        dataSource = TableViewDataSource<Model, Cell>(model: model)
        tableView.dataSource = dataSource
    }
    
}

// MARK: - Helper

protocol DataProvider: class {
    
    associatedtype ItemType
    
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    
    func item(at indexPath: IndexPath) -> ItemType
    func identifier(at indexPath: IndexPath) -> String
    
}

protocol ConfigurableCell {
    associatedtype ItemType
    
    /// Configure cell with associatedtype
    func configure(with item: ItemType)
}

class DataSource<Model: DataProvider>: NSObject {
    
    weak var model: Model!
    
    required init(model: Model) {
        self.model = model
    }
    
}

class TableViewDataSource<Model: DataProvider, Cell: ConfigurableCell>: DataSource<Model>, UITableViewDataSource where Model.ItemType == Cell.ItemType, Cell: UITableViewCell {
    
    deinit {
        print("TableViewDataSource deinit")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = model.identifier(at: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Cell should be configurable")
        }
        
        cell.configure(with: model.item(at: indexPath))
        
        return cell
    }
    
}

// MARK: - Setup

let controller = CMKTableViewController()
let navigationController = UINavigationController(rootViewController: controller)

// Open Assistant Editor to interact with view
PlaygroundPage.current.liveView = navigationController
