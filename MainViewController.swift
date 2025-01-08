import UIKit
import BarcodeScanner
import SQLite

class MainViewController: UIViewController {

    // MARK: - UI Elements
    private let scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan Code", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resultView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan a code to begin"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let validityLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let historyTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.layer.cornerRadius = 10
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Properties
    private var scannedCodes: [(code: String, isValid: Bool, date: Date)] = []
    private var dbManager: DatabaseManager?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatabase()
        loadHistory()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Green Check"
        
        // Configure button appearance
        scanButton.backgroundColor = .systemGreen
        scanButton.setTitle("Scan Barcode", for: .normal)
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        scanButton.layer.shadowColor = UIColor.black.cgColor
        scanButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        scanButton.layer.shadowRadius = 4
        scanButton.layer.shadowOpacity = 0.25
        
        // Configure result view
        resultView.layer.borderWidth = 1
        resultView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Configure labels
        codeLabel.font = .systemFont(ofSize: 16)
        validityLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        // Configure table view
        historyTableView.layer.borderWidth = 1
        historyTableView.layer.borderColor = UIColor.systemGray4.cgColor
        historyTableView.separatorStyle = .singleLine
        historyTableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        // Add subviews
        view.addSubview(scanButton)
        view.addSubview(resultView)
        resultView.addSubview(codeLabel)
        resultView.addSubview(validityLabel)
        view.addSubview(historyTableView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scanButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.widthAnchor.constraint(equalToConstant: 200),
            scanButton.heightAnchor.constraint(equalToConstant: 50),
            
            resultView.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 20),
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultView.heightAnchor.constraint(equalToConstant: 100),
            
            codeLabel.topAnchor.constraint(equalTo: resultView.topAnchor, constant: 10),
            codeLabel.leadingAnchor.constraint(equalTo: resultView.leadingAnchor, constant: 10),
            codeLabel.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -10),
            
            validityLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 10),
            validityLabel.leadingAnchor.constraint(equalTo: resultView.leadingAnchor, constant: 10),
            validityLabel.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -10),
            
            historyTableView.topAnchor.constraint(equalTo: resultView.bottomAnchor, constant: 20),
            historyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            historyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            historyTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Add title label
        let titleLabel = UILabel()
        titleLabel.text = "Scan History"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: historyTableView.topAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: historyTableView.leadingAnchor),
        ])
        
        // Setup table view
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        historyTableView.dataSource = self
        historyTableView.delegate = self
        
        // Setup actions
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
    }
    
    private func setupDatabase() {
        dbManager = DatabaseManager()
        try? dbManager?.createTables()
    }
    
    private func loadHistory() {
        scannedCodes = dbManager?.getScannedCodes() ?? []
        historyTableView.reloadData()
    }

    // MARK: - Actions
    @objc private func scanButtonTapped() {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        present(viewController, animated: true)
    }
    
    private func handleScannedCode(_ code: String) {
        // Check validity (implement your validation logic here)
        let isValid = true // Replace with actual validation
        
        // Update UI
        codeLabel.text = "Code: \(code)"
        validityLabel.text = isValid ? "Valid ✅" : "Invalid ❌"
        validityLabel.textColor = isValid ? .systemGreen : .systemRed
        
        // Save to database
        dbManager?.saveCode(code: code, isValid: isValid)
        
        // Reload history
        loadHistory()
    }
}

// MARK: - BarcodeScannerCodeDelegate
extension MainViewController: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        controller.dismiss(animated: true) { [weak self] in
            self?.handleScannedCode(code)
        }
    }
}

// MARK: - BarcodeScannerErrorDelegate
extension MainViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print("Scanning error: \(error)")
    }
}

// MARK: - BarcodeScannerDismissalDelegate
extension MainViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedCodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let scan = scannedCodes[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        cell.textLabel?.text = """
            Code: \(scan.code)
            Date: \(dateFormatter.string(from: scan.date))
            Valid: \(scan.isValid ? "✅" : "❌")
            """
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: Int) -> CGFloat {
        return 80
    }
}
