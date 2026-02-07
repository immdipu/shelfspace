import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Github, Download, Menu, X } from 'lucide-react'

const navLinks = [
  { label: 'Features', href: '#features' },
  { label: 'How it works', href: '#how-it-works' },
  { label: 'Showcase', href: '#showcase' },
  { label: 'Download', href: '#download' },
]

const Navbar = () => {
  const [scrolled, setScrolled] = useState(false)
  const [mobileOpen, setMobileOpen] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 40)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <motion.nav
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${
        scrolled
          ? 'bg-void/80 backdrop-blur-xl border-b border-void-600/50'
          : 'bg-transparent'
      }`}
    >
      <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
        {/* Logo */}
        <a href="#" className="flex items-center gap-3 group">
          <div className="w-8 h-8 rounded-lg bg-violet flex items-center justify-center shadow-lg shadow-violet/20 group-hover:shadow-violet/40 transition-shadow">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <rect x="1" y="3" width="14" height="2.5" rx="1" fill="white" opacity="0.95"/>
              <rect x="1" y="7" width="10" height="2.5" rx="1" fill="white" opacity="0.7"/>
              <rect x="1" y="11" width="12" height="2.5" rx="1" fill="white" opacity="0.45"/>
            </svg>
          </div>
          <span className="font-display text-xl text-ash-50 tracking-tight">ShelfSpace</span>
        </a>

        {/* Desktop links */}
        <div className="hidden md:flex items-center gap-1">
          {navLinks.map((link) => (
            <a
              key={link.label}
              href={link.href}
              className="px-4 py-2 text-sm text-ash-300 hover:text-white rounded-lg hover:bg-void-500/40 transition-all duration-200"
            >
              {link.label}
            </a>
          ))}
        </div>

        {/* Desktop CTA */}
        <div className="hidden md:flex items-center gap-3">
          <a
            href="https://github.com/immdipu/shelfspace"
            target="_blank"
            rel="noopener noreferrer"
            className="p-2.5 text-ash-400 hover:text-white rounded-lg hover:bg-void-500/40 transition-all duration-200"
            aria-label="GitHub"
          >
            <Github className="w-4.5 h-4.5" />
          </a>
          <a
            href="https://github.com/immdipu/shelfspace/releases/latest/download/ShelfSpace.dmg"
            className="inline-flex items-center gap-2 text-sm font-medium bg-violet/10 text-violet-200 hover:bg-violet/20 border border-violet/20 hover:border-violet/40 px-4 py-2 rounded-lg transition-all duration-200"
          >
            <Download className="w-3.5 h-3.5" />
            Download
          </a>
        </div>

        {/* Mobile toggle */}
        <button
          onClick={() => setMobileOpen(!mobileOpen)}
          className="md:hidden p-2 text-ash-300 hover:text-white"
          aria-label="Toggle menu"
        >
          {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
        </button>
      </div>

      {/* Mobile menu */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="md:hidden bg-void-100/95 backdrop-blur-xl border-b border-void-600/50 overflow-hidden"
          >
            <div className="px-6 py-4 space-y-1">
              {navLinks.map((link) => (
                <a
                  key={link.label}
                  href={link.href}
                  onClick={() => setMobileOpen(false)}
                  className="block px-4 py-3 text-ash-200 hover:text-white rounded-lg hover:bg-void-500/40 transition-colors"
                >
                  {link.label}
                </a>
              ))}
              <div className="pt-3 border-t border-void-600/50 flex gap-3">
                <a
                  href="https://github.com/immdipu/shelfspace"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex-1 text-center py-3 text-sm text-ash-300 border border-void-600 rounded-lg hover:bg-void-500/40 transition-colors"
                >
                  GitHub
                </a>
                <a
                  href="https://github.com/immdipu/shelfspace/releases/latest/download/ShelfSpace.dmg"
                  className="flex-1 text-center py-3 text-sm font-medium bg-violet text-white rounded-lg"
                >
                  Download
                </a>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.nav>
  )
}

export default Navbar
