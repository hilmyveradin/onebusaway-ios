//
//  ReportProblemViewController.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 6/12/19.
//

import UIKit
import AloeStackView

// abxoxo - next up: build this out!
// Eureka isn't going to work for me here. I need to duplicate StopViewController's ability to show a list of ArrivalDEparture objects.

/// The 'hub' view controller for reporting problems about stops and trips.
///
/// From here, a user can report a problem either about a `Stop` or about a trip at that stop.
///
/// - Note: This view controller expects to be presented modally.
@objc(OBAReportProblemViewController)
public class ReportProblemViewController: UIViewController {

    private lazy var stackView: AloeStackView = {
        let stack = AloeStackView()
        stack.backgroundColor = application.theme.colors.groupedTableBackground
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let application: Application
    private let stop: Stop

    private var operation: StopArrivalsModelOperation?

    private var stopArrivals: StopArrivals? {
        didSet {
            updateUI()
        }
    }

    // MARK: - Init

    public init(application: Application, stop: Stop) {
        self.application = application
        self.stop = stop

        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        title = NSLocalizedString("report_problem.title", value: "Report a Problem", comment: "Title of the Report Problem view controller.")
    }

    deinit {
        operation?.cancel()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = application.theme.colors.groupedTableBackground

        view.addSubview(stackView)
        stackView.pinToSuperview(.edges)

        updateData()
    }

    // MARK: - Data

    private func updateData() {
        guard let modelService = application.restAPIModelService else { return }

        let op = modelService.getArrivalsAndDeparturesForStop(id: stop.id, minutesBefore: 30, minutesAfter: 30)
        op.then { [weak self] in
            guard let self = self else { return }
            self.stopArrivals = op.stopArrivals
        }

        self.operation = op
    }

    // MARK: - Actions

    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Form Builder

    private func updateUI() {
        guard
            let stop = stopArrivals?.stop,
            let arrivalsAndDepartures = stopArrivals?.arrivalsAndDepartures
            else {
                return
        }

        addProblemWithTheStopRow(stop)
        addProblemWithAVehicleRow(arrivalsAndDepartures)
    }

    private func addProblemWithTheStopRow(_ stop: Stop) {
        let stopHeader = TableHeaderView(text: NSLocalizedString("report_problem_controller.stop_problem.header", value: "Problem with the Stop", comment: "A table header in the 'Report Problem' view controller."))
        stackView.addRow(stopHeader, hideSeparator: false)
        stackView.setSeparatorInset(forRow: stopHeader, inset: .zero)

        let fmt = NSLocalizedString(
            "report_problem_controller.report_stop_problem_fmt",
            value: "Report a problem with the stop at %@",
            comment: "Report a problem with the stop at {Stop Name}"
        )

        let reportStopProblemRow = DefaultTableRowView(
            title: String(format: fmt, stop.name),
            accessoryType: .disclosureIndicator
        )

        addTableRowToStack(reportStopProblemRow)
        stackView.setSeparatorInset(forRow: reportStopProblemRow, inset: .zero)
    }

    fileprivate func addProblemWithAVehicleRow(_ arrivalsAndDepartures: [ArrivalDeparture]) {
        let vehicleHeader = TableHeaderView.autolayoutNew()
        vehicleHeader.textLabel.text = NSLocalizedString("report_problem_controller.stop_problem.header", value: "Problem with a Vehicle at the Stop", comment: "A table header in the 'Report Problem' view controller.")
        stackView.addRow(vehicleHeader, hideSeparator: false)
        stackView.setSeparatorInset(forRow: vehicleHeader, inset: .zero)

        let rows = arrivalsAndDepartures.map { arrDep -> UIView in
            let arrivalView = StopArrivalView.autolayoutNew()
            arrivalView.deemphasizePastEvents = false
            arrivalView.formatters = application.formatters
            arrivalView.arrivalDeparture = arrDep
            addTableRowToStack(arrivalView)
            return arrivalView
        }

        if let lastRow = rows.last {
            stackView.setSeparatorInset(forRow: lastRow, inset: .zero)
        }
    }

    private func addTableRowToStack(_ row: UIView) {
        stackView.addRow(row, hideSeparator: false)
        stackView.setBackgroundColor(forRow: row, color: application.theme.colors.groupedTableRowBackground)
    }
}
