import Cocoa

/// Reusable animation utilities using Core Animation
enum AnimationHelper {
    // MARK: - Animation Durations

    enum Duration {
        static let fast: CFTimeInterval = 0.15
        static let normal: CFTimeInterval = 0.25
        static let slow: CFTimeInterval = 0.4
    }

    // MARK: - Spring Animations

    static func springAnimation(
        keyPath: String,
        from: Any? = nil,
        to: Any,
        duration: CFTimeInterval = Duration.normal,
        damping: CGFloat = 15,
        mass: CGFloat = 1,
        stiffness: CGFloat = 200
    ) -> CASpringAnimation {
        let animation = CASpringAnimation(keyPath: keyPath)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.damping = damping
        animation.mass = mass
        animation.stiffness = stiffness
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        return animation
    }

    // MARK: - Card Hover Animations

    /// Lift card up with translateY effect
    static func liftCard(layer: CALayer, by offset: CGFloat = -2) {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 0
        animation.toValue = offset
        animation.duration = Duration.fast
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "liftCard")
    }

    /// Lower card back to original position
    static func lowerCard(layer: CALayer) {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = layer.presentation()?.value(forKeyPath: "transform.translation.y") ?? -2
        animation.toValue = 0
        animation.duration = Duration.fast
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "lowerCard")
    }

    /// Animate border color change
    static func animateBorderColor(layer: CALayer, to color: CGColor, duration: CFTimeInterval = Duration.fast) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = color
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "borderColor")
        layer.borderColor = color
    }

    // MARK: - Scale Animations

    static func scaleUp(layer: CALayer, scale: CGFloat = 1.03, duration: CFTimeInterval = Duration.fast) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = scale
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "scaleUp")
    }

    static func scaleDown(layer: CALayer, duration: CFTimeInterval = Duration.fast) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = layer.presentation()?.value(forKeyPath: "transform.scale") ?? 1.0
        animation.toValue = 1.0
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "scaleDown")
    }

    /// Scale animation for item add (spring bounce)
    static func scaleInWithBounce(layer: CALayer, completion: (() -> Void)? = nil) {
        let scaleAnimation = CASpringAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.8
        scaleAnimation.toValue = 1.0
        scaleAnimation.damping = 12
        scaleAnimation.stiffness = 300
        scaleAnimation.mass = 0.8
        scaleAnimation.duration = scaleAnimation.settlingDuration
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = .forwards

        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = Duration.fast

        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, fadeAnimation]
        group.duration = scaleAnimation.settlingDuration
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        layer.add(group, forKey: "scaleInWithBounce")
        CATransaction.commit()
    }

    /// Scale animation for item remove
    static func scaleOut(layer: CALayer, completion: (() -> Void)? = nil) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 0.8
        scaleAnimation.duration = Duration.fast

        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = Duration.fast

        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, fadeAnimation]
        group.duration = Duration.fast
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        layer.add(group, forKey: "scaleOut")
        CATransaction.commit()
    }

    // MARK: - Shadow Animations

    static func elevateShadow(
        layer: CALayer,
        opacity: Float = 0.25,
        radius: CGFloat = 12,
        offset: CGSize = CGSize(width: 0, height: 6)
    ) {
        let group = CAAnimationGroup()
        group.duration = Duration.fast

        let opacityAnim = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnim.toValue = opacity

        let radiusAnim = CABasicAnimation(keyPath: "shadowRadius")
        radiusAnim.toValue = radius

        let offsetAnim = CABasicAnimation(keyPath: "shadowOffset")
        offsetAnim.toValue = offset

        group.animations = [opacityAnim, radiusAnim, offsetAnim]
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        layer.add(group, forKey: "elevateShadow")
    }

    static func resetShadow(
        layer: CALayer,
        opacity: Float = 0.1,
        radius: CGFloat = 4,
        offset: CGSize = CGSize(width: 0, height: 2)
    ) {
        let group = CAAnimationGroup()
        group.duration = Duration.fast

        let opacityAnim = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnim.toValue = opacity

        let radiusAnim = CABasicAnimation(keyPath: "shadowRadius")
        radiusAnim.toValue = radius

        let offsetAnim = CABasicAnimation(keyPath: "shadowOffset")
        offsetAnim.toValue = offset

        group.animations = [opacityAnim, radiusAnim, offsetAnim]
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        layer.add(group, forKey: "resetShadow")
    }

    // MARK: - Fade Animations

    static func fadeIn(layer: CALayer, duration: CFTimeInterval = Duration.normal) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "fadeIn")
    }

    static func fadeOut(layer: CALayer, duration: CFTimeInterval = Duration.normal) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        layer.add(animation, forKey: "fadeOut")
    }

    /// Crossfade between two values
    static func crossfade(layer: CALayer, duration: CFTimeInterval = Duration.fast) {
        let animation = CATransition()
        animation.type = .fade
        animation.duration = duration
        layer.add(animation, forKey: "crossfade")
    }

    // MARK: - Tab Indicator Animation

    /// Spring animation for tab indicator movement
    static func moveTabIndicator(layer: CALayer, to frame: CGRect) {
        let positionAnimation = CASpringAnimation(keyPath: "position")
        positionAnimation.fromValue = layer.position
        positionAnimation.toValue = CGPoint(x: frame.midX, y: frame.midY)
        positionAnimation.damping = 15
        positionAnimation.stiffness = 300
        positionAnimation.mass = 0.8
        positionAnimation.duration = positionAnimation.settlingDuration

        let boundsAnimation = CASpringAnimation(keyPath: "bounds.size")
        boundsAnimation.fromValue = layer.bounds.size
        boundsAnimation.toValue = frame.size
        boundsAnimation.damping = 15
        boundsAnimation.stiffness = 300
        boundsAnimation.mass = 0.8
        boundsAnimation.duration = boundsAnimation.settlingDuration

        let group = CAAnimationGroup()
        group.animations = [positionAnimation, boundsAnimation]
        group.duration = max(positionAnimation.settlingDuration, boundsAnimation.settlingDuration)
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards

        layer.add(group, forKey: "moveTabIndicator")
        layer.position = CGPoint(x: frame.midX, y: frame.midY)
        layer.bounds.size = frame.size
    }

    // MARK: - Pulsing Animation (for drag feedback)

    static func addPulsingBorder(to layer: CALayer, color: CGColor, width: CGFloat = 2) {
        let pulseAnimation = CABasicAnimation(keyPath: "borderWidth")
        pulseAnimation.fromValue = width
        pulseAnimation.toValue = width + 1
        pulseAnimation.duration = 0.5
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer.borderColor = color
        layer.borderWidth = width
        layer.add(pulseAnimation, forKey: "pulsingBorder")
    }

    static func removePulsingBorder(from layer: CALayer) {
        layer.removeAnimation(forKey: "pulsingBorder")
    }

    // MARK: - Animated Dashed Border (for drop zone)

    static func addAnimatedDashedBorder(to layer: CAShapeLayer, color: CGColor, lineWidth: CGFloat = 2) {
        let animation = CABasicAnimation(keyPath: "lineDashPhase")
        animation.fromValue = 0
        animation.toValue = 24
        animation.duration = 0.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)

        layer.strokeColor = color
        layer.lineWidth = lineWidth
        layer.lineDashPattern = [8, 4]
        layer.add(animation, forKey: "dashAnimation")
    }

    static func removeAnimatedDashedBorder(from layer: CAShapeLayer) {
        layer.removeAnimation(forKey: "dashAnimation")
    }

    // MARK: - Gradient Border for Pinned Items

    static func createGradientBorderLayer(bounds: CGRect, cornerRadius: CGFloat, colors: [CGColor]) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        let maskLayer = CAShapeLayer()
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 1.5, dy: 1.5), xRadius: cornerRadius, yRadius: cornerRadius)
        maskLayer.path = path.cgPath
        maskLayer.fillColor = nil
        maskLayer.strokeColor = NSColor.white.cgColor
        maskLayer.lineWidth = 3

        gradientLayer.mask = maskLayer

        return gradientLayer
    }

    // MARK: - Glow Effect

    static func addGlowEffect(to layer: CALayer, color: CGColor, radius: CGFloat = 10, opacity: Float = 0.5) {
        layer.shadowColor = color
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
    }

    static func removeGlowEffect(from layer: CALayer) {
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        layer.shadowOffset = NSSize(width: 0, height: 2)
    }

    // MARK: - Pinned Indicator Animation

    static func addPinnedAccentBorder(to layer: CALayer, accentColor: CGColor, width: CGFloat = 3) {
        // Create a sublayer for the left accent border
        let accentLayer = CALayer()
        accentLayer.name = "pinnedAccent"
        accentLayer.backgroundColor = accentColor
        accentLayer.frame = CGRect(x: 0, y: 4, width: width, height: layer.bounds.height - 8)
        accentLayer.cornerRadius = width / 2

        // Add glow to accent
        accentLayer.shadowColor = accentColor
        accentLayer.shadowRadius = 6
        accentLayer.shadowOpacity = 0.5
        accentLayer.shadowOffset = .zero

        layer.addSublayer(accentLayer)
    }

    static func removePinnedAccentBorder(from layer: CALayer) {
        layer.sublayers?.first { $0.name == "pinnedAccent" }?.removeFromSuperlayer()
    }
}

// MARK: - NSBezierPath CGPath Extension

extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0..<elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo, .cubicCurveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .quadraticCurveTo:
                path.addQuadCurve(to: points[1], control: points[0])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                break
            }
        }

        return path
    }
}
