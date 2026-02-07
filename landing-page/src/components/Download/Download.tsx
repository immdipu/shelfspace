import { motion } from 'framer-motion'
import { Download, Apple, Github } from 'lucide-react'

const ease = [0.22, 1, 0.36, 1]

const DownloadSection = () => {
  return (
    <section id="download" className="relative py-32 px-4">
      <div className="section-divider max-w-2xl mx-auto mb-32" />

      <div className="max-w-3xl mx-auto relative">
        {/* Ambient glow */}
        <div className="absolute -inset-32 bg-violet/[0.03] rounded-full blur-[100px] pointer-events-none" />

        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-80px" }}
          transition={{ duration: 0.8, ease }}
          className="relative glass-card rounded-3xl p-10 md:p-16 text-center overflow-hidden"
        >
          {/* Decorative grid */}
          <div
            className="absolute inset-0 pointer-events-none opacity-[0.02]"
            style={{
              backgroundImage: `radial-gradient(circle, rgba(139,92,246,0.5) 1px, transparent 1px)`,
              backgroundSize: '24px 24px',
            }}
          />

          <div className="relative z-10">
            {/* Icon */}
            <motion.div
              initial={{ scale: 0, rotate: -20 }}
              whileInView={{ scale: 1, rotate: 0 }}
              viewport={{ once: true }}
              transition={{ type: "spring", stiffness: 200, damping: 15, delay: 0.2 }}
              className="w-16 h-16 mx-auto mb-8 rounded-2xl bg-gradient-to-br from-violet to-violet-600 flex items-center justify-center shadow-lg shadow-violet/30 animate-glow"
            >
              <Download className="w-7 h-7 text-white" />
            </motion.div>

            <h2 className="font-display text-3xl md:text-5xl tracking-tight mb-4">
              <span className="text-ash-50">Ready to try</span>{' '}
              <span className="gradient-text-violet italic">ShelfSpace</span>
              <span className="text-ash-50">?</span>
            </h2>
            <p className="font-body text-base md:text-lg text-ash-400 mb-10 max-w-md mx-auto leading-relaxed">
              Free, open source, and built for macOS.
              Download and start managing your clipboard in seconds.
            </p>

            {/* CTA */}
            <motion.a
              href="https://github.com/immdipu/shelfspace/releases/latest/download/ShelfSpace.dmg"
              whileHover={{ scale: 1.03 }}
              whileTap={{ scale: 0.97 }}
              className="btn-violet text-base py-4 px-10"
            >
              <Apple className="w-5 h-5" />
              Download for macOS
            </motion.a>

            {/* Info badges */}
            <div className="mt-8 flex flex-wrap items-center justify-center gap-x-5 gap-y-2 text-sm font-body text-ash-500">
              <span className="flex items-center gap-2">
                <span className="w-1.5 h-1.5 rounded-full bg-green-400 glow-dot" style={{ boxShadow: '0 0 6px rgba(74,222,128,0.5)' }} />
                macOS 13.0+
              </span>
              <span className="text-ash-700">|</span>
              <span>Free & Open Source</span>
              <span className="text-ash-700">|</span>
              <a
                href="https://github.com/immdipu/shelfspace"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-1.5 text-ash-400 hover:text-violet transition-colors"
              >
                <Github className="w-3.5 h-3.5" />
                Source Code
              </a>
            </div>

            {/* First launch note */}
            <div className="mt-6 flex items-center justify-center gap-2 text-xs text-ash-600">
              <span className="w-1 h-1 rounded-full bg-ash-600/40" />
              <span>First launch: Right-click → Open (macOS security requirement)</span>
              <span className="w-1 h-1 rounded-full bg-ash-600/40" />
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  )
}

export default DownloadSection
