import Cocoa

final class ThemedScroller: NSScroller {
    override class var isCompatibleWithOverlayScrollers: Bool { true }

    private var knobColor: NSColor {
        return AppColors.accent.withAlphaComponent(0.45)
    }

    private var knobHoverColor: NSColor {
        return AppColors.accent.withAlphaComponent(0.6)
    }

    private var slotColor: NSColor {
        return AppColors.background.withAlphaComponent(0.15)
    }

    override func drawKnobSlot(in slotRect: NSRect, highlight flag: Bool) {
        let path = NSBezierPath(roundedRect: slotRect.insetBy(dx: 1, dy: 2), xRadius: 4, yRadius: 4)
        slotColor.setFill()
        path.fill()
    }

    override func drawKnob() {
        let knobRect = rect(for: .knob)
        let radius: CGFloat = min(knobRect.width, knobRect.height) / 2
        let path = NSBezierPath(roundedRect: knobRect.insetBy(dx: 1, dy: 1), xRadius: radius, yRadius: radius)
        (isHighlighted ? knobHoverColor : knobColor).setFill()
        path.fill()
    }
}
