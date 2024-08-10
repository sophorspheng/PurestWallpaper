////
////  FolderViewController.swift
////  Note001
////
////  Created by Sophors Pheng on 7/20/24.
////
//
//import UIKit
//import CoreData
//import NVActivityIndicatorView
//import NVActivityIndicatorViewExtended
//struct Folders {
//    var title: String // The title of the folder
//    var notes: [(String, String)] // Array of notes where each note is a tuple (title, detail)
//}
//class FolderViewController: UIViewController,NVActivityIndicatorViewable {
//    var note : Notes?
//    var folders: [Folder] = []
//    private let presentingIndicatorTypes = {
//          return NVActivityIndicatorType.allCases.filter { $0 != .blank }
//      }()
//    lazy var fetchedResultsController: NSFetchedResultsController = {
//               let context = CoreDataManager.shared.context
//               // Create a fetch request and sort descriptor for the entity to display
//               // in the table view.
//               let fetchRequest: NSFetchRequest<Folder> = Folder
//                   .fetchRequest()
//               let sortDescriptor = NSSortDescriptor(key: "folderName", ascending: true)
//               fetchRequest.sortDescriptors = [sortDescriptor]
//
//
//               // Initialize the fetched results controller with the fetch request and
//               // managed object context.
//               return NSFetchedResultsController(
//                   fetchRequest: fetchRequest,
//                   managedObjectContext: context,
//                   sectionNameKeyPath: nil,
//                   cacheName: nil)
//           }()
//       var cats = ["P",
//                   "A"
//                   ,"B","C","D","E","F","G"]
//
//    var button : UIButton =  {
//       let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.layer.shadowOpacity = 90
//        button.tintColor = UIColor.white
//        button.setImage(UIImage(named: "14.jpeg"), for: .normal)
//        return  button
//    }()
//    
//    var collectionView : UICollectionView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor  = .systemMint
//        let rightButton = UIBarButtonItem(image: UIImage(systemName: "plus.rectangle.on.folder.fill"), style: .plain, target: self, action: #selector(addFolder))
//        rightButton.tintColor = UIColor.red
//        navigationItem.rightBarButtonItem = rightButton
//        title = "Folder List"
////        self.view.backgroundColor = UIColor(red: CGFloat(237 / 255.0), green: CGFloat(85 / 255.0), blue: CGFloat(101 / 255.0), alpha: 1)
//        let layout = UICollectionViewFlowLayout()
//               collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//               view.addSubview(collectionView)
//               collectionView.backgroundColor = .white
//               collectionView.translatesAutoresizingMaskIntoConstraints = false
//               collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
//               collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//               collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 5).isActive = true
//               collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
//               collectionView.backgroundColor = .white
//               collectionView.dataSource = self
//               collectionView.delegate = self
//               collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "Cell")
//
//        
//        view.addSubview(button)
//        button.addTarget(self, action: #selector(buttons), for: .touchUpInside)
//        button.snp.makeConstraints { make in
//            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
//            make.right.equalTo(view.safeAreaLayoutGuide).inset(30)
//            make.height.equalTo(50)
//            make.width.equalTo(50)
//        }
//    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        let safeArea = view.safeAreaLayoutGuide.layoutFrame
//
//        var cols = 4
//        var rows = Int(ceil(Double(presentingIndicatorTypes.count) / 4.0))
//        if safeArea.width > safeArea.height {
//            //Landscape
//            cols = Int(ceil(Double(presentingIndicatorTypes.count) / 4.0))
//            rows = 4
//        }
//        let cellWidth = Int(safeArea.width / CGFloat(cols))
//        let cellHeight = Int(safeArea.height / CGFloat(rows))
//
//        self.view.subviews.forEach {
//            $0.removeFromSuperview()
//        }
//
//        for (index, indicatorType) in presentingIndicatorTypes.enumerated() {
//            let x = index % cols * cellWidth + Int(safeArea.origin.x)
//            let y = index / cols * cellHeight + Int(safeArea.origin.y)
//            let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
//            let activityIndicatorView = NVActivityIndicatorView(frame: frame,
//                                                                type: indicatorType)
//            let animationTypeLabel = UILabel(frame: frame)
//
//            
//
//            activityIndicatorView.padding = 20
//            if indicatorType == NVActivityIndicatorType.orbit {
//                activityIndicatorView.padding = 0
//            }
////            self.view.addSubview(activityIndicatorView)
//            self.view.addSubview(animationTypeLabel)
//            activityIndicatorView.startAnimating()
//
//            let button = UIButton(frame: frame)
//            button.tag = index
//            button.addTarget(self,
//                             action: #selector(addFolder(_:)),
//                             for: .touchUpInside)
//            self.view.addSubview(button)
//        }
//    }
//    @objc func addFolder(_ sender: UIButton){
//        let size = CGSize(width: 30, height: 30)
//        let selectedIndicatorIndex = sender.tag
//        let indicatorType = presentingIndicatorTypes[29]
//
//        startAnimating(size, message: "Loading...", type: indicatorType, fadeInAnimation: nil)
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
//            NVActivityIndicatorPresenter.sharedInstance.setMessage("Authenticating...")
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
//            self.stopAnimating(nil)
//        }
//    }
//    func didCreateFolder(withTitle title: String) {
//       
//        if note != nil {
//            note?.titles = title
//            
//            
//            
//        } else {
//            let note = Notes(context: CoreDataManager.shared.context)
//            note.titles = title
//            
//            note.noteID = UUID().uuidString
//        }
//        do {
//            try CoreDataManager.shared.save()
//            let alertController = UIAlertController(title: "Warning", message: "Your record have saved successfully!", preferredStyle: .alert)
//            let alertAction = UIAlertAction(title: "Done", style: .destructive)
//            alertController.addAction(alertAction)
//            navigationController?.popViewController(animated: true)
//            present(alertController, animated: true)
//            
//        } catch {
//            print("error")
//        }
//
//    }
//    @objc func buttons(){
//        let alert = UIAlertController(title: "New Folder", message: "Enter folder name", preferredStyle: .alert) // Create an alert to enter a new folder name
//        alert.addTextField { textField in
//            textField.placeholder = "Folder name"
//        }
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil)) // Add a cancel action to the alert
//        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
//            if let folderName = alert.textFields?.first?.text, !folderName.isEmpty {
//                self?.didCreateFolder(withTitle: folderName) // Create a new folder if the text field is not empty
//            }
//        }))
//        present(alert, animated: true, completion: nil) // Present the alert
//           
////            let title = textLabel.text!
////            if(textLabel.text == ""){
////                
////                let alertController = UIAlertController(title: "Warning", message: "Cannot be empty!", preferredStyle: .alert)
////                let alertAction = UIAlertAction(title: "Close", style: .destructive)
////                alertController.addAction(alertAction)
////                present(alertController, animated: true)
////            }else
////            if note != nil {
////                note?.titles = title
////                
////                
////                
////            } else {
////                let note = Notes(context: CoreDataManager.shared.context)
////                note.titles = title
////                
////                note.noteID = UUID().uuidString
////            }
////            do {
////                try CoreDataManager.shared.save()
////                let alertController = UIAlertController(title: "Warning", message: "Your record have saved successfully!", preferredStyle: .alert)
////                let alertAction = UIAlertAction(title: "Done", style: .destructive)
////                alertController.addAction(alertAction)
////                navigationController?.popViewController(animated: true)
////                present(alertController, animated: true)
////                
////            } catch {
////                print("error")
////            }
//
//            
//            
//       
//    }
//}
//extension FolderViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return fetchedResultsController.sections?.count ?? 0
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard let section = fetchedResultsController.sections?[section] else { return 0 }
//                return section.numberOfObjects
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCell
//        let object = fetchedResultsController.object(at: indexPath)
//
//        cell.catImageView.text = object.folderName
//        
//        
//        return cell
//        
//       
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width/2 - 10, height: 120)
//    }
//    ///Selectdid
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        print("clicked\(indexPath.item)")
//        
//        
////        let object = fetchedResultsController.object(at: indexPath)
////        let vc = NoteViewNew()
////        let nav = UINavigationController(rootViewController: vc)
////        vc.folder = object
////        present(nav, animated: true)
//        
//    }
//    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        let object = fetchedResultsController.object(at: indexPath)
//        CoreDataManager.shared.context.delete(object)
//        try? CoreDataManager.shared.save()
//        return true
//    }
//   
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
//            let object = self.fetchedResultsController.object(at: indexPath)
//            let delete = UIAction(title: "Delete", attributes: .destructive) { _ in
//                self.cats.remove(at: indexPath.item)
//                CoreDataManager.shared.context.delete(object)
//                try? CoreDataManager.shared.save()
//                collectionView.reloadData()
//                
//            }
//            
//            
//            return UIMenu( children: [delete])
//        }
//        
//    }
//    
//}
//class CustomCell: UICollectionViewCell{
//    let catImageView = UILabel()
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addSubview(catImageView)
//
//
//        catImageView.translatesAutoresizingMaskIntoConstraints = false
//        catImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        catImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        catImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        catImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        catImageView.layer.cornerRadius = 10
//        catImageView.layer.masksToBounds = true
//        catImageView.backgroundColor = .systemPurple
//        catImageView.textAlignment = .center
//        catImageView.textColor = .white
//
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//extension FolderViewController : NSFetchedResultsControllerDelegate{
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        collectionView.reloadData()
//    }
//   
//}
