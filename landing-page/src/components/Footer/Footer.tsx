import { Github, Heart } from 'lucide-react'

const Footer = () => {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="relative py-12 px-4">
      <div className="section-divider max-w-3xl mx-auto mb-12" />

      <div className="max-w-6xl mx-auto">
        <div className="flex flex-col md:flex-row items-center justify-between gap-8">
          {/* Logo + copyright */}
          <div className="flex flex-col items-center md:items-start gap-2">
            <div className="flex items-center gap-2.5">
              <div className="w-6 h-6 rounded-md bg-violet flex items-center justify-center">
                <svg width="10" height="10" viewBox="0 0 16 16" fill="none">
                  <rect x="1" y="3" width="14" height="2.5" rx="1" fill="white" opacity="0.9"/>
                  <rect x="1" y="7" width="10" height="2.5" rx="1" fill="white" opacity="0.65"/>
                  <rect x="1" y="11" width="12" height="2.5" rx="1" fill="white" opacity="0.4"/>
                </svg>
              </div>
              <span className="font-display text-lg text-ash-100">ShelfSpace</span>
            </div>
            <p className="text-xs font-body text-ash-600">
              &copy; {currentYear} ShelfSpace. All rights reserved.
            </p>
          </div>

          {/* Links */}
          <div className="flex items-center gap-6">
            <a
              href="https://github.com/immdipu/shelfspace"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 text-sm font-body text-ash-500 hover:text-violet transition-colors"
            >
              <Github className="w-4 h-4" />
              GitHub
            </a>
            <a
              href="https://github.com/immdipu/shelfspace/releases"
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm font-body text-ash-500 hover:text-violet transition-colors"
            >
              Releases
            </a>
            <a
              href="https://github.com/immdipu/shelfspace/issues"
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm font-body text-ash-500 hover:text-violet transition-colors"
            >
              Issues
            </a>
          </div>

          {/* Attribution */}
          <div className="flex items-center gap-1.5 text-xs font-body text-ash-600">
            Made with
            <Heart className="w-3 h-3 text-violet fill-violet" />
            by
            <a
              href="https://github.com/immdipu"
              target="_blank"
              rel="noopener noreferrer"
              className="text-ash-400 hover:text-violet transition-colors"
            >
              immdipu
            </a>
          </div>
        </div>
      </div>

      {/* Bottom spacing */}
      <div className="h-4" />
    </footer>
  )
}

export default Footer
