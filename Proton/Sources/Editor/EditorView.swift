//
//  EditorView.swift
//  Proton
//
//  Created by Rajdeep Kwatra on 5/1/20.
//  Copyright © 2020 Rajdeep Kwatra. All rights reserved.
//

import Foundation
import UIKit

public protocol BoundsObserving: class {
    func didChangeBounds(_ bounds: CGRect)
}

open class EditorView: UIView {
    let richTextView: RichTextView

    public let context: EditorViewContext

    public init(frame: CGRect = .zero, context: EditorViewContext = .shared) {
        self.context = context
        self.richTextView = RichTextView(frame: frame, context: context.richTextViewContext)

        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var contentInset: UIEdgeInsets {
        get { richTextView.contentInset }
        set { richTextView.contentInset = newValue }
    }

    public var textContainerInset: UIEdgeInsets {
        get { richTextView.textContainerInset }
        set { richTextView.textContainerInset = newValue }
    }

    public var contentLength: Int {
        return attributedText.length
    }

    public var selectedText: NSAttributedString {
        return attributedText.attributedSubstring(from: selectedRange)
    }

    public override var backgroundColor: UIColor? {
        didSet {
            richTextView.backgroundColor = backgroundColor
        }
    }

    public var font: UIFont? = UIFont.systemFont(ofSize: 17) {
        didSet { richTextView.typingAttributes[.font] = font }
    }

    public var paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle() {
        didSet { richTextView.typingAttributes[.paragraphStyle] = paragraphStyle }
    }

    public var maxHeight: CGFloat {
        get { richTextView.maxHeight }
        set { richTextView.maxHeight = newValue }
    }

    public var attributedText: NSAttributedString {
        get { return richTextView.attributedText }
        set { richTextView.attributedText = newValue }
    }

    public var selectedRange: NSRange {
        get { return richTextView.selectedRange }
        set { richTextView.selectedRange = newValue }
    }

    public var typingAttributes: [NSAttributedString.Key: Any] {
        get { return richTextView.typingAttributes }
        set { richTextView.typingAttributes = newValue }
    }

    public var boundsObserver: BoundsObserving? {
        get { richTextView.boundsObserver }
        set { richTextView.boundsObserver = newValue }
    }

    public var textEndRange: NSRange {
        return richTextView.textEndRange
    }

    func setup() {
        richTextView.autocorrectionType = .no

        richTextView.translatesAutoresizingMaskIntoConstraints = false
        richTextView.defaultTextFormattingProvider = self

        addSubview(richTextView)
        NSLayoutConstraint.activate([
            richTextView.topAnchor.constraint(equalTo: topAnchor),
            richTextView.bottomAnchor.constraint(equalTo: bottomAnchor),
            richTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            richTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])

        setupTextStyles()
        typingAttributes = [
            NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
    }

    private func setupTextStyles() {
        paragraphStyle.lineSpacing = 6
        paragraphStyle.firstLineHeadIndent = 8
    }

    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        return richTextView.becomeFirstResponder()
    }

    public func insertAttachment(in range: NSRange, attachment: Attachment) {
        // TODO: handle undo

        richTextView.insertAttachment(in: range, attachment: attachment)
    }

    public func resignFocus() {
        richTextView.resignFirstResponder()
    }

    public func scrollRangeToVisible(range: NSRange) {
        richTextView.scrollRangeToVisible(range)
    }

    public func scrollRectToVisible(rect: CGRect, animated: Bool) {
        richTextView.scrollRectToVisible(rect, animated: animated)
    }

    public func replaceCharacters(in range: NSRange, with attriburedString: NSAttributedString) {
        richTextView.textStorage.replaceCharacters(in: range, with: attriburedString)
    }

    public func replaceCharacters(in range: NSRange, with string: String) {
        richTextView.textStorage.replaceCharacters(in: range, with: string)
    }
}

extension EditorView {
    public func addAttributes(_ attributes: [NSAttributedString.Key: Any], at range: NSRange) {
        self.richTextView.storage.addAttributes(attributes, range: range)
        // TODO: propagate to attachments
    }

    public func removeAttributes(_ attributes: [NSAttributedString.Key], at range: NSRange) {
        self.richTextView.storage.removeAttributes(attributes, range: range)
       // TODO: propagate to attachments
    }

    public func addAttribute(_ name: NSAttributedString.Key, value: Any, at range: NSRange) {
        self.addAttributes([name: value], at: range)
    }

    public func removeAttribute(_ name: NSAttributedString.Key, at range: NSRange) {
        self.removeAttributes([name], at: range)
    }
}

extension EditorView: DefaultTextFormattingProviding { }