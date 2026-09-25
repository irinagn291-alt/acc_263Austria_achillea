import UIKit

/// Role: Name. Relays edits from a NIB cell. The table is the mechanic.
@MainActor
protocol NameCellRelay: AnyObject {
    func nameCellDidEndName(_ cell: NameCell)
    func nameCellDidEndMass(_ cell: NameCell)
    func nameCellDidTapRemove(_ cell: NameCell)
}

/// Role: Name. NIB-registered row for one pledged line. Views never keep a second name table.
@MainActor
final class NameCell: UITableViewCell, UITextFieldDelegate {
    static let reuseID = "NameCell"
    static let nibName = "NameCell"

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var massField: UITextField!
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var massWidth: NSLayoutConstraint!

    weak var relay: NameCellRelay?
    private(set) var nameID: UUID?

    nonisolated override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            style()
        }
    }

    func apply(_ name: Name, frozen: Bool, hidesStalk: Bool) {
        nameID = name.id
        if nameField.isFirstResponder == false {
            nameField.text = name.text
        }
        if massField.isFirstResponder == false {
            massField.text = AskFigures.mass(name.stalk.mass)
        }
        massField.isHidden = hidesStalk
        massWidth.constant = hidesStalk ? 0 : AskSpace.step(9)
        massField.isEnabled = frozen == false && hidesStalk == false
        nameField.isEnabled = frozen == false
        removeButton.isHidden = frozen
        removeButton.isEnabled = frozen == false
        nameField.textColor = frozen ? AskPaint.muted : AskPaint.ink
        accessibilityLabel = name.text
    }

    func nameText() -> String {
        nameField.text ?? ""
    }

    func massText() -> String {
        massField.text ?? ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField === massField else { return true }
        let current = textField.text ?? ""
        guard let span = Range(range, in: current) else { return false }
        let next = current.replacingCharacters(in: span, with: string)
        return AskFigures.allowsMassDraft(next)
    }

    private func style() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cardView.backgroundColor = AskPaint.surface
        cardView.layer.cornerRadius = AskRadius.card
        cardView.layer.borderWidth = AskRadius.hairline
        cardView.layer.borderColor = AskPaint.muted.withAlphaComponent(0.35).cgColor
        cardView.clipsToBounds = true

        nameField.font = UIFont.preferredFont(forTextStyle: .body)
        nameField.adjustsFontForContentSizeCategory = true
        nameField.textColor = AskPaint.ink
        nameField.tintColor = AskPaint.accent
        nameField.backgroundColor = .clear
        nameField.borderStyle = .none
        nameField.autocapitalizationType = .words
        nameField.returnKeyType = .done
        nameField.delegate = self
        nameField.addTarget(self, action: #selector(endedName), for: .editingDidEnd)
        nameField.attributedPlaceholder = NSAttributedString(
            string: AskCopy.namePlaceholder,
            attributes: [.foregroundColor: AskPaint.muted]
        )

        massField.font = UIFont.monospacedDigitSystemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize,
            weight: .medium
        )
        massField.adjustsFontForContentSizeCategory = true
        massField.textColor = AskPaint.ink
        massField.tintColor = AskPaint.accent
        massField.backgroundColor = .clear
        massField.borderStyle = .none
        massField.keyboardType = .decimalPad
        massField.textAlignment = .right
        massField.delegate = self
        massField.addTarget(self, action: #selector(endedMass), for: .editingDidEnd)
        massField.attributedPlaceholder = NSAttributedString(
            string: AskCopy.massPlaceholder,
            attributes: [.foregroundColor: AskPaint.muted]
        )
        massField.inputAccessoryView = makeDoneBar()

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.baseForegroundColor = AskPaint.ink
        config.contentInsets = NSDirectionalEdgeInsets(
            top: AskSpace.inner,
            leading: AskSpace.inner,
            bottom: AskSpace.inner,
            trailing: AskSpace.inner
        )
        removeButton.configuration = config
        removeButton.accessibilityLabel = AskCopy.removeName
        removeButton.addTarget(self, action: #selector(tappedRemove), for: .touchUpInside)
    }

    @objc private func endedName() {
        relay?.nameCellDidEndName(self)
    }

    @objc private func endedMass() {
        relay?.nameCellDidEndMass(self)
    }

    @objc private func tappedRemove() {
        relay?.nameCellDidTapRemove(self)
    }

    private func makeDoneBar() -> UIToolbar {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: AskSpace.step(40), height: AskSpace.hit))
        bar.barTintColor = AskPaint.surface
        bar.tintColor = AskPaint.accent
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(
            title: AskCopy.done,
            style: .done,
            target: self,
            action: #selector(doneMass)
        )
        bar.items = [spacer, done]
        bar.sizeToFit()
        return bar
    }

    @objc private func doneMass() {
        massField.resignFirstResponder()
    }
}

/// Role: Name. Named colours for UIKit cells. Hex lives only in AskInk.
enum AskPaint {
    static var background: UIColor { named("background") }
    static var surface: UIColor { named("surface") }
    static var ink: UIColor { named("ink") }
    static var accent: UIColor { named("accent") }
    static var muted: UIColor { named("muted") }

    private static func named(_ name: String) -> UIColor {
        UIColor(named: name) ?? .label
    }
}
