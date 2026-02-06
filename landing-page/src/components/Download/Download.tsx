import { motion } from 'framer-motion'
import { Download, Apple, Github } from 'lucide-react'

const DownloadSection = () => {
  return (
    <section id="download" className="py-24 px-4">
      <div className="max-w-4xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="glass rounded-3xl p-8 md:p-12 text-center relative overflow-hidden"
        >
          {/* Background gradient */}
          <div className="absolute inset-0 bg-gradient-to-br from-primary/10 to-accent/10 pointer-events-none" />

          {/* Content */}
          <div className="relative z-10">
            <motion.div
              initial={{ scale: 0 }}
              whileInView={{ scale: 1 }}
              viewport={{ once: true }}
              transition={{ type: "spring", stiffness: 200, damping: 15 }}
              className="w-20 h-20 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-primary to-accent flex items-center justify-center shadow-lg shadow-primary/30"
            >
              <Download className="w-10 h-10 text-white" />
            </motion.div>

            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              Ready to Get Started?
            </h2>
            <p className="text-lg text-text-secondary mb-8 max-w-xl mx-auto">
              Download ShelfSpace for free and transform the way you manage temporary files on macOS.
            </p>

            {/* Download button */}
            <motion.a
              href="https://github.com/immdipu/shelfspace/releases"
              target="_blank"
              rel="noopener noreferrer"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="inline-flex items-center gap-3 bg-gradient-to-r from-primary to-primary-light text-white font-semibold py-4 px-8 rounded-full shadow-lg shadow-primary/30 hover:shadow-xl hover:shadow-primary/40 transition-shadow duration-300"
            >
              <Apple className="w-6 h-6" />
              Download for macOS
            </motion.a>

            {/* Version info */}
            <div className="mt-6 flex flex-col sm:flex-row items-center justify-center gap-4 text-sm text-text-secondary">
              <span className="flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-green-400" />
                macOS 13.0+
              </span>
              <span className="hidden sm:block">|</span>
              <span>Free & Open Source</span>
              <span className="hidden sm:block">|</span>
              <a
                href="https://github.com/immdipu/shelfspace"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 hover:text-primary transition-colors"
              >
                <Github className="w-4 h-4" />
                View Source
              </a>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  )
}

export default DownloadSection
