import { motion } from 'framer-motion'
import {
  MonitorSmartphone,
  Clipboard,
  MousePointerClick,
  Pin,
  Moon,
  Zap
} from 'lucide-react'

const features = [
  {
    icon: MonitorSmartphone,
    title: 'Menu Bar Access',
    description: 'Always accessible from your menu bar. One click away from all your temporary files.',
    color: 'text-blue-400',
    bgColor: 'bg-blue-400/10',
  },
  {
    icon: Clipboard,
    title: 'Clipboard Capture',
    description: 'Automatically captures copied images, text, and files from your clipboard.',
    color: 'text-green-400',
    bgColor: 'bg-green-400/10',
  },
  {
    icon: MousePointerClick,
    title: 'Drag & Drop',
    description: 'Simply drag files into the app. Supports files up to 200MB with smart categorization.',
    color: 'text-purple-400',
    bgColor: 'bg-purple-400/10',
  },
  {
    icon: Pin,
    title: 'Pin Important Items',
    description: 'Pin items to keep them safe from auto-cleanup. They stay until you unpin them.',
    color: 'text-orange-400',
    bgColor: 'bg-orange-400/10',
  },
  {
    icon: Moon,
    title: 'Native Dark Mode',
    description: 'Beautiful dark interface that matches your macOS system preferences.',
    color: 'text-indigo-400',
    bgColor: 'bg-indigo-400/10',
  },
  {
    icon: Zap,
    title: 'Lightweight & Fast',
    description: 'Built with Swift for native performance. Minimal memory footprint.',
    color: 'text-yellow-400',
    bgColor: 'bg-yellow-400/10',
  },
]

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
    },
  },
}

const Features = () => {
  return (
    <section id="features" className="py-24 px-4">
      <div className="max-w-6xl mx-auto">
        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <h2 className="text-4xl md:text-5xl font-bold mb-4">
            <span className="gradient-text">Powerful Features</span>
          </h2>
          <p className="text-lg text-text-secondary max-w-2xl mx-auto">
            Everything you need to manage temporary files and clipboard content efficiently.
          </p>
        </motion.div>

        {/* Features grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          {features.map((feature, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              whileHover={{ scale: 1.02, translateY: -5 }}
              className="glass rounded-2xl p-6 transition-all duration-300 hover:border-primary/30"
            >
              <div className={`w-12 h-12 ${feature.bgColor} rounded-xl flex items-center justify-center mb-4`}>
                <feature.icon className={`w-6 h-6 ${feature.color}`} />
              </div>
              <h3 className="text-xl font-semibold mb-2">{feature.title}</h3>
              <p className="text-text-secondary">{feature.description}</p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}

export default Features
