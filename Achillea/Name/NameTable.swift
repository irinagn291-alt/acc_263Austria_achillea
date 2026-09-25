import SwiftUI
import UIKit

/// Role: Name. UITableView with NIB-registered cells hosted under the numeric rail. This table is the mechanic.
struct NameTableHost: UIViewRepresentable {
    var names: [Name]
    var frozen: Bool
    var hidesStalk: Bool
    var onCommitText: (UUID, String) -> Void
    var onCommitMass: (UUID, String) -> Void
    var onRemove: (UUID) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UITableView {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(
            UINib(nibName: NameCell.nibName, bundle: Bundle(for: NameCell.self)),
            forCellReuseIdentifier: NameCell.reuseID
        )
        table.dataSource = context.coordinator
        table.delegate = context.coordinator
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.keyboardDismissMode = .onDrag
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.allowsSelection = false
        table.contentInsetAdjustmentBehavior = .never
        context.coordinator.table = table
        context.coordinator.apply(self)
        return table
    }

    func updateUIView(_ table: UITableView, context: Context) {
        let oldIDs = context.coordinator.names.map(\.id)
        let newIDs = names.map(\.id)
        let flagsChanged =
            context.coordinator.frozen != frozen
            || context.coordinator.hidesStalk != hidesStalk
        context.coordinator.apply(self)
        if oldIDs != newIDs {
            table.reloadData()
            return
        }
        if flagsChanged {
            for case let cell as NameCell in table.visibleCells {
                guard let id = cell.nameID, let name = names.first(where: { $0.id == id }) else {
                    continue
                }
                cell.apply(name, frozen: frozen, hidesStalk: hidesStalk)
            }
            return
        }
        for case let cell as NameCell in table.visibleCells {
            guard let id = cell.nameID, let name = names.first(where: { $0.id == id }) else {
                continue
            }
            cell.apply(name, frozen: frozen, hidesStalk: hidesStalk)
        }
    }

    @MainActor
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate, NameCellRelay {
        var names: [Name] = []
        var frozen = false
        var hidesStalk = false
        var onCommitText: (UUID, String) -> Void = { _, _ in }
        var onCommitMass: (UUID, String) -> Void = { _, _ in }
        var onRemove: (UUID) -> Void = { _ in }
        weak var table: UITableView?

        func apply(_ host: NameTableHost) {
            names = host.names
            frozen = host.frozen
            hidesStalk = host.hidesStalk
            onCommitText = host.onCommitText
            onCommitMass = host.onCommitMass
            onRemove = host.onRemove
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            names.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NameCell.reuseID,
                for: indexPath
            )
            guard let nameCell = cell as? NameCell else { return cell }
            let name = names[indexPath.row]
            nameCell.relay = self
            nameCell.apply(name, frozen: frozen, hidesStalk: hidesStalk)
            return nameCell
        }

        func nameCellDidEndName(_ cell: NameCell) {
            guard let id = cell.nameID else { return }
            onCommitText(id, cell.nameText())
        }

        func nameCellDidEndMass(_ cell: NameCell) {
            guard let id = cell.nameID else { return }
            onCommitMass(id, cell.massText())
        }

        func nameCellDidTapRemove(_ cell: NameCell) {
            guard let id = cell.nameID else { return }
            onRemove(id)
        }
    }
}
