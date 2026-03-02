import Apollo
import UIKit

/// TODOS:
/// - Image watermarking

class HomeViewController: UIViewController {
    lazy var client: ApolloClient = createClient(
        accessToken: "RSTZZwesdCSoDgpBlqGw",
        url: URL(string: "https://takehome.graphql.copilot.money")!
    )
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width / 2, height: view.frame.width / 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCollectionViewCell")
        
        return collectionView
    }()
    
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        bar.placeholder = "Search"
        return bar
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    var fetchedBirds: [LocalBird] = []
    var filteredBirds: [LocalBird] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        fetchData()
    }
    
    private func fetchData() {
        activityIndicator.startAnimating()
        client.fetch(query: GraphQL.BirdsQuery()) { result in
            do {
                let fetchResult = try result.get()
                if let data = fetchResult.data {
                    let birds = data.birds.map { $0.toLocalBird() }
                    self.fetchedBirds = birds
                    self.filteredBirds = birds
                    
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredBirds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as? HomeCollectionViewCell else {
            assertionFailure("dequeue error")
            return UICollectionViewCell()
        }
        
        guard indexPath.row < filteredBirds.count else {
            assertionFailure("index error")
            return UICollectionViewCell()
        }
        
        let bird = filteredBirds[indexPath.row]
        cell.setBird(bird)
        
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bird = filteredBirds[indexPath.row]
        
        let detailViewController = BirdDetailViewController()
        detailViewController.client = client
        detailViewController.bird = bird
        detailViewController.sheetPresentationController?.prefersGrabberVisible = true
        
        present(detailViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationItem.titleView?.endEditing(true)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredBirds = fetchedBirds.filter { bird in
            let candidates = bird.latinName.split(separator: " ") + bird.englishName.split(separator: " ")
            
            for candidate in candidates {
                if candidate.lowercased().hasPrefix(searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) {
                    return true
                }
            }
            return false
        }
        
        collectionView.reloadData()
    }
}

