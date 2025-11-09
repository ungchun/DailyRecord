//
//  SearchViewController.swift
//  DailyRecord
//
//  Created by Kim SungHun on 3/17/25.
//

import UIKit

final class SearchViewController: BaseViewController {
  
  // MARK: - Properties
  
  var coordinator: SearchCoordinator?
  
  private let viewModel: SearchViewModel
  private let calendarViewModel: CalendarViewModel
  
  private var searchWorkItem: DispatchWorkItem?
  private var isFirstAppearance = true
  
  // MARK: - Views
  
  private let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = L10n.Search.placeholder
    searchBar.searchBarStyle = .minimal
    searchBar.tintColor = .azGray900
    
    if let textField = searchBar.value(forKey: "searchField") as? UITextField {
      textField.textColor = .azGray900
      if let placeholderLabel = textField.value(forKey: "placeholderLabel") as? UILabel {
        placeholderLabel.textColor = .azGray700
      }
      if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
        clearButton.setImage(
          clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal
        )
        clearButton.tintColor = .azGray700
      }
    }
    return searchBar
  }()
  
  private let emptyResultLabel: UILabel = {
    let label = UILabel()
    label.text = L10n.Search.noResults
    label.font = UIFont(name: "omyu_pretty", size: 18)
    label.textColor = .azGray700
    label.textAlignment = .center
    label.isHidden = true
    return label
  }()
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = true
    scrollView.alwaysBounceVertical = true
    return scrollView
  }()
  
  private lazy var contentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private lazy var recordStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.distribution = .fill
    return stackView
  }()
  
  // MARK: - Init
  
  init(
    viewModel: SearchViewModel,
    calendarViewModel: CalendarViewModel
  ) {
    self.viewModel = viewModel
    self.calendarViewModel = calendarViewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Amp.track(event: "screen_view", properties: ["screen_name": "search"])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if isFirstAppearance {
      searchBar.becomeFirstResponder()
      isFirstAppearance = false
    }
  }
  
  // MARK: - Functions
  
  override func addView() {
    [searchBar, scrollView, emptyResultLabel].forEach {
      view.addSubview($0)
    }
    
    scrollView.addSubview(contentView)
    contentView.addSubview(recordStackView)
  }
  
  override func setLayout() {
    searchBar.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.trailing.equalToSuperview()
    }
    
    scrollView.snp.makeConstraints { make in
      make.top.leading.trailing.bottom.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    
    recordStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.leading.trailing.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().offset(-16)
    }
    
    emptyResultLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  override func setupView() {
    view.backgroundColor = .azGray50
    
    navigationItem.titleView = searchBar
    
    searchBar.delegate = self
    scrollView.delegate = self
  }
}

private extension SearchViewController {
  func updateSearchResults() {
    recordStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    if viewModel.searchResults.isEmpty {
      scrollView.isHidden = true
      emptyResultLabel.isHidden = false
    } else {
      scrollView.isHidden = false
      emptyResultLabel.isHidden = true
      
      viewModel.searchResults.forEach { record in
        let recordView = SearchRecordItemView(record: record)
        recordView.delegate = self
        recordStackView.addArrangedSubview(recordView)
      }
    }
  }
}

extension SearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchWorkItem?.cancel()
    
    if searchText.isEmpty {
      viewModel.clearSearchResults()
      updateSearchResults()
      return
    }
    
    let workItem = DispatchWorkItem { [weak self] in
      guard let self = self else { return }
      self.viewModel.search(query: searchText)
      Amp.track(event: "search_execute", properties: [
        "query": searchText,
        "result_count": self.viewModel.searchResults.count
      ])
      DispatchQueue.main.async {
        self.updateSearchResults()
      }
    }
    
    searchWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchWorkItem?.cancel()
    
    if let searchText = searchBar.text, !searchText.isEmpty {
      viewModel.search(query: searchText)
      DispatchQueue.main.async { [weak self] in
        self?.updateSearchResults()
      }
    }
    
    searchBar.resignFirstResponder()
  }
}

extension SearchViewController: SearchRecordItemViewDelegate {
  func didTapRecord(_ record: RecordEntity) {
    Amp.track(event: "search_result_click", properties: [
      "has_emotion": !record.emotionType.isEmpty,
      "has_images": !record.imageList.isEmpty
    ])
    
    coordinator?.showRecord(
      calendarViewModel: calendarViewModel,
      selectData: record
    )
  }
}

extension SearchViewController: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    searchBar.resignFirstResponder()
  }
}
