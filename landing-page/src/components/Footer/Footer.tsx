import { motion } from 'framer-motion'
import { Github, Heart } from 'lucide-react'

const Footer = () => {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="py-12 px-4 border-t border-white/10">
      <div className="max-w-6xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="flex flex-col md:flex-row items-center justify-between gap-6"
        >
          {/* Logo & copyright */}
          <div className="flex flex-col items-center md:items-start gap-2">
            <span className="text-xl font-bold gradient-text">ShelfSpace</span>
            <p className="text-sm text-text-secondary">
              &copy; {currentYear} ShelfSpace. All rights reserved.
            </p>
          </div>

          {/* Links */}
          <div className="flex items-center gap-6">
            <a
              href="https://github.com/immdipu/shelfspace"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 text-text-secondary hover:text-primary transition-colors"
            >
              <Github className="w-5 h-5" />
              GitHub
            </a>
            <a
              href="https://github.com/immdipu/shelfspace/releases"
              target="_blank"
              rel="noopener noreferrer"
              className="text-text-secondary hover:text-primary transition-colors"
            >
              Releases
            </a>
            <a
              href="https://github.com/immdipu/shelfspace/issues"
              target="_blank"
              rel="noopener noreferrer"
              className="text-text-secondary hover:text-primary transition-colors"
            >
              Issues
            </a>
          </div>

          {/* Made with love */}
          <div className="flex items-center gap-2 text-sm text-text-secondary">
            Made with
            <Heart className="w-4 h-4 text-accent fill-accent" />
            by
            <a
              href="https://github.com/immdipu"
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary hover:underline"
            >
              immdipu
            </a>
          </div>
        </motion.div>
      </div>
    </footer>
  )
}

export default Footer
