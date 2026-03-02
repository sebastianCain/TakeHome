//
//  BirdDetailViewController.swift
//  TakeHome
//
//  Created by Sebastian Cain on 3/1/26.
//

import Apollo
import UIKit

class BirdDetailViewController: UIViewController {
    
    var client: ApolloClient!
    var bird: LocalBird!
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = bird.latinName
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var noteInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        textField.textColor = .black
        textField.placeholder = NSLocalizedString("Add a note", comment: "")
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()
    
    lazy var stackSpacer = UIView()
    
    lazy var notesHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = NSLocalizedString("Community Notes", comment: "")
        return label
    }()
    
    lazy var notesScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var notesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()
    
    func notesLabel(note: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = note
        return label
    }
    
    lazy var addNoteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("add a note", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(addNoteTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isUserInteractionEnabled = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.addSubview(activityIndicator)
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(noteInputField)
        contentStackView.addArrangedSubview(stackSpacer)
        contentStackView.addArrangedSubview(notesHeaderLabel)
        
        // Hide input by default
        noteInputField.isHidden = true
        
        notesScrollView.addSubview(notesStackView)
        contentStackView.addArrangedSubview(notesScrollView)
        
        view.addSubview(contentStackView)
        view.addSubview(addNoteButton)
        
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            contentStackView.bottomAnchor.constraint(equalTo: addNoteButton.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            notesStackView.topAnchor.constraint(equalTo: notesScrollView.topAnchor),
            notesStackView.bottomAnchor.constraint(equalTo: notesScrollView.bottomAnchor),
            notesStackView.leadingAnchor.constraint(equalTo: notesScrollView.leadingAnchor),
            notesStackView.trailingAnchor.constraint(equalTo: notesScrollView.trailingAnchor),
            
            addNoteButton.heightAnchor.constraint(equalToConstant: 95),
            addNoteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            addNoteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addNoteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.topAnchor.constraint(equalTo: imageView.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
        ])
        
        loadImage()
        refreshNotes()
    }
    
    private func loadImage() {
        activityIndicator.startAnimating()
        if let imageUrl = URL(string: bird.imageUrl) {
            Task {
                let image = try await ImageLoader.shared.load(url: imageUrl)
                
                await MainActor.run {
                    self.imageView.image = image
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    @objc func addNoteTapped() {
        noteInputField.becomeFirstResponder()
        updateInputFocused(true)
    }
    
    private func updateInputFocused(_ focused: Bool) {
        noteInputField.isHidden = !focused
        stackSpacer.isHidden = !focused
        notesHeaderLabel.isHidden = focused
        notesScrollView.isHidden = focused
    }
    
    private func submitNote(text: String) {
        client.perform(
            mutation: GraphQL.AddNoteMutation(
                birdId: bird.id,
                comment: text,
                timestamp: (bird.notes.last?.timestamp ?? 0) + 1
                // Int(Date.now.timeIntervalSince1970 * 1000) fails GraphQL with Int32 error, use simple increment for now
            ),
            resultHandler: { result in
                do {
                    _ = try result.get()
                    
                    self.noteInputField.resignFirstResponder()
                    self.updateInputFocused(false)
                    self.noteInputField.text = nil
                    
                    self.refreshNotes()
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        )
    }
    
    private func refreshNotes() {
        client.fetch(query: GraphQL.BirdQuery(id: bird.id), cachePolicy: .fetchIgnoringCacheCompletely) { result in
            do {
                let fetchResult = try result.get()
                if let data = fetchResult.data, let bird = data.bird {
                    self.bird = bird.toLocalBird()
                    
                    self.refreshStackView()
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func refreshStackView() {
        print(bird.notes)
        
        for view in notesStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for note in bird.notes {
            let noteLabel = notesLabel(note: note.comment)
            notesStackView.addArrangedSubview(noteLabel)
        }
    }
}

extension BirdDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        
        submitNote(text: text)
        return true
    }
}
