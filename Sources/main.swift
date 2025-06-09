import Cocoa

// Create and configure the application
let app = NSApplication.shared
app.setActivationPolicy(.accessory) // This makes it a menu bar only app

// Create the app delegate
let delegate = AppDelegate()
app.delegate = delegate

// Run the application
app.run() 