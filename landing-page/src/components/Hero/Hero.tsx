import { motion } from 'framer-motion'
import { Download, MonitorSmartphone } from 'lucide-react'

const Hero = () => {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden px-4 py-20">
      {/* Animated background elements */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div
          className="absolute top-20 left-10 w-72 h-72 bg-primary/10 rounded-full blur-3xl"
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        />
        <motion.div
          className="absolute bottom-20 right-10 w-96 h-96 bg-accent/10 rounded-full blur-3xl"
          animate={{
            scale: [1.2, 1, 1.2],
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        />
      </div>

      <div className="relative z-10 max-w-6xl mx-auto text-center">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass mb-8"
        >
          <MonitorSmartphone className="w-4 h-4 text-primary" />
          <span className="text-sm text-text-secondary">macOS Menu Bar App</span>
        </motion.div>

        {/* Title */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="text-5xl md:text-7xl font-bold mb-6"
        >
          <span className="gradient-text">ShelfSpace</span>
        </motion.h1>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="text-xl md:text-2xl text-text-secondary max-w-2xl mx-auto mb-12"
        >
          A lightweight temporary file and clipboard manager for macOS.
          Drag, drop, and organize your files effortlessly from your menu bar.
        </motion.p>

        {/* CTA Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="flex flex-col sm:flex-row gap-4 justify-center items-center"
        >
          <a
            href="https://github.com/immdipu/shelfspace/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="btn-primary flex items-center gap-2"
          >
            <Download className="w-5 h-5" />
            Download for macOS
          </a>
          <a
            href="https://github.com/immdipu/shelfspace"
            target="_blank"
            rel="noopener noreferrer"
            className="btn-secondary"
          >
            View on GitHub
          </a>
        </motion.div>

        {/* App Preview */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.5 }}
          className="mt-16"
        >
          <motion.div
            animate={{ y: [0, -10, 0] }}
            transition={{
              duration: 4,
              repeat: Infinity,
              ease: "easeInOut",
            }}
            className="relative inline-block"
          >
            {/* App mockup */}
            <div className="w-80 md:w-96 mx-auto rounded-2xl overflow-hidden shadow-2xl shadow-primary/20 border border-white/10">
              <div className="bg-surface p-4">
                {/* Header */}
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h3 className="text-lg font-bold text-primary">ShelfSpace</h3>
                    <p className="text-xs text-text-secondary">3 items</p>
                  </div>
                  <div className="flex gap-2">
                    <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center">
                      <span className="text-xs">i</span>
                    </div>
                    <div className="w-6 h-6 rounded-full bg-red-500/80 flex items-center justify-center">
                      <span className="text-xs">x</span>
                    </div>
                  </div>
                </div>

                {/* Tabs */}
                <div className="flex gap-2 mb-4">
                  {['All', 'Images', 'Text', 'Files'].map((tab, i) => (
                    <div
                      key={tab}
                      className={`px-3 py-1 rounded-md text-xs ${
                        i === 0 ? 'bg-primary text-white' : 'text-text-secondary'
                      }`}
                    >
                      {tab}
                    </div>
                  ))}
                </div>

                {/* Items grid */}
                <div className="grid grid-cols-3 gap-3">
                  {[
                    { name: 'Screenshot.png', type: 'image', color: 'bg-blue-500/20' },
                    { name: 'Notes.txt', type: 'text', color: 'bg-green-500/20' },
                    { name: 'Document.pdf', type: 'file', color: 'bg-orange-500/20' },
                  ].map((item, i) => (
                    <motion.div
                      key={i}
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: 0.8 + i * 0.1 }}
                      className={`${item.color} rounded-lg p-3 text-center`}
                    >
                      <div className="w-12 h-12 mx-auto mb-2 rounded-md bg-white/10 flex items-center justify-center">
                        <span className="text-lg">
                          {item.type === 'image' ? '🖼' : item.type === 'text' ? '📝' : '📄'}
                        </span>
                      </div>
                      <p className="text-xs truncate">{item.name}</p>
                    </motion.div>
                  ))}
                </div>
              </div>
            </div>

            {/* Glow effect */}
            <div className="absolute inset-0 -z-10 blur-3xl opacity-30 bg-gradient-to-r from-primary to-accent rounded-full transform scale-110" />
          </motion.div>
        </motion.div>
      </div>
    </section>
  )
}

export default Hero
