import { motion } from 'framer-motion'
import { Clipboard, LayoutGrid, MousePointerClick } from 'lucide-react'

const ease = [0.22, 1, 0.36, 1]

const steps = [
  {
    number: '01',
    icon: Clipboard,
    title: 'Copy anything',
    description: 'ShelfSpace monitors your clipboard in real-time. Copy text, images, screenshots, or files — they\'re captured instantly.',
    visual: (
      <div className="relative w-full h-full flex items-center justify-center">
        <motion.div
          className="flex flex-col gap-2"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={{
            hidden: {},
            visible: { transition: { staggerChildren: 0.2, delayChildren: 0.3 } },
          }}
        >
          {['Screenshot captured', 'Text copied to clipboard', 'File detected: report.pdf'].map((text, i) => (
            <motion.div
              key={i}
              variants={{
                hidden: { opacity: 0, x: -20 },
                visible: { opacity: 1, x: 0, transition: { duration: 0.5, ease: [0.22, 1, 0.36, 1] } },
              }}
              className="flex items-center gap-3 bg-void-400 border border-void-500/50 rounded-lg px-4 py-2.5"
            >
              <div className={`w-2 h-2 rounded-full ${i === 0 ? 'bg-blue-400' : i === 1 ? 'bg-green-400' : 'bg-amber-400'}`} />
              <span className="text-sm font-body text-ash-200">{text}</span>
              <span className="ml-auto text-[10px] font-mono text-ash-600">now</span>
            </motion.div>
          ))}
        </motion.div>
      </div>
    ),
  },
  {
    number: '02',
    icon: LayoutGrid,
    title: 'Stay organized',
    description: 'Items are automatically categorized by type. Filter by images, text, or files. Pin what matters, clear what doesn\'t.',
    visual: (
      <div className="relative w-full h-full flex items-center justify-center">
        <div className="flex gap-2">
          {['All', 'Pinned', 'Images', 'Text', 'Files'].map((tab, i) => (
            <motion.div
              key={tab}
              initial={{ opacity: 0, y: 10 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.3 + i * 0.08, duration: 0.4, ease: [0.22, 1, 0.36, 1] }}
              className={`px-3 py-1.5 rounded-lg text-xs font-body font-medium ${
                i === 0
                  ? 'bg-violet text-white'
                  : 'bg-void-400 text-ash-500 border border-void-500/50'
              }`}
            >
              {tab}
              {i < 3 && (
                <span className={`ml-1.5 text-[10px] ${i === 0 ? 'text-violet-200' : 'text-ash-600'}`}>
                  {i === 0 ? '12' : i === 1 ? '3' : '5'}
                </span>
              )}
            </motion.div>
          ))}
        </div>
      </div>
    ),
  },
  {
    number: '03',
    icon: MousePointerClick,
    title: 'Use anywhere',
    description: 'One click from your menu bar. Copy items back, drag them to any app, or let auto-clear keep things tidy.',
    visual: (
      <div className="relative w-full h-full flex items-center justify-center">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.3, duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
          className="flex items-center gap-3"
        >
          {/* Simulated menu bar area */}
          <div className="flex items-center gap-3 bg-void-300 rounded-xl px-5 py-3 border border-void-500/50">
            <div className="flex items-center gap-2">
              <div className="w-5 h-5 rounded bg-violet/20 flex items-center justify-center">
                <svg width="10" height="10" viewBox="0 0 16 16" fill="none">
                  <rect x="1" y="3" width="14" height="2.5" rx="1" fill="#8B5CF6" opacity="0.9"/>
                  <rect x="1" y="7" width="10" height="2.5" rx="1" fill="#8B5CF6" opacity="0.6"/>
                  <rect x="1" y="11" width="12" height="2.5" rx="1" fill="#8B5CF6" opacity="0.35"/>
                </svg>
              </div>
              <span className="text-xs font-body text-ash-300">Menu Bar</span>
            </div>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#525266" strokeWidth="2" strokeLinecap="round">
              <path d="M5 12h14M12 5l7 7-7 7"/>
            </svg>
            <div className="flex items-center gap-2 bg-void-400 rounded-lg px-3 py-1.5 border border-violet/20">
              <div className="w-3 h-3 rounded bg-violet/30" />
              <span className="text-xs font-body text-violet-200">Click to open</span>
            </div>
          </div>
        </motion.div>
      </div>
    ),
  },
]

const HowItWorks = () => {
  return (
    <section id="how-it-works" className="relative py-32 px-4">
      <div className="section-divider max-w-2xl mx-auto mb-32" />

      <div className="max-w-5xl mx-auto relative">
        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-80px" }}
          transition={{ duration: 0.7, ease }}
          className="text-center mb-24"
        >
          <span className="inline-block font-mono text-xs text-violet tracking-widest uppercase mb-4">
            How it works
          </span>
          <h2 className="font-display text-4xl md:text-6xl tracking-tight">
            <span className="text-ash-50">Three steps.</span>{' '}
            <span className="text-ash-400 italic">That's it.</span>
          </h2>
        </motion.div>

        {/* Steps */}
        <div className="space-y-24">
          {steps.map((step, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-60px" }}
              transition={{ duration: 0.7, ease }}
              className={`flex flex-col ${i % 2 === 1 ? 'md:flex-row-reverse' : 'md:flex-row'} items-center gap-12 md:gap-16`}
            >
              {/* Text side */}
              <div className="flex-1 max-w-md">
                <div className="flex items-center gap-4 mb-5">
                  <span className="font-mono text-sm text-ash-600">{step.number}</span>
                  <div className="w-8 h-8 rounded-lg bg-violet/10 flex items-center justify-center">
                    <step.icon className="w-4 h-4 text-violet" />
                  </div>
                </div>
                <h3 className="font-display text-3xl md:text-4xl text-ash-50 mb-4 tracking-tight">
                  {step.title}
                </h3>
                <p className="font-body text-base text-ash-400 leading-relaxed">
                  {step.description}
                </p>
              </div>

              {/* Visual side */}
              <div className="flex-1 w-full">
                <div className="glass-card rounded-2xl p-6 min-h-[160px] flex items-center justify-center overflow-hidden">
                  {step.visual}
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default HowItWorks
