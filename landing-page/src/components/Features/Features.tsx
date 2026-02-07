import { motion } from 'framer-motion'
import {
  Eye,
  Clipboard,
  GripVertical,
  LayoutGrid,
  Pin,
  Settings2,
  Zap,
  HardDrive,
  Filter,
  Copy,
  Trash2,
  Power,
} from 'lucide-react'

const features = [
  {
    icon: Clipboard,
    title: 'Smart Clipboard Monitoring',
    description: 'Auto-captures copied images, text, and files. Smart content detection with configurable polling and duplicate filtering.',
    accent: '#8B5CF6',
  },
  {
    icon: GripVertical,
    title: 'Drag & Drop Everything',
    description: 'Drop files directly into the app or drag items out to other apps. Visual drop zone with real-time feedback.',
    accent: '#3B82F6',
  },
  {
    icon: LayoutGrid,
    title: 'Grid & List Views',
    description: 'Switch between grid and list layouts with three density levels — compact, comfortable, and large.',
    accent: '#22C55E',
  },
  {
    icon: Filter,
    title: 'Content Filtering',
    description: 'Five tabs — All, Pinned, Images, Text, Files — with live item counts and instant switching.',
    accent: '#F59E0B',
  },
  {
    icon: Pin,
    title: 'Pin Important Items',
    description: 'Pin items to protect them from auto-cleanup. Persisted across restarts with clear visual indicators.',
    accent: '#EF4444',
  },
  {
    icon: Eye,
    title: 'Rich Previews',
    description: 'Image thumbnails, text content rendering, syntax-highlighted code, and file type icons with size display.',
    accent: '#06B6D4',
  },
  {
    icon: Copy,
    title: 'Quick Actions on Hover',
    description: 'Copy, pin, and delete buttons appear on hover with satisfying animations and instant feedback.',
    accent: '#EC4899',
  },
  {
    icon: HardDrive,
    title: 'Persistent Storage',
    description: 'Items saved automatically to Application Support. Survives restarts with debounced auto-save.',
    accent: '#14B8A6',
  },
  {
    icon: Settings2,
    title: 'Deeply Customizable',
    description: 'Polling interval, file size limits, capture toggles, density, thumbnail style, corner radius, retention.',
    accent: '#A78BFA',
  },
  {
    icon: Zap,
    title: 'Native Performance',
    description: 'Built with Swift and AppKit. Minimal memory footprint with smart background processing.',
    accent: '#FBBF24',
  },
  {
    icon: Power,
    title: 'Launch at Login',
    description: 'Start automatically with macOS. Configure menu bar and Dock visibility to your preference.',
    accent: '#34D399',
  },
  {
    icon: Trash2,
    title: 'Bulk Management',
    description: 'Clear all items, clear only unpinned, or set auto-clear retention by days. Stay organized effortlessly.',
    accent: '#F87171',
  },
]

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.06 },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 16 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.5, ease: [0.22, 1, 0.36, 1] },
  },
}

const Features = () => {
  return (
    <section id="features" className="relative py-32 px-4">
      {/* Background glow */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-violet/[0.02] rounded-full blur-[120px] pointer-events-none" />

      <div className="max-w-6xl mx-auto relative">
        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-80px" }}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
          className="text-center mb-20"
        >
          <span className="inline-block font-mono text-xs text-violet tracking-widest uppercase mb-4">
            Features
          </span>
          <h2 className="font-display text-4xl md:text-6xl tracking-tight mb-5">
            <span className="text-ash-50">Everything you need,</span>
            <br />
            <span className="text-ash-400 italic">nothing you don't.</span>
          </h2>
          <p className="font-body text-lg text-ash-500 max-w-lg mx-auto">
            Powerful clipboard management with a thoughtful, native macOS experience.
          </p>
        </motion.div>

        {/* Features grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-60px" }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4"
        >
          {features.map((feature, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              className="feature-card glass-card rounded-2xl p-6 transition-all duration-500 group"
            >
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center mb-4 transition-colors duration-300"
                style={{
                  background: `${feature.accent}10`,
                }}
              >
                <feature.icon
                  className="w-5 h-5 transition-colors duration-300"
                  style={{ color: feature.accent }}
                />
              </div>
              <h3 className="font-body text-[15px] font-semibold text-ash-50 mb-2">
                {feature.title}
              </h3>
              <p className="font-body text-sm text-ash-400 leading-relaxed">
                {feature.description}
              </p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}

export default Features
