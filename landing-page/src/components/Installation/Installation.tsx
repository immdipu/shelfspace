import { motion } from 'framer-motion'
import { Download, FolderOpen, ShieldCheck, Terminal } from 'lucide-react'

const ease = [0.22, 1, 0.36, 1]

interface SecurityStep {
  number: string
  instruction: string
  image: string
  imageAlt: string
}

const securitySteps: SecurityStep[] = [
  {
    number: '1',
    instruction: 'Open ShelfSpace — you\'ll see a "Not Opened" warning. Click Done.',
    image: '/images/installation/step-1-not-opened.png',
    imageAlt: 'macOS dialog showing ShelfSpace Not Opened warning with Done button',
  },
  {
    number: '2',
    instruction:
      'Go to System Settings → Privacy & Security. Find "ShelfSpace was blocked" and click Open Anyway.',
    image: '/images/installation/step-2-open-anyway.png',
    imageAlt: 'macOS Privacy & Security settings showing Open Anyway button for ShelfSpace',
  },
  {
    number: '3',
    instruction: 'A confirmation dialog appears. Click Open Anyway to launch ShelfSpace.',
    image: '/images/installation/step-3-confirm.png',
    imageAlt: 'macOS confirmation dialog with Open Anyway button',
  },
]

const Installation = () => {
  return (
    <section id="installation" className="relative py-32 px-4">
      <div className="section-divider max-w-2xl mx-auto mb-32" />

      <div className="max-w-4xl mx-auto relative">
        {/* Ambient glow */}
        <div className="absolute -inset-32 bg-violet/[0.02] rounded-full blur-[120px] pointer-events-none" />

        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-80px' }}
          transition={{ duration: 0.7, ease }}
          className="text-center mb-20"
        >
          <span className="inline-block font-mono text-xs text-violet tracking-widest uppercase mb-4">
            Installation
          </span>
          <h2 className="font-display text-4xl md:text-6xl tracking-tight">
            <span className="text-ash-50">Up and running</span>{' '}
            <span className="text-ash-400 italic">in minutes.</span>
          </h2>
        </motion.div>

        {/* Steps */}
        <div className="relative">
          <div className="absolute left-[23px] md:left-[27px] top-0 bottom-0 w-px bg-gradient-to-b from-violet/30 via-violet/10 to-transparent pointer-events-none" />

          <div className="space-y-10">
            <motion.div
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-40px' }}
              transition={{ duration: 0.6, ease }}
              className="relative flex gap-5 md:gap-7"
            >
              <div className="relative z-10 flex-shrink-0">
                <div className="w-12 h-12 md:w-14 md:h-14 rounded-xl bg-void-200 border border-void-500/60 flex items-center justify-center">
                  <Download className="w-5 h-5 text-violet" />
                </div>
              </div>
              <div className="flex-1 pt-1 pb-2">
                <span className="font-mono text-[11px] text-ash-600 tracking-wider">STEP 01</span>
                <h3 className="font-display text-xl md:text-2xl text-ash-50 mb-2 mt-2 tracking-tight">
                  Download the DMG
                </h3>
                <p className="font-body text-sm md:text-base text-ash-400 leading-relaxed">
                  Grab the latest ShelfSpace.dmg from GitHub Releases. It works on both Intel and
                  Apple Silicon Macs running macOS 13.0+.
                </p>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-40px' }}
              transition={{ duration: 0.6, ease, delay: 0.05 }}
              className="relative flex gap-5 md:gap-7"
            >
              <div className="relative z-10 flex-shrink-0">
                <div className="w-12 h-12 md:w-14 md:h-14 rounded-xl bg-void-200 border border-void-500/60 flex items-center justify-center">
                  <FolderOpen className="w-5 h-5 text-violet" />
                </div>
              </div>
              <div className="flex-1 pt-1 pb-2">
                <span className="font-mono text-[11px] text-ash-600 tracking-wider">STEP 02</span>
                <h3 className="font-display text-xl md:text-2xl text-ash-50 mb-2 mt-2 tracking-tight">
                  Drag to Applications
                </h3>
                <p className="font-body text-sm md:text-base text-ash-400 leading-relaxed">
                  Open the downloaded DMG file and drag ShelfSpace into your Applications folder.
                </p>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-40px' }}
              transition={{ duration: 0.6, ease, delay: 0.1 }}
              className="relative flex gap-5 md:gap-7"
            >
              <div className="relative z-10 flex-shrink-0">
                <div className="w-12 h-12 md:w-14 md:h-14 rounded-xl bg-void-200 border border-void-500/60 flex items-center justify-center">
                  <ShieldCheck className="w-5 h-5 text-violet" />
                </div>
              </div>
              <div className="flex-1 pt-1 pb-2">
                <span className="font-mono text-[11px] text-ash-600 tracking-wider">STEP 03</span>
                <h3 className="font-display text-xl md:text-2xl text-ash-50 mb-2 mt-2 tracking-tight">
                  Approve on first launch
                </h3>
                <p className="font-body text-sm md:text-base text-ash-400 leading-relaxed mb-5">
                  Since ShelfSpace is open-source and not notarized with Apple, macOS will show a
                  security prompt. Follow these three quick steps — you only need to do this once.
                </p>
                <div className="space-y-4">
                  {securitySteps.map((s, i) => (
                    <motion.div
                      key={i}
                      initial={{ opacity: 0, y: 16 }}
                      whileInView={{ opacity: 1, y: 0 }}
                      viewport={{ once: true, margin: '-20px' }}
                      transition={{ duration: 0.5, ease, delay: 0.15 + i * 0.1 }}
                      className="glass-card rounded-xl p-4 md:p-5 border border-void-500/40"
                    >
                      <div className="flex items-start gap-3 mb-3">
                        <span className="flex-shrink-0 w-6 h-6 rounded-lg bg-violet/15 text-violet text-xs font-mono font-semibold flex items-center justify-center">
                          {s.number}
                        </span>
                        <p className="font-body text-sm md:text-base text-ash-200 leading-relaxed">
                          {s.instruction}
                        </p>
                      </div>
                      <div className="rounded-lg overflow-hidden border border-void-500/30 bg-void">
                        <img
                          src={s.image}
                          alt={s.imageAlt}
                          className="w-full h-auto max-h-[280px] object-contain"
                          loading="lazy"
                        />
                      </div>
                    </motion.div>
                  ))}
                </div>

                <div className="mt-4 glass-card rounded-xl p-4 border border-void-500/40">
                  <span className="inline-block font-mono text-[11px] text-ash-500 tracking-wider uppercase mb-2.5">
                    Alternative method
                  </span>
                  <p className="text-sm font-body text-ash-400 leading-relaxed">
                    You can also Right-click ShelfSpace.app in Applications, select "Open" from the
                    context menu, then click "Open" again in the security dialog.
                  </p>
                </div>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-40px' }}
              transition={{ duration: 0.6, ease, delay: 0.15 }}
              className="relative flex gap-5 md:gap-7"
            >
              <div className="relative z-10 flex-shrink-0">
                <div className="w-12 h-12 md:w-14 md:h-14 rounded-xl bg-void-200 border border-void-500/60 flex items-center justify-center">
                  <Terminal className="w-5 h-5 text-violet" />
                </div>
              </div>
              <div className="flex-1 pt-1 pb-2">
                <span className="font-mono text-[11px] text-ash-600 tracking-wider">STEP 04</span>
                <h3 className="font-display text-xl md:text-2xl text-ash-50 mb-2 mt-2 tracking-tight">
                  Or build from source
                </h3>
                <p className="font-body text-sm md:text-base text-ash-400 leading-relaxed mb-4">
                  Prefer to compile it yourself? Clone the repo and run a single command.
                </p>
                <div className="glass-card rounded-xl overflow-hidden border border-void-500/40">
                  <div className="flex items-center gap-1.5 px-4 py-2 border-b border-void-500/40">
                    <span className="w-2.5 h-2.5 rounded-full bg-red-500/60" />
                    <span className="w-2.5 h-2.5 rounded-full bg-yellow-500/60" />
                    <span className="w-2.5 h-2.5 rounded-full bg-green-500/60" />
                    <span className="ml-2 text-[11px] font-mono text-ash-600">Terminal</span>
                  </div>
                  <div className="px-4 py-3 font-mono text-sm text-ash-200 leading-relaxed overflow-x-auto">
                    {['git clone https://github.com/immdipu/shelfspace.git', 'cd shelfspace', 'make run'].map((line, k) => (
                      <div key={k} className="flex items-center gap-2">
                        <span className="text-violet select-none">$</span>
                        <span>{line}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </motion.div>
          </div>
        </div>
      </div>
    </section>
  )
}

export default Installation
