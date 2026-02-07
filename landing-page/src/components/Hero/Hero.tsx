import { motion } from 'framer-motion'
import { Download, ArrowDown } from 'lucide-react'

const ease = [0.22, 1, 0.36, 1]

const AppMockup = () => (
  <div className="w-[340px] md:w-[400px] rounded-2xl overflow-hidden mockup-glow transition-all duration-700 bg-void-300">
    {/* Title bar */}
    <div className="flex items-center justify-between px-4 py-3 bg-void-300 border-b border-void-500/50">
      <div className="flex items-center gap-2.5">
        <div className="w-6 h-6 rounded-md bg-violet flex items-center justify-center">
          <svg width="10" height="10" viewBox="0 0 16 16" fill="none">
            <rect x="1" y="3" width="14" height="2.5" rx="1" fill="white" opacity="0.9"/>
            <rect x="1" y="7" width="10" height="2.5" rx="1" fill="white" opacity="0.65"/>
            <rect x="1" y="11" width="12" height="2.5" rx="1" fill="white" opacity="0.4"/>
          </svg>
        </div>
        <span className="text-[13px] font-semibold text-ash-50 font-body">ShelfSpace</span>
        <span className="text-[11px] text-ash-500 font-body">12 items</span>
      </div>
      <div className="flex items-center gap-1.5">
        <div className="w-5 h-5 rounded-md bg-void-500 flex items-center justify-center">
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#6B6B80" strokeWidth="2" strokeLinecap="round">
            <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
        </div>
        <div className="w-5 h-5 rounded-md bg-void-500 flex items-center justify-center">
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#6B6B80" strokeWidth="2" strokeLinecap="round">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </div>
      </div>
    </div>

    {/* Tabs */}
    <div className="flex items-center gap-0.5 px-3 py-2 bg-void-300 border-b border-void-500/30">
      {['All', 'Pinned', 'Images', 'Text', 'Files'].map((tab, i) => (
        <div
          key={tab}
          className={`px-3 py-1.5 rounded-md text-[11px] font-medium font-body transition-colors ${
            i === 0
              ? 'bg-violet text-white'
              : 'text-ash-500 hover:text-ash-300'
          }`}
        >
          {tab}
        </div>
      ))}
      <div className="ml-auto flex items-center gap-1">
        <div className="w-5 h-5 rounded bg-void-500/60 flex items-center justify-center">
          <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#6B6B80" strokeWidth="2.5">
            <rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/>
            <rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>
          </svg>
        </div>
        <div className="w-5 h-5 rounded bg-void-500/30 flex items-center justify-center">
          <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#525266" strokeWidth="2.5">
            <line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/>
          </svg>
        </div>
      </div>
    </div>

    {/* Items grid */}
    <div className="grid grid-cols-2 gap-2.5 p-3 bg-void-200">
      {[
        { name: 'screenshot-2024.png', color: '#3B82F6', type: 'img', size: '2.4 MB' },
        { name: 'meeting-notes.txt', color: '#22C55E', type: 'txt', size: '1.2 KB' },
        { name: 'design-v3.fig', color: '#F59E0B', type: 'file', size: '48 MB' },
        { name: 'api-response.json', color: '#8B5CF6', type: 'code', size: '3.8 KB' },
      ].map((item, i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 1.0 + i * 0.12, duration: 0.5, ease }}
          className="rounded-xl bg-void-400 border border-void-500/40 overflow-hidden group"
        >
          {/* Preview area */}
          <div className="h-[72px] relative flex items-center justify-center overflow-hidden"
            style={{ background: `linear-gradient(135deg, ${item.color}10, ${item.color}05)` }}>
            {item.type === 'img' && (
              <div className="w-full h-full bg-gradient-to-br from-blue-500/20 via-cyan-400/10 to-blue-600/20 flex items-center justify-center">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke={item.color} strokeWidth="1.5" opacity="0.6">
                  <rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/>
                  <path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"/>
                </svg>
              </div>
            )}
            {item.type === 'txt' && (
              <div className="w-full h-full p-2.5 flex flex-col gap-1">
                <div className="h-1.5 w-[80%] rounded-full bg-ash-600/30"/>
                <div className="h-1.5 w-[60%] rounded-full bg-ash-600/20"/>
                <div className="h-1.5 w-[70%] rounded-full bg-ash-600/15"/>
                <div className="h-1.5 w-[45%] rounded-full bg-ash-600/10"/>
              </div>
            )}
            {item.type === 'file' && (
              <div className="flex items-center justify-center">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke={item.color} strokeWidth="1.5" opacity="0.6">
                  <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/>
                  <path d="M14 2v4a2 2 0 0 0 2 2h4"/>
                </svg>
              </div>
            )}
            {item.type === 'code' && (
              <div className="w-full h-full p-2.5 font-mono text-[7px] leading-relaxed text-violet-300/40">
                {'{'}<br/>
                &nbsp;&nbsp;"status": 200,<br/>
                &nbsp;&nbsp;"data": {'{'} ... {'}'}
                <br/>
                {'}'}
              </div>
            )}
            {/* Pin badge on first item */}
            {i === 0 && (
              <div className="absolute top-1.5 right-1.5 w-4 h-4 rounded-full bg-violet flex items-center justify-center">
                <svg width="8" height="8" viewBox="0 0 24 24" fill="white" stroke="white" strokeWidth="2">
                  <path d="M12 17v5M9 10.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24V16a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V7a1 1 0 0 1 1-1 2 2 0 0 0 2-2H6a2 2 0 0 0 2 2 1 1 0 0 1 1 1z"/>
                </svg>
              </div>
            )}
          </div>
          {/* Footer */}
          <div className="px-2.5 py-2 border-t border-void-500/30">
            <p className="text-[10px] text-ash-100 truncate font-body font-medium">{item.name}</p>
            <p className="text-[9px] text-ash-500 font-body mt-0.5">{item.size}</p>
          </div>
        </motion.div>
      ))}
    </div>
  </div>
)

const Hero = () => {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center overflow-hidden pt-24 pb-16 px-4">
      {/* Ambient glow */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[600px] h-[600px] rounded-full bg-violet/[0.04] blur-[120px]" />
        <div className="absolute top-[60%] left-[20%] w-[300px] h-[300px] rounded-full bg-violet/[0.03] blur-[100px]" />
        <div className="absolute top-[30%] right-[10%] w-[200px] h-[200px] rounded-full bg-violet-800/[0.05] blur-[80px]" />
      </div>

      {/* Grid pattern overlay */}
      <div
        className="absolute inset-0 pointer-events-none opacity-[0.03]"
        style={{
          backgroundImage: `linear-gradient(rgba(139,92,246,0.3) 1px, transparent 1px), linear-gradient(90deg, rgba(139,92,246,0.3) 1px, transparent 1px)`,
          backgroundSize: '60px 60px',
        }}
      />

      <div className="relative z-10 max-w-5xl mx-auto flex flex-col items-center text-center">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, ease }}
          className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full border border-void-600 bg-void-200/50 mb-8"
        >
          <div className="w-1.5 h-1.5 rounded-full bg-violet glow-dot" />
          <span className="text-xs font-body font-medium text-ash-300 tracking-wide">
            macOS Menu Bar App
          </span>
          <span className="text-xs text-ash-600">|</span>
          <span className="text-xs font-body text-ash-400">Free & Open Source</span>
        </motion.div>

        {/* Title */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.1, ease }}
          className="font-display text-6xl md:text-8xl lg:text-[6.5rem] leading-[0.95] tracking-tight mb-6"
        >
          <span className="text-ash-50">Your clipboard,</span>
          <br />
          <span className="gradient-text-violet italic">elevated.</span>
        </motion.h1>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.2, ease }}
          className="font-body text-lg md:text-xl text-ash-400 max-w-xl mx-auto mb-10 leading-relaxed"
        >
          A native clipboard manager that lives in your menu bar.
          Capture images, text, and files automatically — organized,
          searchable, always one click away.
        </motion.p>

        {/* CTA Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.3, ease }}
          className="flex flex-col sm:flex-row gap-3 mb-16"
        >
          <a
            href="https://github.com/immdipu/shelfspace/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="btn-violet"
          >
            <Download className="w-4.5 h-4.5" />
            Download for macOS
          </a>
          <a
            href="https://github.com/immdipu/shelfspace"
            target="_blank"
            rel="noopener noreferrer"
            className="btn-ghost"
          >
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
            </svg>
            View on GitHub
          </a>
        </motion.div>

        {/* App Mockup */}
        <motion.div
          initial={{ opacity: 0, y: 60 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.5, ease }}
          className="relative"
        >
          {/* Mockup ambient glow */}
          <div className="absolute -inset-20 bg-violet/[0.04] rounded-full blur-[80px] pointer-events-none" />

          <motion.div
            animate={{ y: [0, -8, 0] }}
            transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
          >
            <AppMockup />
          </motion.div>
        </motion.div>

        {/* Scroll indicator */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.5, duration: 1 }}
          className="mt-16"
        >
          <motion.div
            animate={{ y: [0, 6, 0] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
          >
            <ArrowDown className="w-4 h-4 text-ash-600" />
          </motion.div>
        </motion.div>
      </div>
    </section>
  )
}

export default Hero
